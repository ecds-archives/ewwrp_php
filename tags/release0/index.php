<?php

global $title;
global $collname;
$baseurl = "http://biliku.library.emory.edu/rebecca/ewwrp/";	
$page = "index";

if ($title == '') {
  $title = "Emory Women Writers Resource Project";
  $collname = "EWWRP";
 }

?>
<html>
 <head>
    <title><?= $title ?></title>
    <link rel="stylesheet" type="text/css" href="ewwrp.css">
    <link rel="shortcut icon" href="ewwrp.ico" type="image/x-icon">
</head>
<body>


<? include("header.php") ?>

<div class="titlebar tbar-left"></div>
<div class="titlebar tbar-right"></div>
<div class="titlebar tbar-text">
<?= $title ?>
</div>


<? include("nav.php") ?>


<div class="rightcol">
<a
href="http://womenwriters.library.emory.edu/genrefiction/cti-tgfwfw-owheart_d75e1">
<img src="ewwrp_files/owheartfc.jpg" alt="Cover image of The Heart of
Hyacinth" height="550" width="380"></a> 
<!-- <img src="ewwrp_files/cover-02.jpg" alt="Cover image of The Heart of
Hyacinth" height="550" width="380"></a>  -->
 
 <div class="imageinfo imgtextbg"></div>
 <div class="imageinfo imgtext">
 1903: <i>The Heart of Hyacinth</i> - Onota Watanna, NY: Harper &amp;
	Brothers<br>
(a selection from the Women's Genre Fiction Collection)
 </div>



<div class="copyright">
<? include("funding.xml") ?>
<hr class="menu">
    &copy;2005 Emory University | Contact: <a href="mailto:beckctr@emory.edu">The Beck Center</a>
</div>

</div>		<!-- end right column -->

</body></html>