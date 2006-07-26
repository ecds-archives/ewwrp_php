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
$keyword = $_GET["keyword"];
// need a filter if we are in a collection?

if ($title == '') {
  $title = "Emory Women Writers Resource Project";
  $collname = "EWWRP";
 }


$query = "let \$doc := document('db/$db/$docname.xml')/TEI.2
return <TEI.2>
{\$doc/@id}
{\$doc/teiHeader}
{for \$a in \$doc//(front|body|back|text|group|titlePage|div)
  return <item name='{name(\$a)}'>{\$a/@*}{\$a/head}
  {\$a/front/titlePage/docTitle/titlePart[@type='main']}
      <parent>{\$a/../@id}{name(\$a/..)}</parent>
      </item>}
</TEI.2>";

$xsl = "$baseurl/stylesheets/toc.xsl";
  $xsl_params = array();
if ($keyword)
 $xsl_params{"url_suffix"} = "keyword=$keyword";
$xdb->xquery($query);

$doctitle = $xdb->findnode("title");
// truncate document title for html header
$doctitle = str_replace(", an electronic edition", "", $doctitle);


// if we are in a collection, add EWWRP to the beginning of the html title
if ($collname != "EWWRP") 
  $htmltitle = "EWWRP : $title";
else
   $htmltitle = $title;

?>


<html>
 <head>
    <title><?= "$htmltitle : $doctitle" ?></title>
    <link rel="stylesheet" type="text/css" href="ewwrp.css">
    <link rel="shortcut icon" href="ewwrp.ico" type="image/x-icon">
<?
$xdb->xslBind("$baseurl/stylesheets/teiheader-dc.xsl");
$xdb->xslBind("$baseurl/stylesheets/dc-htmldc.xsl");
$xdb->transform();
$xdb->printResult();
?>
</head>
<body>

<? include("header.php") ?>
<? include("nav.php") ?>

<div class="content">

<div class="title"><a href="index.php"><?= $title ?></a></div>

<?
$xdb->xslTransform($xsl, $xsl_params);
$xdb->printResult();
?>


</div>	

</body></html>