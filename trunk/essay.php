<?php
include_once("config.php");
include_once("lib/xmlDbConnection.class.php");

$connectionArray{"debug"} = false;

$db = new xmlDbConnection($connectionArray);

global $title;
global $abbrev;
global $collection;

$id = $_REQUEST["id"];
$node = $_GET["level"];
$runninghdr = $_GET["running-header"];
$keyword = $_GET["keyword"];
$view = $_GET["view"];		// print, blackboard, ??
// need a filter if we are in a collection ?

if ($title == '') {
  $title = "Emory Women Writers Resource Project";
  $abbrev = "EWWRP";
 }


$query = "for \$a in (//div[@id='$id'][@type='critical essay'], //div[@id='$id'][@type='critical introduction'])
let \$doc := substring-before(util:document-name(\$a), '.xml')
let \$root := root(\$a)
return <TEI.2> 
  <doc>{\$doc}</doc>
  <teiHeader>
    {\$root//teiHeader//titleStmt}
    {\$root//sourceDesc}
  </teiHeader>
<content>{\$a}</content>
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
if ($abbrev != "EWWRP") 
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