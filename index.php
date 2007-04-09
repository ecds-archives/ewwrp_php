<?php

include("config.php");

global $title;
global $abbrev;
global $collection;
//$baseurl = "http://biliku.library.emory.edu/rebecca/ewwrp/";	
$page = "index";

if ($title == '') {
  $title = "Emory Women Writers|Resource Project";
  $abbrev = "EWWRP";
}


// | determines how to center title
$t = explode('|', $title);
//$t[1] = "Emory Women Writers";
//$t[2] = "Resource Project";
$title = str_replace("|", " ", $title);

// if we are in a collection, add EWWRP to the beginning of the html title
if ($abbrev != "EWWRP") 
  $htmltitle = "EWWRP : $title";
else
   $htmltitle = $title;


?>
<html>
 <head>
    <title><?= $htmltitle ?></title>
    <link rel="stylesheet" type="text/css" href="ewwrp.css">
    <link rel="shortcut icon" href="ewwrp.ico" type="image/x-icon">
</head>
<body>


<? include("header.php") ?>

<div class="titlebar tbar-left"></div>
<div class="titlebar tbar-right"></div>
<div class="titlebar tbar-text titleleft"><?= $t[0] ?></div>
<div class="titlebar tbar-text titleright"><?= $t[1] ?></div>

<!-- (simplified version)
<div class="titlebar tbar-left"><p><?= $t[0] ?></p></div>
<div class="titlebar tbar-right"><p><?= $t[1] ?></p></div> -->


<? include("nav.php") ?>


<div class="rightcol">

<?
 // read in xml file of front page images & associated metadata
$imgdoc = new DOMDocument();
$imgdoc->load("$baseurl/frontpageimages.xml");
$xpath = new domxpath($imgdoc);
// filter on collection if there is one defined
if ($collection) {
  $collection = stripslashes($collection);
  $filter = "[@collection=\"$collection\"]";
 }
$imglist = $xpath->query("/images/div$filter");
if ($imglist->length) {
  // generate random index # based on number of matching images
  $index = rand(0, ($imglist->length - 1));
   
  // create a new output domdoc, and use the random index to insert image div
  $odoc = new DOMDocument();
  $onode = $odoc->importNode($imglist->item($index), TRUE);
  $odoc->appendChild($onode);
  print $odoc->saveXML();
 } else {
  print "<div class='image'>(no images yet for this collection)</div>";
 }
?>

<!-- white partially-opaque background for text about image -->
<!-- <div class="imgtextbg"></div>  -->


<div class="copyright">
<? include("funding.xml") ?>
<hr class="menu">
    &copy;2006 Emory University | Contact: <a href="mailto:beckctr@emory.edu">The Beck Center</a>
</div>

</div>		<!-- end right column -->

</body></html>
