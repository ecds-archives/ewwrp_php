<form action="search.php" method="GET">
<table class="searchform" border="0">
<tr><th>Keyword</th>
  <td class="input">
    <input type="text" size="40" name="keyword" value="<?php print $kw ?>">
   </td></tr>
<tr><th>Title</th>
  <td class="input">
    <input type="text" size="40" name="doctitle" value="<?php print $doctitle ?>">
  </td></tr>
<tr><th>Author</th>
   <td class="input">
      <input type="text" size="40" name="author" value="<?php print $author ?>">
   </td></tr>
<tr><th>Date</th>
   <td class="input">
     <input type="text" size="40" name="date" value="<?php print $date ?>">
   </td></tr>
<tr><th>Subject</th>
   <td class="input">
     <input type="text" size="40" name="subject" value="<?php print $subj ?>">
    </td></tr>
<tr><td colspan="2">

  <input onmouseover='src="<?= $baseurl ?>images/search-on.jpg"' onmouseout='src="<?= $baseurl ?>images/search-off.jpg"' src="<?= $baseurl ?>images/search-off.jpg" name="searchbutton" alt="search" type="image">
<!-- 
  <input type="submit" value="Submit"> <input type="reset" value="Reset"> -->
  </td></tr>
</table>
</form>

<div class="tips">
  <h2>Search tips</h2>
  <ul>
    <li>Multiple words: "bicycle wheel" finds only those documents that contains both words.</li>
    <li>Wild cards: "marri*" matches married, marriage, etc.</li>
    <li>Character case is ignored</li>
  </ul>
</div>

