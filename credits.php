<?php
include_once("config.php");

global $title;
global $abbrev;
global $collection;

if ($title == '') {
  $title = "Emory Women Writers Resource Project";
  $abbrev = "EWWRP";
 }

print "$doctype
<html>
 <head>
<title>$htmltitle : About</title>
    <link rel='stylesheet' type='text/css' href='ewwrp.css'>
    <link rel='shortcut icon' href='ewwrp.ico' type='image/x-icon'>
</head>
<body>";

include("header.php");
include("nav.php");

print "<div class='content'>

<div class='title'><a href='index.php'>$title</a></div>";

include("credits.xml");

print "</div></body></html>";

?>