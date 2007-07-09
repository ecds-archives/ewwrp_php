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
   $path1 = "//teiHeader$rsfilter//titleStmt/author/name";
   $path2 = "//teiHeader$rsfilter//titleStmt/author/name/@reg";
   $path = "('$path1', '$path2')";
   break;
 case "subject":
   $path = "'//teiHeader$rsfilter//keywords/list/item'";
   break;
 case "title":
   $path = "'//teiHeader$rsfilter//titleStmt/title'";
   $label = "";		// no labels (each title = one text)
   break;
 }

if (strpos($str, ' ')) {
  $str = str_replace(" ", "* ", $str);
 }


if ($field == "keyword") {
  // use eXist's text index-terms search
$query = "import module namespace suggest='http://www.library.emory.edu/xquery/suggest' at
'xmldb:exist:///db/xquery-modules/suggest.xqm';
<ul> {
let \$terms := text:index-terms(collection('/db/ewwrp')/TEI.2". $rsfilter .", '" . $str . "',
  util:function('suggest:term-callback', 2), 15)
for \$li in \$terms
order by xs:int(\$li/count) descending
return <li>
  <span class='count'>({\$li/count} hit{if (\$li/count != 1) then 's' else ()})</span>
  <span class='value'>{\$li/term}</span>
 </li>
}</ul>
";
 } else {
  
  $query = "import module namespace suggest='http://example.org/suggest' at
'xmldb:exist:///db/xquery-modules/suggest.xqm';
suggest:suggestor('ewwrp', $path, '$str', '$label')
";

 }

$db->xquery($query);
print $db->getXML();

/* print "<ul><li>last result...<pre>";
print_r($_REQUEST);
print "</pre></li></ul>"; */



?>
