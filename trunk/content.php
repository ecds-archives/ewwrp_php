<?php
include_once("config.php");
include_once("lib/xmlDbConnection.class.php");

$connectionArray{"debug"} = false;

$db = new xmlDbConnection($connectionArray);

global $title;
global $collname;
global $collection;

//$baseurl = "http://biliku.library.emory.edu/rebecca/ewwrp/";	

$id = $_GET["id"];
$node = $_GET["level"];
$runninghdr = $_GET["running-header"];
$keyword = $_GET["keyword"];
$view = $_GET["view"];		// print, blackboard, ??
// need a filter if we are in a collection ?

if ($title == '') {
  $title = "Emory Women Writers Resource Project";
  $collname = "EWWRP";
 }


$query = "let \$a := //${node}[@id='$id']
let \$doc := substring-before(util:document-name(\$a), '.xml')
let \$root := root(\$a)
let \$contentnode := (if (exists(\$a//div|\$a//titlePage)) then
  ((\$a/div[1][not(./div)]|\$a/div[1]/div[1]|\$a//div[not(./div)])|\$a//titlePage)[1]
else
  \$a)
let \$contentnodehi := \$contentnode[. |= '$keyword']
let \$content := (if (exists(\$contentnodehi)) then
 <content>{\$contentnodehi}</content>
else
 <content>
";
// don't return preceding pb if main item is itself a pb
// FIXME: this is a workaround for a bug in the sibling axis in eXist; should be fixed in future
$query .=   ($node != "pb") ? "{\$a/preceding-sibling::*[1][name() = 'pb']}" : "";

$query .= "
  {\$contentnode}
  </content>)
return <TEI.2>
  <doc>{\$doc}</doc>
  <teiHeader>
    {\$root//teiHeader//titleStmt}
    {\$root//sourceDesc}
    {\$root//rs[@type='collection']}
  </teiHeader>
  <relative-toc>
    {for \$d in (\$a/ancestor::TEI.2|\$a/ancestor::front|\$a/ancestor::titlePage|\$a/ancestor::body|\$a/ancestor::back|\$a/ancestor::text|\$a/ancestor::group|\$a/ancestor::div|\$a)
     return <item name='{name(\$d)}'>{\$d/@*}{\$d/head}
	{\$d/front/titlePage/docTitle/titlePart[@type='main']}
        <parent>{\$d/../@id}{name(\$d/..)}</parent>
      </item>}
  </relative-toc>
  <toc type='{\$a/@type}'>
      {for \$i in \$a//(front|body|back|text|group|titlePage|div)[@id!='$id' and not(exists(ancestor::q))]
      return <item name='{name(\$i)}'>{\$i/@*}{\$i/head}
      <parent>{\$i/../@id}{name(\$i/..)}</parent>
     </item>}
  </toc>";

if ($node == "pb") {
  $query .=   "<nav>
    {for \$s in \$a/preceding::pb[@entity][last()]
 	return <first name='{name(\$s)}'>{\$s/@*}</first>}
    {for \$s in \$a/preceding::pb[@entity][1]
 	return <prev name='{name(\$s)}'>{\$s/@*}</prev>}
    {for \$s in \$a/following::pb[@entity][1]
 	return <next name='{name(\$s)}'>{\$s/@*}</next>}
    {for \$s in \$a/following::pb[@entity][last()]
 	return <last name='{name(\$s)}'>{\$s/@*}</last>}
  </nav>";

} else {

  /* NOTE: as of Nov. 2006, there is a bug in the exist xquery sibling
   axes-- it fails to find a named following-sibling when there are
   nested nodes with the same name (as with nested divs in TEI)
   Using following-sibling::* and filtering on local-name for now.
  */
   
  $query .= "
  <nav>
    {for \$s in (\$a/preceding-sibling::*[local-name() = 'div'][last()]|\$a/preceding-sibling::titlePage[last()]|\$a/preceding-sibling::text[last()])[1]
 	return <first name='{name(\$s)}'>{\$s/@*}
	  {\$s/front/titlePage/docTitle/titlePart[@type='main']}
	</first>}
    {for \$s in (\$a/preceding-sibling::*[local-name() = 'div'][1]|\$a/preceding-sibling::titlePage[1]|\$a/preceding-sibling::text[1])[last()]
 	return <prev name='{name(\$s)}'>{\$s/@*}
	  {\$s/front/titlePage/docTitle/titlePart[@type='main']}
	</prev>}
    {for \$s in (\$a/following-sibling::*[local-name() = 'div'][1]|\$a/following-sibling::div[1]|\$a/following-sibling::titlePage[1]|\$a/following-sibling::text[1])[1]
 	return <next name='{name(\$s)}'>{\$s/@*}
	  {\$s/front/titlePage/docTitle/titlePart[@type='main']}
	</next>}
    {for \$s in (\$a/following-sibling::*[local-name() = 'div'][last()]|\$a/following-sibling::titlePage[last()]|\$a/following-sibling::text[last()])[1]
 	return <last name='{name(\$s)}'>{\$s/@*}
	  {\$s/front/titlePage/docTitle/titlePart[@type='main']}
	</last>}
  </nav>";
}
$query .= "
  {\$content}
</TEI.2>
";

// add keyword parameter to url, if there is one defined
$kwurl = ($keyword != '') ? "keyword=$keyword" : "";

$xsl = "$baseurl/stylesheets/content.xsl";
$xsl_params = array("url" => "content.php?level=$node&id=$id&$kwurl",	// FIXME: gets blank & if no keyword
		    "url_suffix" => $kwurl,
		    "node" => $node, "id" => $id);
if($runninghdr) $xsl_params{"running-header"} = $runninghdr;

$db->xquery($query);

// extract information to use in html page title

$doctitle = $db->findnode("title");
// truncate document title for html header
$doctitle = str_replace(", an electronic edition", "", $doctitle);

// generate a title appropriate to the kind of content being displayed
switch ($node) {
 case "div":
   $content_title =  $db->findnode("content/div/@type") . " " .  $db->findnode("content/div/@n");
   break;
 case "titlePage": $content_title = "title page"; break;
 case "pb": $content_title = $db->findnode("content/pb/@pages");
   if (!(strstr($content_title, "page"))) $content_title = "Page $content_title";
 }


// if we are in a collection, add EWWRP to the beginning of the html title
if ($collname != "EWWRP") 
  $htmltitle = "EWWRP : $title";
else
   $htmltitle = $title;


print "
$doctype
<html>
 <head>
    <title>$htmltitle : $doctitle : $content_title</title>
";
switch ($view) {
 case "print": 
 case "blackboard":
   print "<link rel='stylesheet' type='text/css' href='$baseurl/$view.css'/>";
   break;
 default: print "<link rel='stylesheet' type='text/css' href='ewwrp.css'/>"; 
 }

print "
    <link rel='shortcut icon' href='ewwrp.ico' type='image/x-icon'/>
    <script type='text/javascript' src='$baseurl/scripts/overlib.js'><!--overLIB (c) Erik Bosrup--></script>
</head>
<body>";

include("header.php");
include("nav.php");

print '<div class="content">';

print "<div class='title'><a href='index.php'>$title</a></div>";

$db->xslTransform($xsl, $xsl_params);
$db->printResult();
?>

</div>	

</body>
</html>