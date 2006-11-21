<?php
include_once("config.php");
include_once("common_functions.php");
include_once("lib/xmlDbConnection.class.php");

$connectionArray{"debug"} = false;

$db = new xmlDbConnection($connectionArray);

global $title;
global $collname;
global $collection;

if ($title == '') {
  $title = "Emory Women Writers Resource Project";
  $collname = "EWWRP";
 }

// if we are in a collection, add EWWRP to the beginning of the html title
if ($collname != "EWWRP") 
  $htmltitle = "EWWRP : $title";
else
   $htmltitle = $title;


//$baseurl = "http://biliku.library.emory.edu/rebecca/ewwrp/";	

$field = $_GET["field"];
$value = $_GET["value"];
$letter = $_GET["letter"];
if (!($field)) $field = "author";	// default list

// publishers must be enclosed in "" to pass &; remove quotes & convert ampersand for xquery
$value = preg_replace('/^\"(.*)\"$/', '$1', stripslashes($value));	// remove slashes to simplify removing quotes
$value = preg_replace('/&/', '&amp;', $value);
$value = addslashes($value);	// add slashes back in so searches with ' will work

$pos = $_GET["position"];
$max = $_GET["max"];

if ($pos == '') $pos = 1;
if ($max == '') $max = 20;


// filter format for profile information *only* if a collection is defined
if ($collection) {
  $rsfilter = "@type='collection' and .='$collection'";
  $filter = "[rs[$rsfilter]]";				// version of filter relative to profileDesc
  $ancfilter = "[ancestor::TEI.2//rs[$rsfilter]]";	// version of filter needed for titles/authors/etc
}
  
// retrieve browse fields
$profile_qry = 'let $p := //profileDesc/creation' . $filter . '
return <profile>
{ for $a in distinct-values($p/rs[@type="ethnicity"]) order by $a return <ethnicity>{$a}</ethnicity>}
{for $a in distinct-values($p/rs[@type="genre"]) order by $a return <genre>{$a}</genre>}
{for $a in distinct-values($p/rs[@type="geography"]) order by $a return <geography>{$a}</geography>}
{for $a in distinct-values($p/date) order by $a return <period>{$a}</period>}
{for $a in distinct-values($p/rs[@type="form"]) order by $a return <form>{$a}</form>}
</profile>';

// sort version of title; ignores leading The, A, An, and '
$sort_title ='let $sort_title :=
  (if (starts-with($a, "The ")) then substring-after($a, "The ")
   else if (starts-with($a, "THE ")) then substring-after($a, "THE ")
   else if (starts-with($a, "A ")) then substring-after($a, "A ")
   else if (starts-with($a, "An ")) then substring-after($a, "An ")
   else if (starts-with($a, "\'")) then substring-after($a, "\'")
   else string($a))';
$titlesort = $sort_title . " order by \$sort_title";

$sort_pub = 'let $sort_pub :=
   (if (starts-with($a, "The ")) then substring-after($a, "The ")
    else if (starts-with($a, "[")) then substring-after($a, "[")
    else string($a))';

// browse by letter : filter on first letter of search field
if ($letter) {
  $lfilter = "where starts-with(\$a, '$letter')";
  $title_lfilter = "where starts-with(\$sort_title, '$letter')";
  $pub_lfilter = "where starts-with(\$sort_pub, '$letter')";
 }


if ($value) {
  // search for titles based on specified value in specified search field 
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
  }
 } else {	// no value defined, field only (lists of authors, titles, publishers, subjects)

    switch($field) {
  case "title":
    // list of titles
    $browse_qry = "for \$a in //titleStmt/title$ancfilter
	let \$doc := substring-before(util:document-name(\$a), '.xml')
	$sort_title
	$title_lfilter
	order by \$sort_title
	return <item>{\$a}<id>{\$doc}</id></item>";
        $alpha_qry = '<alphalist> {
		  for $l in distinct-values(
		  	for $a in //titleStmt/title' . $ancfilter . '
			' . $sort_title . '
		  	return substring($sort_title,1,1) )
		  order by $l
		  return <letter>{$l}</letter> } </alphalist>';
	break;

    case "criticaledition":
    //list of critical edition titles (filtered on form=Edited)
    $browse_qry = "for \$a in //titleStmt/title[ancestor::TEI.2//rs[@type='form' and .='Edited'
	" . ($collection ? "and $rsfilter" : "") . "]]
	let \$doc := substring-before(util:document-name(\$a), '.xml')
  	let \$auth := \$a/../author
	let \$ed := \$a/../respStmt/name
	let \$date := root(\$a)//sourceDesc/bibl/date
	$titlesort
	return <item>{\$a}<id>{\$doc}</id>{\$auth}{\$date}<editor>{\$ed}</editor></item>"; break;

  case "publisher":
    // list of distinct source publishers
    $browse_qry = 'for $a in distinct-values(//sourceDesc/bibl/publisher' . $ancfilter . ')
	' . $sort_pub . '
	' . $pub_lfilter . '
	order by $sort_pub
	return <item><publisher>{$a}</publisher></item>';
        $alpha_qry = '<alphalist> {
		  for $l in distinct-values(
		  	for $a in distinct-values(//sourceDesc/bibl/publisher' . $ancfilter . ')
			' . $sort_pub . '
		  	return substring($sort_pub,1,1) )
		  order by $l
		  return <letter>{$l}</letter> } </alphalist>';
    break;
  case "subject":
    //list of distinct subject headings
    $browse_qry = 'for $a in distinct-values(//keywords/list/item' . $ancfilter . ')
	' . $lfilter . '
	order by $a
	return <item><subject>{$a}</subject></item>';
    $alpha_qry = '<alphalist> {
		  for $l in distinct-values(
		  	for $a in distinct-values(//keywords/list/item' . $ancfilter . ')
		  	return substring($a,1,1) )
		  order by $l
		  return <letter>{$l}</letter> } </alphalist>';
    break;
    
  case "author":
  default:
    // list of distinct authors
    $browse_qry = 'for $a in distinct-values(//titleStmt/author' . $ancfilter . '/name/@reg)
	let $auth := //titleStmt/author/name[@reg=$a]
	' . $lfilter . '
	order by normalize-space($a) 
	return <item><author reg="{$a}">
		{for $n in distinct-values($auth) return <name>{$n}</name>}
	       </author></item>';
    $alpha_qry = '<alphalist> {
		  for $l in distinct-values(
		  	for $a in //titleStmt/author' . $ancfilter . '/name/@reg
		  	return substring($a,1,1) )
		  order by $l
		  return <letter>{$l}</letter> } </alphalist>';
  }

}
    


$query = "<result>{ $profile_qry } { $browse_qry } </result>";

$xsl = "$baseurl/stylesheets/browse.xsl";
$xsl_params = array('field' => $field, 'value' => $value, 'max' => $max, 'letter' => $letter);

?>
<html>
 <head>
<title><?= $htmltitle ?> : Browse <?= $field?></title>
    <link rel="stylesheet" type="text/css" href="ewwrp.css"/>
    <link rel="shortcut icon" href="ewwrp.ico" type="image/x-icon"/>
</head>
<body>

<?
include("header.php");
include("nav.php");
validate_link();
?>

<div class="content">

<div class="title"><a href="index.php"><?= $title ?></a></div>

<? 
$db->xquery($profile_qry);
$db->xslTransform($xsl);
$db->printResult();

// browse by first letter (if relevant in current mode)
if ($alpha_qry) {
  $db->xquery($alpha_qry, 1, 25);
  $db->xslTransform($xsl, $xsl_params);
  $db->printResult();
 }

// do the queries separately so that exist will handle the counting & paging for us 
$db->xquery($browse_qry, $pos, $max);
$db->xslTransform($xsl, $xsl_params);
$db->printResult();

?>


</div>	

</body></html>