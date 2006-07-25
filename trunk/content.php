<?php
include_once("config.php");
include_once("lib/xmlDbConnection.class.php");

$connectionArray{"debug"} = false;

$db = new xmlDbConnection($connectionArray);

global $title;
global $collname;
global $collection;

$baseurl = "http://biliku.library.emory.edu/rebecca/ewwrp/";	

$id = $_GET["id"];
$node = $_GET["level"];
$runninghdr = $_GET["running-header"];
// need a filter if we are in a collection ?

if ($title == '') {
  $title = "Emory Women Writers Resource Project";
  $collname = "EWWRP";
 }


$query = "let \$a := //${node}[@id='$id']
let \$doc := substring-before(util:document-name(\$a), '.xml')
let \$root := root(\$a)
let \$content := (if (exists(\$a//div|\$a//titlePage)) then
  <content>{((\$a/div[not(./div)],\$a//div[not(./div)])|\$a//titlePage)[1]}</content>
else 
  <content>
  {\$a/preceding-sibling::pb[1]}{\$a}
  </content>)
return <TEI.2>
  <doc>{\$doc}</doc>
  <teiHeader>
    {\$root//teiHeader//titleStmt}
    {\$root//sourceDesc}
  </teiHeader>
  <relative-toc>
    {for \$d in (\$a/ancestor::TEI.2|\$a/ancestor::front|\$a/ancestor::titlePage|\$a/ancestor::body|\$a/ancestor::back|\$a/ancestor::text|\$a/ancestor::group|\$a/ancestor::div|\$a)
     return <item name='{name(\$d)}'>{\$d/@*}{\$d/head}
	{\$d/front/titlePage/docTitle/titlePart[@type='main']}
        <parent>{\$d/../@id}{name(\$d/..)}</parent>
      </item>}
  </relative-toc>
  <toc>{for \$i in \$a//(front|body|back|text|group|titlePage|div)[@id!='$id' and not(exists(ancestor::q))]
      return <item name='{name(\$i)}'>{\$i/@*}{\$i/head}
      <parent>{\$i/../@id}{name(\$i/..)}</parent>
     </item>}
  </toc>
  <nav>
    {for \$s in (\$a/preceding-sibling::div[last()]|\$a/preceding-sibling::titlePage[last()]|\$a/preceding-sibling::text[last()])[1]
 	return <first name='{name(\$s)}'>{\$s/@*}
	  {\$s/front/titlePage/docTitle/titlePart[@type='main']}
	</first>}
    {for \$s in (\$a/preceding-sibling::div[1]|\$a/preceding-sibling::titlePage[1]|\$a/preceding-sibling::text[1])[last()]
 	return <prev name='{name(\$s)}'>{\$s/@*}
	  {\$s/front/titlePage/docTitle/titlePart[@type='main']}
	</prev>}
    {for \$s in (\$a/following-sibling::div[1]|\$a/following-sibling::titlePage[1]|\$a/following-sibling::text[1])[1]
 	return <next name='{name(\$s)}'>{\$s/@*}
	  {\$s/front/titlePage/docTitle/titlePart[@type='main']}
	</next>}
    {for \$s in (\$a/following-sibling::div[last()]|\$a/following-sibling::titlePage[last()]|\$a/following-sibling::text[last()])[1]
 	return <last name='{name(\$s)}'>{\$s/@*}
	  {\$s/front/titlePage/docTitle/titlePart[@type='main']}
	</last>}
  </nav>
  {\$content}
</TEI.2>
";



$xsl = "$baseurl/stylesheets/content.xsl";
$xsl_params = array("url" => "content.php?level=$node&id=$id",
		    "node" => $node, "id" => $id);
if($runninghdr) $xsl_params{"running-header"} = $runninghdr;


?>
<html>
 <head>
    <title><?= $title ?></title>
    <link rel="stylesheet" type="text/css" href="ewwrp.css">
    <link rel="shortcut icon" href="ewwrp.ico" type="image/x-icon">
</head>
<body>

<? include("header.php") ?>
<? include("nav.php") ?>

<div class="content">

<div class="title"><a href="index.php"><?= $title ?></a></div>

<? 
$db->xquery($query);
$db->xslTransform($xsl, $xsl_params);
$db->printResult();
?>

</div>	

</body></html>