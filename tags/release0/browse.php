<?php
include_once("config.php");
include_once("lib/xmlDbConnection.class.php");

$connectionArray{"debug"} = false;

$db = new xmlDbConnection($connectionArray);

global $title;
global $collname;
global $collection;

$baseurl = "http://biliku.library.emory.edu/rebecca/ewwrp/";	

$field = $_GET["field"];
$value = $_GET["value"];
// need a filter if we are in a collection

if ($title == '') {
  $title = "Emory Women Writers Resource Project";
  $collname = "EWWRP";
 }

// filter format for profile information *only* if a collection is defined
if ($collection) {
  $rsfilter = "@type='collection' and .='$collection'";
  $filter = "[rs[$rsfilter]]";				// version of filter relative to profileDesc
  $ancfilter = "[ancestor::TEI.2//rs[$rsfilter]]";	// version of filter needed for titles/authors/etc
}
  
// retrieve browse fields
$profile_qry = 'let $p := //profileDesc/creation' . $filter . '
return <profile>
{ for $a in distinct-values($p/rs[@type="ethnicity"]) return <ethnicity>{$a}</ethnicity>}
{for $a in distinct-values($p/rs[@type="genre"]) return <genre>{$a}</genre>}
{for $a in distinct-values($p/rs[@type="geography"]) return <geography>{$a}</geography>}
{for $a in distinct-values($p/date) return <period>{$a}</period>}
</profile>';


switch($field) {
  case "title":
	$browse_qry = 'for $a in //titleStmt/title' . $ancfilter . '
	let $doc := substring-before(util:document-name($a), ".xml")
	return <item>{$a}<id>{$doc}</id></item>'; break;
  case "genre":
  case "ethnicity":
  case "geography":
	$browse_qry = "for \$a in //titleStmt/title[ancestor::TEI.2//rs[@type='$field' and .='$value'
	" . ($collection ? "and $rsfilter" : "") . "]]
	let \$doc := substring-before(util:document-name(\$a), '.xml')
  	let \$auth := \$a/../author
	  let \$date := root(\$a)//sourceDesc/bibl/date
	    return <item>{\$a}<id>{\$doc}</id>{\$auth}{\$date}<$field>$value</$field></item>"; break;
  case "period":
	$browse_qry = "for \$a in //titleStmt/title[ancestor::TEI.2//rs[../date='$value'
	" . ($collection ? "and $rsfilter" : "") . "]]
	let \$doc := substring-before(util:document-name(\$a), '.xml')
  	let \$auth := \$a/../author
	  let \$date := root(\$a)//sourceDesc/bibl/date
	    return <item>{\$a}<id>{\$doc}</id>{\$auth}{\$date}<period>$value</period></item>"; break;
  case "publisher":
	$browse_qry = 'for $a in distinct-values(//sourceDesc/bibl/publisher' . $ancfilter . ')
	return <item><publisher>{$a}</publisher></item>'; break;
  case "subject":
	$browse_qry = 'for $a in distinct-values(//keywords/list/item' . $ancfilter . ')
	return <item><subject>{$a}</subject></item>'; break;
  case "author":
  default: // list of distinct authors
    //	$browse_qry = 'for $a in distinct-values(//titleStmt/author/@n) 
	$browse_qry = 'for $a in distinct-values(//titleStmt/author' . $ancfilter . '/name/@reg) 
		  let $auth := //titleStmt/author/name[@reg=$a]
		  return <item><author reg="{$a}">{$auth}</author></item>';

}


$query = "<result>{ $profile_qry } { $browse_qry } </result>";

$xsl = "$baseurl/stylesheets/browse.xsl";


?>
<html>
 <head>
    <title><?= $title ?></title>
    <link rel="stylesheet" type="text/css" href="ewwrp.css">
    <link rel="shortcut icon" href="ewwrp.ico" type="image/x-icon">
</head>
<body>

<? include("header.php") ?>
<? include("nav.php") ?>

<div class="content">

<div class="title"><a href="/"><?=$title?></a></div>

<? 
$db->xquery($profile_qry);
$db->xslTransform($xsl);
$db->printResult();

// do the queries separately so that exist will handle the counting & paging for us 
$db->xquery($browse_qry);
$db->xslTransform($xsl);
$db->printResult();

?>


</div>	

</body></html>