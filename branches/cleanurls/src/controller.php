<?php
  include("config.php");

  /* This script parses the url, sets key variables, and hands off to the appropriate script */

$url =  $_REQUEST{"url"};
$_url = $url;	// save original url as passed in
//print "url is $url<br>\n";

$includenav = true;

// in a subcollection?
// note: generate regexp here from list of collections?
if (preg_match("<^(genrefiction|twentiethcentury|abolition)/?(.*)$>", $url, $matches)) {
  $collection = $matches[1];
  $remainder = $matches[2];
  //  print "collection is $collection, remaining url is $remainder<br>\n";
} else {
  $collection = "ewwrp";
  $remainder = $url;
}

// general section of the site
if (preg_match("<^(browse|view|search|about|essays)/?(.*)$>", $remainder, $matches)) {
  $mode = $matches[1];
  $remainder = $matches[2];
  //  print "mode is $mode<br>\n";
}

if ($mode == "browse") {

  $includefile = "browse";
  // work backwards from the end of the url to find options for paging, filters

  // parameters for paging?
  if (preg_match("<^(.*)/([0-9]{1,3})-([0-9]{1,3})$>", $remainder, $matches)) {
    $remainder = $matches[1];
    $pos = $matches[2];
    $max = $matches[3];
  }

  // filter by first letter?
  if (preg_match("<^(.*)/([A-Z])$>", $remainder, $matches)) {
    $remainder = $matches[1];
    $letter = $matches[2];
  }

  // could have field or field/value
  if ($remainder != "") {
    $opts = split('/', $remainder);
    $field = $opts[0];
    if (isset($opts[1])) $value = $opts[1];
  }
  /*
   // debug: check that things were set properly
   foreach (array("field", "value", "letter", "position", "max") as $name) {
    if (isset($$name))
      print "$name = " . $$name . "<br>\n";
      }*/

  
 } elseif ($mode == "view") {
    $opts = split('/', $remainder);
    $docname = $opts[0];

    if (isset($opts[1])) {
      switch ($opts[1]) {
      case "teiheader":
	$includefile = "teiheader";
	$includenav = false;
	break;
      }
    } else {
      $includefile = "toc";
    }
   
 }


$htmltitle = "testing new ewwrp";
if ($includenav) {
  include("header.php");
  include("nav.php");
 }
?>
<div class="content">
  <? if ($includefile) include($includefile . ".php"); ?>

</div>

</body></html>
<?  
// idea - advanced search url = search/advanced  ?

  /*
#RewriteRule ^(genrefiction|twentiethcentury)?/?(about|essays|advancedsearch)$  	$2.php?collection=$1
#RewriteRule ^essays\/(.+)$  			content.php?level=div&id=$1

# browse - by field, with optional paging 
#RewriteRule ^browse/([^/]+)/?(([0-9]+){,3}-([0-9]+){,3})?$	browse.php?field=$1&position=$3&max=$4
 # note: limiting paging #s to 3 digits so time periods will be correctly recognized as field + value
 	## FIXME: adjust code so url will be 134-154, not 134-20 (start-end, not start-max)
# 	 - by field + first letter
#RewriteRule ^browse/([^/]+)/([A-Z])$			browse.php?field=$1&letter=$2 
# 	 - by field + value, with optional paging
#RewriteRule ^browse/([^/]+)/([^/]+)/?(([0-9]+)-([0-9]+))?$ browse.php?field=$1&value=$2&position=$4&max=$5


#RewriteRule ^view/([^/]+)	toc.php?id=$1



#RewriteRule ^learning/search   http://wilson.library.emory.edu/~rsutton/hdot/search.php [P,L,QSA]

#RewriteRule ^(denial|trial|struggle|learning)(.*) http://wilson.library.emory.edu/~rsutton/hdot/hdot.php?sec=$1&path=$2 [P,L,QSA]


  */

?>