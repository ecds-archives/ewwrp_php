<?php
include_once("config.php");
include_once("common_functions.php");
include_once("lib/xmlDbConnection.class.php");

$connectionArray{"debug"} = false;

$xdb = new xmlDbConnection($connectionArray);

global $title;
global $abbrev;
global $collection;

$docname = $_GET["id"];
$keyword = $_GET["keyword"];
$view = $_GET["view"];		// print, blackboard, ??
// need a filter if we are in a collection?

if ($title == '') {
  $title = "Emory Women Writers Resource Project";
  $abbrev = "EWWRP";
 }


$query = $teixq . 'let $doc := document("/db/' . $db . '/' . $docname . '.xml")/TEI.2
return  <TEI.2>
  {$doc/@id}
  {$doc/teiHeader}
  <toc>{teixq:toc($doc)}</toc>
  </TEI.2>
';

$xsl = "xslt/toc.xsl";
  $xsl_params = array("id" => $docname,
		      "url" => "toc.php?id=$docname");
if ($keyword)
 $xsl_params{"url_suffix"} = "keyword=$keyword";
$xdb->xquery($query);

$doctitle = $xdb->findnode("title");
// truncate document title for html header
$doctitle = str_replace(", an electronic edition", "", $doctitle);


// if we are in a collection, add EWWRP to the beginning of the html title
if ($abbrev != "EWWRP") 
  $htmltitle = "EWWRP : $title";
else
   $htmltitle = $title;

print "$doctype  
<html>
 <head>
    <title>$htmltitle : $doctitle</title>";

switch ($view) {
 case "print": 
 case "blackboard":
   print "<link rel='stylesheet' type='text/css' href='web/css/$view.css'/>";
   break;
 default: print "<link rel='stylesheet' type='text/css' href='web/css/ewwrp.css'/>"; 
 }
print '
    <link rel="shortcut icon" href="ewwrp.ico" type="image/x-icon"/>';

$xdb->xslBind("xslt/teiheader-dc.xsl");
$xdb->xslBind("xslt/dc-htmldc.xsl");
$xdb->transform();
$xdb->printResult();
?>
</head>
<body>

<?
include("header.php");
include("nav.php");
//validate_link();	// for testing only
?>

<div class="content">

<div class="title"><a href="index.php"><?= $title ?></a></div>

<?
$xdb->xslTransform($xsl, $xsl_params);
$xdb->printResult();
?>


</div>	




</body></html>
