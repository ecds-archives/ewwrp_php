<?php
include_once("config.php");

global $title;
global $collname;
global $collection;

if ($title == '') {
  $title = "Emory Women Writers Resource Project";
  $collection = $title;
  $collname = "EWWRP";
 }

// if we are in a collection, add EWWRP to the beginning of the html title
if ($collname != "EWWRP") 
  $htmltitle = "EWWRP : $title";
else
   $htmltitle = $title;


print "<html>
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

print "<h1>Advanced Search</h1>\n";
print "<p>Search across all texts in " . stripslashes($collection) . "</p>\n";

include("searchform.php");
?>
    </div>
  </body>
</html>


