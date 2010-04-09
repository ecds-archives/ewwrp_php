<?php
$in_production = false;

error_reporting(E_ALL ^ E_NOTICE);

/*$baseurl = "http://wilson.library.emory.edu/~rsutton/ewwrp/";*/	
if ($in_production) {
  $server = "bohr.library.emory.edu";
  $baseurl = "http://womenwriters.library.emory.edu/";
 } else {
  $server = "kamina.library.emory.edu";
 $baseurl = "http://dev11.library.emory.edu/~ahickco/ewwrp/";
 }

$doctype = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">';

/* exist settings  */

if($in_production) {
  $port = "7080";
 } else {
  $port = "8080";
 }
$db = "ewwrp";

$connectionArray = array('host'   => $server,
	      	    'port'   => $port,
		    'db'     => $db,
		    'dbtype' => "exist");


// shortcut to include common tei xqueries
$teixq = 'import module namespace teixq="http://www.library.emory.edu/xquery/teixq" at
"xmldb:exist:///db/xquery-modules/tei.xqm"; '; 

?>