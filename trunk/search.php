<?php
include_once("config.php");
include_once("lib/xmlDbConnection.class.php");

$connectionArray{"debug"} = false;

$db = new xmlDbConnection($connectionArray);

global $title;
global $collname;
global $collection;

$baseurl = "http://biliku.library.emory.edu/rebecca/ewwrp/";	

$kw = $_GET["keyword"];
// need a filter if we are in a collection

$pos = $_GET["position"];
$max = $_GET["max"];

if ($pos == '') $pos = 1;
if ($max == '') $max = 20;

if ($title == '') {
  $title = "Emory Women Writers Resource Project";
  $collname = "EWWRP";
 }

// filter if a collection is defined
if ($collection) {
  $rsfilter = "[teiHeader/profileDesc/creation/rs[@type='collection' and .='$collection']]";
}

$query = "for \$a in /TEI.2${rsfilter}[. &= '$kw']
let \$t := \$a//titleStmt/title
let \$doc := substring-before(util:document-name(\$a), '.xml')
let \$matchcount := text:match-count(\$a)
order by \$matchcount descending
return <TEI.2>{\$a/@id}<doc>{\$doc}</doc>{\$t}<hits>{\$matchcount}</hits></TEI.2>";

$xsl = "$baseurl/stylesheets/search.xsl";
//$xsl_params = array('field' => $field, 'value' => $value, 'max' => $max);

?>
<html>
 <head>
<title><?= $title ?> : Search</title>
    <link rel="stylesheet" type="text/css" href="ewwrp.css">
    <link rel="shortcut icon" href="ewwrp.ico" type="image/x-icon">
</head>
<body>

<? include("header.php") ?>
<? include("nav.php") ?>

<div class="content">

<div class="title"><a href="index.php"><?= $title ?></a></div>

<?

$db->xquery($query, $pos, $max);

print "<p>Found $db->count texts that contain '$kw'</p>";

$db->xslTransform($xsl);
$db->printResult();

?>


</div>	

</body></html>

  
