<div class="leftcol <? if ($page != 'index') echo 'lcontent' ?>">


<div class="brand">
<!-- emory and EWWRP icons -->
<div id="emorylogo">
  <a id="emory" href="http://www.emory.edu/">
<img  src="<?= $baseurl ?>images/emory.png" name="emory" alt="Emory University" border="0"></a>
</div>

<div id="logo">
<a id="ewwrp" href="<?= $baseurl ?>">
  <img src="<?= $baseurl ?>images/ewwrp.png" name="ewwrp" alt="Emory Women Writers Resource Project"
  border="0" height="74" width="56"></a>
</div>
</div>

<div class="menu">
  <p id="m-browse">- <a href="browse.php">Browse</a> <?=$collname ?></p>

  <p id="m-search">- <a>Search</a> <?=$collname ?></p>

  
<form class="menu" action="search.php" method="GET">
  <input name="keyword" size="20" value="" align="left" type="text">
  <input onmouseover='src="<?= $baseurl ?>images/search-on.jpg"' onmouseout='src="<?= $baseurl ?>images/search-off.jpg"' src="<?= $baseurl ?>images/search-off.jpg" name="searchbutton" alt="search" type="image">
  </form>
    
<div class="advsearch">
(<a href="http://womenwriters.library.emory.edu/genrefiction/frames?contentsrc=search-metadata-adv">Advanced Search</a>)
</div>
            

<p id="m-essay">- <a href="http://womenwriters.library.emory.edu/genrefiction/frames?contentsrc=doc-tgfwfw-essays">Essays</a></p>

<p id="m-about">- <a href="http://womenwriters.library.emory.edu/genrefiction/frames?contentsrc=doc-tgfwfw-about">About</a> the Project</p>

</div>

<? if ($page == "index")  include("description.xml") ?>
          
<hr class="menu">

<div class="collections">
      <b><? if ($collname != 'EWWRP') echo "Other "?>Emory Women Writers Resource Project Collections:</b>
<ul>
 <li>- <a id="genrefiction" href="<?= $baseurl ?>genrefiction/">Genre Fiction</a></li>
 <li>- <a id="earlymodern" href="http://chaucer.library.emory.edu/wwrp/">Early Modern</a></li>
 <li>- <a id="worldwar1" href="http://chaucer.library.emory.edu/wwrp/">World War I Poetry</a></li>
 <li>- <a id="nativeamerican" 	href="<?= $baseurl ?>nativeamerican/">Native
	American</a></li>
 <li>- <a id="africanamerican"	href="http://chaucer.library.emory.edu/wwrp/">African
	American</a></li>
 <li>- <a id="advocacy"	href="http://chaucer.library.emory.edu/wwrp/">Women's
	    Advocacy</a></li>
</ul>

</div>

<? if ($page != "index") {
  print "<hr class='menu'>\n<div class='copyright'>";
  include("funding.xml");
  print "<p>&copy;2005 Emory University<br> Contact: <a
      href='mailto:beckctr@emory.edu'>The Beck Center</a></p>
</div>";
}
?>

</div>	<!-- end left column -->
