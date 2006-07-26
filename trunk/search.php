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


// if we are in a collection, add EWWRP to the beginning of the html title
if ($collname != "EWWRP") 
  $htmltitle = "EWWRP : $title";
else
   $htmltitle = $title;


// filter if a collection is defined
if ($collection) {
  $rsfilter = "[teiHeader/profileDesc/creation/rs[@type='collection' and .='$collection']]";
}

$query = "for \$a in /TEI.2${rsfilter}[. &= '$kw']
let \$t := \$a//titleStmt/title
let \$doc := substring-before(util:document-name(\$a), '.xml')
let \$auth := \$a//titleStmt/author
let \$date := root(\$a)//sourceDesc/bibl/date
let \$matchcount := text:match-count(\$a)
order by \$matchcount descending
return <item>{\$a/@id}
  <hits>{\$matchcount}</hits>
  {\$t}
  <id>{\$doc}</id>
  {\$auth}
  {\$date}
</item>";

$xsl = "$baseurl/stylesheets/browse.xsl";
//$xsl_params = array('field' => $field, 'value' => $value, 'max' => $max);
$xsl_params = array('mode' => "search", 'keyword' => $kw, 'max' => $max);

?>
<html>
 <head>
<title><?= $htmltitle ?> : Search Results</title>
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

print "<h1>Texts that contain '$kw'</h1>";

$db->xslTransform($xsl, $xsl_params);
$db->printResult();

?>


</div>	

</body></html>

  
