<?php
include_once("config.php");
include_once("lib/xmlDbConnection.class.php");

$connectionArray{"debug"} = false;

$xdb = new xmlDbConnection($connectionArray);

$docname = $_GET["id"];
$mode = $_GET["mode"];		// paragraph or table
if (!($mode)) $mode = "paragraph";

$query = "document('db/$db/$docname.xml')/TEI.2/teiHeader";

$xsl = "$baseurl/stylesheets/teiheader.xsl";
$xsl_params = array("mode" => $mode);

$xdb->xquery($query);
$xdb->xslBind($xsl, $xsl_params);
$xdb->transform();

global $title;
global $collname;
global $collection;

if ($title == '') {
  $title = "Emory Women Writers Resource Project";
  $collname = "EWWRP";
 }
// if we are in a collection, add EWWRP to the beginning of the html title
if ($collname != "EWWRP") 
  $htmltitle = "EWWRP : $title";
else
   $htmltitle = $title;

$doctitle = $xdb->findnode("title");
$doctitle = str_replace(", an electronic edition", "", $doctitle);

print "<html>
 <head>
    <title>$htmltitle : Metadata for $doctitle</title>
    <link rel=\"stylesheet\" type=\"text/css\" href=\"teiheader.css\">
    <link rel=\"shortcut icon\" href=\"ewwrp.ico\" type=\"image/x-icon\">
</head>
<body>

<h1>Information about document $id</h1>
<p>(this metadata is from the teiHeader)</p>
";


$xdb->printResult();

print "</body></html>";
?>