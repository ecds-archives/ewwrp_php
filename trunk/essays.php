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
<title><?= $htmltitle ?> : Essays <?= $field?></title>
    <link rel="stylesheet" type="text/css" href="ewwrp.css"/>
    <link rel="shortcut icon" href="ewwrp.ico" type="image/x-icon"/>
</head>
<body>

<? include("header.php") ?>
<? include("nav.php") ?>

<div class="content">

<div class="title"><a href="index.php"><?= $title ?></a></div>


<? 

if (isset($collection)) {
  $filter = " where \$rs = '$collection' ";
}

//query for critical introductions & critical essays:
//how to filter by collection?

// get all critical essays & critical introductions
// return with first section id (for critical introductions) or essay id
// return first docauthor & section heading (there are duplicates in the critical introductions)
$query = 'for $d in (//div[@type="critical essay"], //div[@type="critical introduction"])
let $rs := (if (exists($d/rs)) then
	 $d/rs[@type="collection"]
    else root($d)/TEI.2/teiHeader//rs[@type="collection"])' 
  . $filter . ' 
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



// handle the case where there are no essays for a specific collection
// (which will be the case for many)
if ($db->count == 0) {
  print "<p>There are no essays for this collection.</p>
	<p>View <a href='../essays.php'>all essays</a>.</p>";
}



?>


</div>	

</body></html>