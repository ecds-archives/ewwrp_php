<?php

$str = $_REQUEST["str"];
$field = $_REQUEST["field"];
$coll = $_REQUEST["coll"];

// FIXME: add subcollection to filter...


include_once("config.php");
include_once("lib/xmlDbConnection.class.php");

$connectionArray{"debug"} = false;
$connectionArray{"exist-wrap"} = "no";

$db = new xmlDbConnection($connectionArray);

$label = "text";	// label for # of matches

if ($coll != '')
  $rsfilter = "[.//rs[@type=\"collection\" and .=\"$coll\"]]";
 else $rsfilter = "";

switch($field) {
 case "author":
   $path = "//teiHeader$rsfilter//titleStmt/author/name";
   $path2 = "//teiHeader$rsfilter//titleStmt/author/name/@reg";
   break;
 case "subject":
   $path = "//teiHeader$rsfilter//keywords/list/item";
   break;
 case "title":
   $path = "//teiHeader$rsfilter//titleStmt/title";
   $label = "";		// no labels (each title = one text)
   break;
 }



$query = "import module namespace suggest='http://example.org/suggest' at
'xmldb:exist:///db/xquery-modules/suggest.xqm';
suggest:suggestor('ewwrp', ('$path', '$path2'), '$str', '$label')
";

$db->xquery($query);
print $db->getXML();

/* print "<ul><li>last result...<pre>";
print_r($_REQUEST);
print "</pre></li></ul>"; */



?>
