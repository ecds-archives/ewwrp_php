<?php
include_once("config.php");
include_once("lib/xmlDbConnection.class.php");

$connectionArray{"debug"} = false;

$db = new xmlDbConnection($connectionArray);

global $title;
global $collname;
global $collection;

//$baseurl = "http://biliku.library.emory.edu/rebecca/ewwrp/";	

$kw = $_REQUEST["keyword"];
$doctitle = $_REQUEST["doctitle"];
$auth = $_REQUEST["author"];
$date = $_REQUEST["date"];
$subj = $_REQUEST["subject"];
$searchcoll = $_GET["coll"];	// limit to certain/multiple collections (array)
// need a filter if we are in a collection

$pos = $_REQUEST["position"];
$max = $_REQUEST["max"];

if ($pos == '') $pos = 1;
if ($max == '') $max = 20;

if ($title == '') {
  $title = "Emory Women Writers Resource Project";
  $collname = "EWWRP";
 }


// if we are in a collection, add EWWRP to the beginning of the html title
if ($collname != "EWWRP") 
  $htmltitle = "EWWRP : $title";
else
   $htmltitle = $title;


// filter if a collection is defined
if ($collection) {
  $rsfilter = "[teiHeader/profileDesc/creation/rs[@type='collection' and .='$collection']]";
} else if (isset($searchcoll) && $searchcoll[0] != 'ALL') {
  $rsfilter = "[teiHeader/profileDesc/creation/rs[@type='collection' and
	(.='" . implode("' or .='", $searchcoll) . "')]]";
}

$options = array();
if ($kw) 
  array_push($options, ". &='$kw'");
if ($doctitle)
  array_push($options, ".//titleStmt/title &= '$doctitle'");
if ($auth)
  array_push($options, "(.//titleStmt/author/name &= '$auth' or .//titleStmt/author/name/@reg &= '$auth')");
if ($date)
  array_push($options, ".//sourceDesc/bibl/date &= '$date'");
if ($subj)
  array_push($options, ".//keywords/list/item &= '$subj'");

// there must be at least one search parameter for this to work
if (count($options)) {

  $searchfilter = "[" . implode(" and ", $options) . "]"; 
  
  
  $query = "for \$a in /TEI.2${rsfilter}$searchfilter
let \$t := \$a//titleStmt/title
let \$doc := substring-before(util:document-name(\$a), '.xml')
let \$auth := \$a//titleStmt/author
let \$date := root(\$a)//sourceDesc/bibl/date
let \$matchcount := text:match-count(\$a)
order by \$matchcount descending
return <item>{\$a/@id}";
  if ($kw)	// only count matches for keyword searches
    $query .= "<hits>{\$matchcount}</hits>";
  $query .= "
  {\$t}
  <id>{\$doc}</id>
  {\$auth}
  {\$date}";
  if ($subj)	// return subjects if included in search 
    $query .= "{for \$s in \$a//keywords/list/item return <subject>{string(\$s)}</subject>}";
  if (count($searchcoll) > 1)	// if more than one collection is specified
    $query .= "{for \$coll in \$a//creation/rs[@type='collection']
	order by \$coll
	return <collection>{string(\$coll)}</collection>}";
  $query .= "</item>";

  $xsl = "$baseurl/stylesheets/browse.xsl";
  //$xsl_params = array('field' => $field, 'value' => $value, 'max' => $max);
  $xsl_params = array('mode' => "search", 'keyword' => $kw, 'max' => $max);
}

?>
<html>
 <head>
<title><?= $htmltitle ?> : Search Results</title>
    <link rel="stylesheet" type="text/css" href="ewwrp.css">
    <link rel="shortcut icon" href="ewwrp.ico" type="image/x-icon">
</head>
<body>

<? include("header.php") ?>
<? include("nav.php") ?>

<div class="content">

<div class="title"><a href="index.php"><?= $title ?></a></div>

<?

// only execute the query if there are search terms
if (count($options)) {

$db->xquery($query, $pos, $max);


  print "<p><b>Search results for texts where:</b></p>
 <ul class='searchopts'>";
  if ($kw) 
    print "<li>document contains keywords '$kw'</li>";
  if ($doctitle)
    print "<li>title matches '$doctitle'</li>";
  if ($auth)
    print "<li>author matches '$auth'</li>";
  if ($date)
    print "<li>date matches '$date'</li>";
  if ($subj)
    print "<li>subject matches '$subj'</li>";
  if (isset($searchcoll) && $searchcoll[0] != "ALL")
    print "<li>collection is '" . stripslashes(implode($searchcoll, "' or '")) . "'</li>";
  
  
  print "</ul>";
  
  if ($db->count == 0) {
    print "<p><b>No matches found.</b>
You may want to broaden your search or consult the search tips for suggestions.</p>\n";
    include("searchform.php");
  }
  
  $db->xslTransform($xsl, $xsl_params);
  $db->printResult();
  
} else {
  // no search terms - handle gracefully  
  print "<p><b>Error!</b> No search terms specified.</p>";
}

?>


</div>	

</body></html>

  
