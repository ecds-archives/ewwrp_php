<?= $doctype ?>
<html>
 <head>
    <title><?= $htmltitle ?></title>
    <base href="http://wilson.library.emory.edu/~rsutton/ewwrp-svn/src/"/>
    <link rel="stylesheet" type="text/css" href="web/css/<?= $collection ?>.css"/>
    <link rel="shortcut icon" href="web/favico/<?= $collection ?>.ico" type="image/x-icon"/>
</head>
<body>

<? if (isset($includenav) && $includenav) { ?>
<div class="header <? if ($page != 'index') echo 'hdr-content' ?>">
    <a id="first" href="http://chaucer.library.emory.edu/">Beck Center</a>
    <a href="http://english.emory.edu/">English Dept.</a>
    <a href="http://web.library.emory.edu/">University Libraries</a>
    <a href="http://www.emory.edu/">Emory University</a>
</div>
<? }  ?>

