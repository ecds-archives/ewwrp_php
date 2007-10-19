
<div class="leftcol <? if ($page != 'index') echo 'lcontent' ?>">

<?php

 /* Using a transparent png as a mask for ewwrp logo & controlling color
    for each collection with css.
    IE (before version 7) does not support transparent pngs;
    trap for MSIE versions less than 7 & use transparent gif with grayscale blending for mask.
 */

$info = array();
//$test = "Mozilla/4.0 (compatible; MSIE 6.0; MSN 2.5; Windows 98)";
$test = "Mozilla/4.0 (compatible; MSIE 7.0b; Windows NT 5.1)";
//preg_match("/(MSIE) (.)/", $test, $info);
preg_match("/(MSIE) (.)/", $_SERVER['HTTP_USER_AGENT'], $info);

if (($info[1] == "MSIE") && ($info[2] < 7)) {
  $imgtype = "gif";
} else {
  $imgtype = "png";
}

print "
<div class='brand'>
<!-- emory and EWWRP icons --> 
<div id='emorylogo'>
  <a id='emory' href='http://www.emory.edu/'>
<img  src='web/images/emory.png' alt='Emory University'/></a>
</div>
";

 
  //TESTING (alpha filter not working on IE on Jason's windows box; test elsewhere)...
// works on IE6/Windows (tested on Beck Ctr machine)
/*  if (($info[1] == "MSIE") && ($info[2] < 7)) {
  print "<div id='logo'>
<a id='ewwrp' href='$baseurl'><div id='iewwrp'></div></a>
</div>"; 
} 
else {*/
print "<div id=\"logo\">
<a id=\"ewwrp\" href=\"$baseurl\">
  <img src=\"web/images/ewwrp.$imgtype\" alt=\"Emory Women Writers Resource Project\"
  height=\"74\" width=\"56\"/></a>
</div>";
// }


/* <div id="logo">
<a id="ewwrp" href="<?= $baseurl ?>">
  <img src="<?= $baseurl ?>images/ewwrp.<?= $imgtype ?>" name="ewwrp" alt="Emory Women Writers Resource Project"
  border="0" height="74" width="56"></a>
</div> 
*/

?>
</div>

<div class="menu">
  <p id="m-browse">- <a href="browse.php">Browse</a> <?=$abbrev ?></p>

  <p id="m-search">- <a>Search</a> <?=$abbrev ?></p>

  
<form class="menu" action="search.php" method="get">
 <input name="keyword" size="20" value="" align="left" type="text"/>
    <input onmouseover='src="web/images/search-on.jpg"' onmouseout='src="web/images/search-off.jpg"' src="web/images/search-off.jpg" name="searchbutton" alt="search" type="image"/>
   <!-- to control search button with css and avoid search.x + search.y, use something like this -->
<!-- <a><input id="search" type="submit" value="Search" alt="search"></a> -->

  </form>
    
<div class="advsearch">
(<a href="advancedsearch.php">Advanced Search</a>)
</div>
            

<p id="m-essay">- <a href="essays.php">Essays</a></p>

<p id="m-about">- <a href="about.php">About</a> the Project</p>

</div>

<?php //if ($page != "index")  print "<hr class='menu'/>"; ?>

<?php
if ($abbrev == "Genre Fiction" && $page == "index")  {
//  print "<hr class='menu'/>";
  include("web/xml/description.xml");
}
?>


<div class="collections <? if ($abbrev != 'Genre Fiction') print $page ?>">
      <b><a class="ewwrp" href="<?= $baseurl ?>/">Emory Women Writers Resource Project</a> Collections:</b>
<ul>
 <li>- <a class="genrefiction" href="<?= $baseurl ?>genrefiction/">Genre Fiction</a></li>
 <li>- <a class="earlymodern" href="<?= $baseurl ?>earlymodern/">Early Modern through the 18th Century</a></li>
 <li>- <a class="twentieth" href="<?= $baseurl ?>twentiethcentury/">Early 20th Century Literature</a></li>
 <li>- <a class="worldwar1" href="<?= $baseurl ?>worldwarI/">World War I Poetry</a></li>
 <li>- <a class="nativeamerican" 	href="<?= $baseurl ?>nativeamerican/">Native
	American</a></li>
 <li>- <a class="abolition" href="<?= $baseurl ?>abolition/">Abolition, Freedom, and Rights</a></li>
 <li>- <a class="advocacy"	href="<?= $baseurl ?>advocacy/">Women's Advocacy</a></li>
</ul>

</div>

<?php
if ($abbrev != "Genre Fiction" && $page == "index")  {
//  print "<hr class='menu'/>";
  include("web/xml/description.xml");
}
?>

<? if ($page != "index") {
//  print "<hr class='menu'/>\n<div class='copyright'>";
  print "<div class='copyright'>";
  include("web/xml/funding.xml");
  print "<p>&copy;2005 Emory University<br/> Contact: <a
      href='mailto:beckctr@emory.edu'>The Beck Center</a></p>
</div>";
}
?>

</div>	<!-- end left column -->


