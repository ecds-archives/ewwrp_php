<?php

global $title;
global $collname;
$baseurl = "http://biliku.library.emory.edu/rebecca/ewwrp/";	
$page = "index";

if ($title == '') {
  $title = "Emory Women Writers Resource Project";
  $collname = "EWWRP";
 }

?>
<html>
 <head>
    <title><?= $title ?></title>
    <link rel="stylesheet" type="text/css" href="ewwrp.css">
    <link rel="shortcut icon" href="ewwrp.ico" type="image/x-icon">
</head>
<body>


<? include("header.php") ?>

<div class="titlebar tbar-left"></div>
<div class="titlebar tbar-right"></div>
<div class="titlebar tbar-text">
<?= $title ?>
</div>


<? include("nav.php") ?>


<div class="rightcol">

<?
 // read in xml file of front page images & associated metadata
$imgdoc = new DOMDocument();
$imgdoc->load("$baseurl/frontpageimages.xml");
$xpath = new domxpath($imgdoc);
// filter on collection if there is one defined
$imglist = $xpath->query("/images/div[@collection='genrefiction']");
// generate random index # based on number of matching images
$index = rand(0, ($imglist->length - 1));

// create a new output domdoc, and use the random index to insert image div
$odoc = new DOMDocument();
$onode = $odoc->importNode($imglist->item($index), TRUE);
$odoc->appendChild($onode);
print $odoc->saveXML();

?>

<!-- white partially-opaque background for text about image -->
<div class="imgtextbg"></div>

<div class="copyright">
<? include("funding.xml") ?>
<hr class="menu">
    &copy;2005 Emory University | Contact: <a href="mailto:beckctr@emory.edu">The Beck Center</a>
</div>

</div>		<!-- end right column -->

</body></html>