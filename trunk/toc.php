<?php
include_once("config.php");
include_once("lib/xmlDbConnection.class.php");

$connectionArray{"debug"} = false;

$xdb = new xmlDbConnection($connectionArray);

global $title;
global $collname;
global $collection;

$baseurl = "http://biliku.library.emory.edu/rebecca/ewwrp/";	

$docname = $_GET["id"];
// need a filter if we are in a collection?

if ($title == '') {
  $title = "Emory Women Writers Resource Project";
  $collname = "EWWRP";
 }


$query = "let \$doc := document('db/$db/$docname.xml')/TEI.2
return <TEI.2>
{\$doc/@id}
{\$doc/teiHeader}
{for \$a in \$doc//(front|body|back|text|group|titlePage|div)
  return <item name='{name(\$a)}'>{\$a/@*}{\$a/head}
      <parent>{\$a/../@id}{name(\$a/..)}</parent>
      </item>}
</TEI.2>";

$xsl = "$baseurl/stylesheets/toc.xsl";


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
$xdb->xquery($query);
$xdb->xslTransform($xsl);
$xdb->printResult();
?>


</div>	

</body></html>