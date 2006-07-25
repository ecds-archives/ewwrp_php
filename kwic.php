<?php
include_once("config.php");
include_once("lib/xmlDbConnection.class.php");

$connectionArray{"debug"} = false;

$xdb = new xmlDbConnection($connectionArray);

global $title;
global $collname;
global $collection;

$baseurl = "http://biliku.library.emory.edu/rebecca/ewwrp/";	

$docname = $_GET["id"];
$kewyord = $_GET["keyword"];


// need a filter if we are in a collection?

if ($title == '') {
  $title = "Emory Women Writers Resource Project";
  $collname = "EWWRP";
 }


// what should be displayed here?  tgfw shows top-level TOC

// basically TOC query with context added
// note: using |= instead of &= because we want context for any of the
// keyword terms, whether they appear together or not
$xquery = "let \$doc := document('db/$db/$docname.xml')/TEI.2
return <TEI.2>
{\$doc/@id}
<doc>$docname</doc>
<teiHeader>
  {\$doc//teiHeader//titleStmt}
  {\$doc//sourceDesc}
</teiHeader>
{for \$a in \$doc//(front|body|back|text|group|titlePage|div)[. |= '$keyword' or .//* |= '$keyword']
  return <item name='{name(\$a)}'>{\$a/@*}{\$a/head}
  {\$a/front/titlePage/docTitle/titlePart[@type='main']}
      <parent>{\$a/../@id}{name(\$a/..)}</parent>
       {if ((name(\$a) != 'text') and not(\$a/div)) then
	  <context>{for \$c in \$a//*[. |= '$keyword']
		      return if (name(\$c) = 'hi') then
			\$c/..
		      else \$c }</context>
       else <context/>}
      </item>}
</TEI.2>";


/* this is one way to specify context nodes  (filter based on the kinds of nodes to include)
  <context>{(\$a//p|\$a//titlePart|\$a//q|\$a//note)[. &= '$keyword']}</context>
   above is another way-- allow any node, but if the node is a <hi>, return parent instead
   (what other nodes would need to be excluded? title? others?)
*/

$xdb->xquery($xquery);
$doctitle = $xdb->findnode("title");

print "<html>
 <head>
    <title>$title : $doctitle : Keyword in Context</title>
    <link rel='stylesheet' type='text/css' href='ewwrp.css'>
    <link rel='shortcut icon' href='ewwrp.ico' type='image/x-icon'>";

include("header.php");
include("nav.php");

print "<div class='content'>
<div class='title'><a href='index.php'>$title</a></div>";


$xdb->xslBind("$baseurl/stylesheets/kwic-towords.xsl");
$xdb->xslBind("$baseurl/stylesheets/kwic.xsl");

$xdb->transform();
$xdb->printResult();


?>