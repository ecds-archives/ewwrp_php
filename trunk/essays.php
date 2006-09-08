<?php
include_once("config.php");
include_once("lib/xmlDbConnection.class.php");

$connectionArray{"debug"} = false;

$db = new xmlDbConnection($connectionArray);

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
?>

<html>
 <head>
<title><?= $htmltitle ?> : Browse <?= $field?></title>
    <link rel="stylesheet" type="text/css" href="ewwrp.css"/>
    <link rel="shortcut icon" href="ewwrp.ico" type="image/x-icon"/>
</head>
<body>

<? include("header.php") ?>
<? include("nav.php") ?>

<div class="content">

<div class="title"><a href="index.php"><?= $title ?></a></div>


<? 

//query for critical introductions & critical essays:
//how to filter by collection?

// get all critical essays & critical introductions
// return with first section id (for critical introductions) or essay id
// return first docauthor & section heading (there are duplicates in the critical introductions)
$query = 'for $d in (//div[@type="critical essay"], //div[@type="critical introduction"])
let $rs := (root($d)/TEI.2/teiHeader//rs[@type="collection"], $d/rs[@type="collection"])
return <div> 
{$d/@type} 
{$d/@id} 
{$d//docAuthor[1]}
{$d//docDate[1]} 
{$d//head[1]}
{$rs}
</div>';

$xsl = "$baseurl/stylesheets/essays.xsl";
$db->xquery($query);
$db->xslTransform($xsl);
$db->printResult();



?>


</div>	

</body></html>