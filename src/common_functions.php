<?php

function validate_link () {
  print "<div id='validate'>
  <a href='http://validator.w3.org/check?uri=http://". $_SERVER['SERVER_NAME']  . $_SERVER['PHP_SELF'] . "?" . $_SERVER['QUERY_STRING'] . "'>
  validate html</a>
</div>";
}


?>