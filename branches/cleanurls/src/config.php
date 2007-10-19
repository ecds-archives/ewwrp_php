<?php

error_reporting(E_ALL ^ E_NOTICE);

$baseurl = "http://wilson.library.emory.edu/~rsutton/ewwrp/";	

$doctype = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">';

/* exist settings  */
$server = "wilson.library.emory.edu";
$port = "8080";
$db = "ewwrp";

$connectionArray = array('host'   => $server,
	      	    'port'   => $port,
		    'db'     => $db,
		    'dbtype' => "exist");


// shortcut to include common tei xqueries
$teixq = 'import module namespace teixq="http://www.library.emory.edu/xquery/teixq" at
"xmldb:exist:///db/xquery-modules/tei.xqm"; '; 

?>
