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

// publishers must be enclosed in "" to pass &; remove quotes & convert ampersand for xquery
$value = preg_replace('/^\\\\"(.*)\\\\"$/', '$1', $value);
$value = preg_replace('/&/', '&amp;', $value);

$pos = $_GET["position"];
$max = $_GET["max"];

if ($pos == '') $pos = 1;
if ($max == '') $max = 20;

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

// sort titles, ignoring leading The, A, An, and '
$titlesort ='let $sort_title :=
  (if (starts-with($a, "The ")) then substring-after($a, "The ")
   else if (starts-with($a, "THE ")) then substring-after($a, "THE ")
   else if (starts-with($a, "A ")) then substring-after($a, "A ")
   else if (starts-with($a, "An ")) then substring-after($a, "An ")
   else if (starts-with($a, "\'")) then substring-after($a, "\'")
   else string($a))
   order by $sort_title';

if ($value) {		// there is a value for search field is defined

  switch($field) {
  case "genre":
  case "ethnicity":
  case "geography":
    //list of titles filtered on genre, ethnicity, or geography
    $browse_qry = "for \$a in //titleStmt/title[ancestor::TEI.2//rs[@type='$field' and .='$value'
	" . ($collection ? "and $rsfilter" : "") . "]]
	let \$doc := substring-before(util:document-name(\$a), '.xml')
  	let \$auth := \$a/../author
	let \$date := root(\$a)//sourceDesc/bibl/date
	$titlesort
	return <item>{\$a}<id>{\$doc}</id>{\$auth}{\$date}<$field>$value</$field></item>"; break;
  case "period":
    // list of titles, filtered on period
    $browse_qry = "for \$a in //titleStmt/title[ancestor::TEI.2//rs[../date='$value'
	" . ($collection ? "and $rsfilter" : "") . "]]
	let \$doc := substring-before(util:document-name(\$a), '.xml')
  	let \$auth := \$a/../author
	let \$date := root(\$a)//sourceDesc/bibl/date
	$titlesort
	return <item>{\$a}<id>{\$doc}</id>{\$auth}{\$date}<period>$value</period></item>"; break;
  case "publisher":
    // list of titles by publisher
    $browse_qry = "for \$a in //titleStmt/title[ancestor::TEI.2//sourceDesc/bibl/publisher='$value']
	" . ($collection ? "$ancfilter" : "") . "
	let \$doc := substring-before(util:document-name(\$a), '.xml')
	let \$root := root(\$a)
  	let \$auth := \$a/../author
	let \$date := \$root//sourceDesc/bibl/date
	let \$pub := \$root//sourceDesc/bibl/publisher
	$titlesort
	return <item>{\$a}<id>{\$doc}</id>{\$auth}{\$date}<publisher>{\$pub}</publisher></item>"; break;
  case "subject":
    //list of titles by subject headings
    $browse_qry = "for \$a in //titleStmt/title[ancestor::TEI.2//keywords/list/item='$value']
	" . ($collection ? "$ancfilter" : "") . "
	let \$doc := substring-before(util:document-name(\$a), '.xml')
	let \$root := root(\$a)
  	let \$auth := \$a/../author
	let \$date := \$root//sourceDesc/bibl/date
	$titlesort
	return <item>{\$a}<id>{\$doc}</id>{\$auth}{\$date}
	{for \$s in \$root//keywords/list/item return <subject>{xs:string(\$s)}</subject>}
	</item>"; break;
  case "author":
    // list of titles by author
    $browse_qry = "for \$a in //titleStmt[author/name='$value' or author/name/@reg='$value']/title
	" . ($collection ? "$ancfilter" : "") . "
	let \$doc := substring-before(util:document-name(\$a), '.xml')
	let \$root := root(\$a)
  	let \$auth := \$a/../author
	let \$date := \$root//sourceDesc/bibl/date
	$titlesort
	return <item>{\$a}<id>{\$doc}</id>{\$auth}{\$date}</item>"; break;
    $browse_qry = 'for $a in distinct-values(//titleStmt/author' . $ancfilter . '/name/@reg)
	let $auth := //titleStmt/author/name[@reg=$a]
	order by $a
	return <item><author reg="{$a}">
		{for $n in distinct-values($auth) return <name>{$n}</name>}
	       </author></item>';
    
  }
 } else {	// no value defined, field only (lists of authors, titles, publishers, subjects)

    switch($field) {
  case "title":
    // list of titles
    $browse_qry = "for \$a in //titleStmt/title$ancfilter
	let \$doc := substring-before(util:document-name(\$a), '.xml')
	$titlesort
	return <item>{\$a}<id>{\$doc}</id></item>"; break;
  case "publisher":
    // list of distinct source publishers
    $browse_qry = 'for $a in distinct-values(//sourceDesc/bibl/publisher' . $ancfilter . ')
	let $sortpub := concat(substring-after($a, "The "), $a)
	order by $sortpub
	return <item><publisher>{$a}</publisher></item>'; break;
  case "subject":
    //list of distinct subject headings
    $browse_qry = 'for $a in distinct-values(//keywords/list/item' . $ancfilter . ')
	order by $a
	return <item><subject>{$a}</subject></item>'; break;
  case "author":
  default:
    // list of distinct authors
    $browse_qry = 'for $a in distinct-values(//titleStmt/author' . $ancfilter . '/name/@reg)
	let $auth := //titleStmt/author/name[@reg=$a]
	order by $a
	return <item><author reg="{$a}">
		{for $n in distinct-values($auth) return <name>{$n}</name>}
	       </author></item>';
    
  }

}
    


$query = "<result>{ $profile_qry } { $browse_qry } </result>";

$xsl = "$baseurl/stylesheets/browse.xsl";
$xsl_params = array('field' => $field, 'value' => $value, 'max' => $max);

?>
<html>
 <head>
<title><?= $title ?> : Browse <?= $field?></title>
    <link rel="stylesheet" type="text/css" href="ewwrp.css">
    <link rel="shortcut icon" href="ewwrp.ico" type="image/x-icon">
</head>
<body>

<? include("header.php") ?>
<? include("nav.php") ?>

<div class="content">

<div class="title"><a href="index.php"><?= $title ?></a></div>

<? 
$db->xquery($profile_qry);
$db->xslTransform($xsl);
$db->printResult();

// do the queries separately so that exist will handle the counting & paging for us 
$db->xquery($browse_qry, $pos, $max);
$db->xslTransform($xsl, $xsl_params);
$db->printResult();

?>


</div>	

</body></html>