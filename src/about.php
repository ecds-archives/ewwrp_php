<?php
include_once("config.php");

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


print "$doctype
<html>
 <head>
<title>$htmltitle : About</title>
    <link rel='stylesheet' type='text/css' href='web/css/ewwrp.css'>
    <link rel='shortcut icon' href='ewwrp.ico' type='image/x-icon'>
</head>
<body>";

include("header.php");
include("nav.php");

print "<div class='content'>

<div class='title'><a href='index.php'>$title</a></div>";

include("web/xml/about.xml");

print "</div></body></html>";

?>