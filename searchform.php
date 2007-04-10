<?php

//php ajax/scriptaculous
include("projax/projax.php");
$script = new Scriptaculous();



?>

<div id="searchform">

<form action="search.php" method="GET">
<table class="searchform" border="0">
<tr><th>Keyword</th>
  <td class="input">
    <input type="text" size="40" name="keyword" value="<?php print $kw ?>">
   </td></tr>
<tr><th>Title</th>
  <td class="input">
    <div class="autocomplete">
  <?php
if ($abbrev != 'EWWRP')
  $coll = urlencode($collection);
 else $coll = "";

  $ajaxopts = array("url" => "/~rsutton/ewwrp/suggestor.php",
		  "indicator" => "title-loading", "select" => "value",
		  "with" => "'coll=$coll&field=title&str='+document.getElementById('doctitle').value" );

$inputopts = array("size" => "40", "value" => $doctitle, "autocomplete" => "off");
print $script->text_field_with_auto_complete('doctitle', $inputopts, $ajaxopts);
?>
</div>
<td> <span id="title-loading" style="display:none;">Searching...</span>
</td>

<!--    <input type="text" size="40" name="doctitle" value="<?php print $doctitle ?>"> -->
  </td></tr>
<tr><th>Author</th>
   <td class="input">
  <div class="autocomplete">
  <?php
$ajaxopts{"indicator"} = "auth-loading";
$ajaxopts{"with"} = "'coll=$coll&field=author&str='+document.getElementById('author').value";

$inputopts = array("size" => "40", "value" => $author, "autocomplete" => "off");
print $script->text_field_with_auto_complete('author', $inputopts, $ajaxopts);

?>
</div>
<td> <span id="auth-loading" style="display:none;">Searching...</span>
</td>
<!--   
      <input type="text" size="40" name="author" value="<?php print $author ?>"> -->
   </td></tr>
<tr><th>Date</th>
   <td class="input">
     <input type="text" size="40" name="date" value="<?php print $date ?>">
   </td></tr>
<tr><th>Subject</th>
   <td class="input">
    <div class="autocomplete">
<?php
$ajaxopts{"indicator"} = "subj-loading";
$ajaxopts{"with"} = "'coll=$coll&field=subject&str='+document.getElementById('subject').value";
$inputopts{"value"} = $subj;
print $script->text_field_with_auto_complete('subject', $inputopts, $ajaxopts);
?>
<!--     <input type="text" size="04" name="subject" value="<?php print $subj ?>"> -->
  </div>
    </td>
  <td> <span id="subj-loading" style="display:none;">Searching...</span> </td>
</tr>
<?php
if ($abbrev == "EWWRP") {
  print '
<tr>
  <th>Collection(s)</th>
  <td class="input">
    <select multiple name="coll[]" size="8">
	<option value="ALL" selected="true">ALL</option>
	<option value="Genre Fiction">Genre Fiction</option>
	<option value="Early Modern through the 18th Century">Early Modern through the 18th Century</option>
	<option value="Early 20th Century Literature">Early 20th Century Literature</option>
	<option value="World War I">World War I</option>
	<option value="Native American">Native American</option>
	<option value="Abolition, Freedom, and Rights">Abolition, Freedom, and Rights</option>
	<option value="Women\'s Advocacy">Women\'s Advocacy</option>
    </select>
  </td></tr>
';
}
?>

<tr><td colspan="2">

  <input onmouseover='src="<?= $baseurl ?>images/search-on.jpg"' onmouseout='src="<?= $baseurl ?>images/search-off.jpg"' src="<?= $baseurl ?>images/search-off.jpg" name="searchbutton" alt="search" type="image">
<!-- 
  <input type="submit" value="Submit"> <input type="reset" value="Reset"> -->
  </td></tr>
</table>
</form>

</div>

<div class="tips">
  <h2>Search tips</h2>
  <ul>
    <li>Multiple words: "bicycle wheel" finds only those documents that contains both words.</li>
    <li>Wild cards: "marri*" matches married, marriage, etc.</li>
    <li>Character case is ignored.</li>
  </ul>
</div>

