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
// need a filter if we are in a collection ?

if ($title == '') {
  $title = "Emory Women Writers Resource Project";
  $collname = "EWWRP";
 }


$query = "let \$a := //${node}[@id='$id']
let \$root := root(\$a)
return <TEI.2>
  <teiHeader>
    {\$root//teiHeader//titleStmt}
    {\$root//sourceDesc}
  </teiHeader>
  <relative-toc>
    {for \$d in \$root//(TEI.2|front|body|back|text|group|div)[exists(.//div/@id='$id')]
     return <item name='{name(\$d)}'>{\$d/@*}{\$d/head}
        <parent>{\$d/../@id}{name(\$d/..)}</parent>
      </item>}
  </relative-toc>
  <content>{\$a}</content>
</TEI.2>
";



$xsl = "$baseurl/stylesheets/content.xsl";


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
$db->xslTransform($xsl);
$db->printResult();
?>


</div>	

</body></html>