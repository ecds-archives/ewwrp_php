<?php
include_once("config.php");
include_once("lib/xmlDbConnection.class.php");

$connectionArray{"debug"} = false;

$xdb = new xmlDbConnection($connectionArray);

$docname = $_GET["id"];

$query = "document('/db/$db/$docname.xml')/TEI.2/teiHeader";

$xsl = "$baseurl/stylesheets/teiheader.xsl";

$xdb->xquery($query);
$xdb->xslBind($xsl);
$xdb->transform();

global $title;
global $abbrev;
global $collection;

if ($title == '') {
  $title = "Emory Women Writers Resource Project";
  $abbrev = "EWWRP";
 }
// if we are in a collection, add EWWRP to the beginning of the html title
if ($abbrev != "EWWRP") 
  $htmltitle = "EWWRP : $title";
else
   $htmltitle = $title;

$doctitle = $xdb->findnode("title");
$doctitle = str_replace(", an electronic edition", "", $doctitle);

print "$doctype
<html>
 <head>
    <title>$htmltitle : Metadata for $doctitle</title>
    <link rel=\"stylesheet\" type=\"text/css\" href=\"teiheader.css\">
    <link rel=\"shortcut icon\" href=\"ewwrp.ico\" type=\"image/x-icon\">
</head>
<body>
";


$xdb->printResult();

print "</body></html>";
?>