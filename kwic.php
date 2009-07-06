<?php
include_once("config.php");
include_once("lib/xmlDbConnection.class.php");

$connectionArray{"debug"} = false;

$xdb = new xmlDbConnection($connectionArray);

global $title;
global $abbrev;
global $collection;

//$baseurl = "http://biliku.library.emory.edu/rebecca/ewwrp/";	

$docname = $_GET["id"];
$keyword = $_GET["keyword"];


// need a filter if we are in a collection?

if ($title == '') {
  $title = "Emory Women Writers Resource Project";
  $abbrev = "EWWRP";
 }

// if we are in a collection, add EWWRP to the beginning of the html title
if ($abbrev != "EWWRP") 
  $htmltitle = "EWWRP : $title";
else
   $htmltitle = $title;


// what should be displayed here?  tgfw shows top-level TOC

// basically TOC query with context added
// note: using |= instead of &= because we want context for any of the
// keyword terms, whether they appear together or not

$xquery = "declare option exist:serialize 'highlight-matches=all';";
$xquery .= $teixq . "let \$doc := document('/db/$db/$docname.xml')/TEI.2
return <TEI.2>
{\$doc/@id}
<doc>$docname</doc>
<teiHeader>
  {\$doc//teiHeader//titleStmt}
  {\$doc//sourceDesc}
</teiHeader>
<kwic>{teixq:kwic-context(\$doc, '$keyword')}</kwic>
</TEI.2>";


/* this is one way to specify context nodes  (filter based on the kinds of nodes to include)
  <context>{(\$a//p|\$a//titlePart|\$a//q|\$a//note)[. &= '$keyword']}</context>
   above is another way-- allow any node, but if the node is a <hi>, return parent instead
   (what other nodes would need to be excluded? title? others?)
*/

$xdb->xquery($xquery);
$doctitle = $xdb->findnode("title");
// truncate document title for html header
$doctitle = str_replace(", an electronic edition", "", $doctitle);


print "$doctype
<html>
 <head>
    <title>$htmltitle : $doctitle : Keyword in Context</title>
    <link rel='stylesheet' type='text/css' href='ewwrp.css'>
    <link rel='shortcut icon' href='ewwrp.ico' type='image/x-icon'>";

include("header.php");
include("nav.php");

print "<div class='content'>
<div class='title'><a href='index.php'>$title</a></div>";

$xsl_params = array("url_suffix" => "keyword=$keyword");

$xdb->xslBind("$baseurl/stylesheets/kwic-towords.xsl");
$xdb->xslBind("$baseurl/stylesheets/kwic.xsl", $xsl_params);

$xdb->transform();
$xdb->printResult();


?>