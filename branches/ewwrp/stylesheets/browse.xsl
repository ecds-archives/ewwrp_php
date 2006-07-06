<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exist="http://exist.sourceforge.net/NS/exist"
  version="1.0">

  <xsl:output method="xml"/>

  <xsl:variable name="nl"><xsl:text> 
</xsl:text></xsl:variable>


  <xsl:template match="/">
    <xsl:apply-templates select="//profile"/>
    <xsl:call-template name="itemlist"/>
  </xsl:template>

  <xsl:template match="profile">
    <div class="browse">
      <h1>Select a browse category:</h1>
      <ul>
        <li><a href="browse.php?field=title">All Titles</a></li>
        <li>Ethnicity: <xsl:apply-templates select="ethnicity"/></li>
        <li>Genre: <xsl:apply-templates select="genre"/></li>
        <li>Geography: <xsl:apply-templates select="geography"/></li>
        <li>Period: <xsl:apply-templates select="period"/></li>
        <li><a href="browse.php?field=publisher">Source Publisher List</a></li>
        <li><a href="browse.php?field=author">Author List</a></li>
        <li><a href="browse.php?field=subject">Subject List</a></li>
      </ul>
    </div>
  </xsl:template>

  <xsl:template match="profile/ethnicity|profile/genre|profile/geography|profile/period">
    <a>
      <xsl:attribute name="href">browse.php?field=<xsl:value-of select="name()"/>&amp;value=<xsl:value-of select="."/></xsl:attribute>
      <xsl:value-of select="."/>
    </a>
    <xsl:if test="position() != last()">
      <xsl:text> | </xsl:text>
    </xsl:if>
  </xsl:template>


  <xsl:template name="itemlist">
    <xsl:if test="count(//item) > 0">

    <xsl:call-template name="total-jumplist"/>
    
      <table class="browse">
        <thead style="font-size:small;">
        <tr>
          <th class="num">#</th>
          <xsl:if test="//item/title"><th >title</th></xsl:if>
          <xsl:if test="//item/author"><th>author</th></xsl:if>
          <xsl:if test="//item/date"><th>date</th></xsl:if>
          <xsl:if test="//item/ethnicity"><th>ethnicity</th></xsl:if>
          <xsl:if test="//item/genre"><th>genre</th></xsl:if>
          <xsl:if test="//item/geography"><th>geography</th></xsl:if>
          <xsl:if test="//item/period"><th>period</th></xsl:if>
          <xsl:if test="//item/publisher"><th>source publisher</th></xsl:if>
          <!--          <xsl:if test="//item/??"><th>collection</th></xsl:if> -->
	<xsl:if test="//item/subject"><th>subject</th></xsl:if>
      </tr>
    </thead>
    <tbody align="left" valign="top" style="font-size:small;">
      <xsl:apply-templates select="//item"/>
    </tbody>
  </table>
</xsl:if>
  
  </xsl:template>

  <xsl:template match="item">
    <tr>
      <td><xsl:value-of select="position()"/>.</td>
      <xsl:value-of select="$nl"/>
      <xsl:apply-templates mode="table"/>
    </tr>
    <xsl:value-of select="$nl"/>
  </xsl:template>

  <!-- FIXME: multiple authors for a single text should still be in the same table cell -->
  <xsl:template match="item/*" mode="table">
    <xsl:if test="name() != 'id'">
      <td><xsl:apply-templates select="."/></td>
      <xsl:value-of select="$nl"/>
    </xsl:if>
  </xsl:template>

<!-- browse list of unique authors
  authoritative author name (title page name[, other title page name(s)]) --> 
<xsl:template match="author">
  <xsl:value-of select="@reg"/> <!-- canonical version of author name -->
  (<xsl:value-of select="."/>) <!-- title page version(s) of author name -->
  <!-- should link to search by author; make sure multiple versions of name works okay -->
</xsl:template>


<xsl:template match="title">
  <a>
    <xsl:attribute name="href">content.php?doc=<xsl:value-of select="../id"/></xsl:attribute>
    <xsl:apply-templates/>
  </a>
</xsl:template>

<!-- do nothing with id itself -->
<xsl:template match="id"/>

<xsl:template name="total-jumplist">

  <xsl:variable name="total">
    <xsl:value-of select="//@exist:hits"/>        
  </xsl:variable>

  <!-- only display total & jump list if there are actually results -->
  <xsl:if test="$total > 0">

    <!--    <xsl:variable name="chunksize"><xsl:value-of select="($end - $start + 1)"/></xsl:variable> -->

    <!-- only display jump list if there are more results than displayed here. -->
    <!--    <xsl:if test="$total > $chunksize">
      <script language="Javascript" type="text/javascript" src="scripts/jumpnav.js"/>
      <script language="Javascript" type="text/javascript">
        jumpnavform("search-metadata", 
        <xsl:value-of select="$chunksize"/>, 
        <xsl:value-of select="$total"/>, 
        <xsl:value-of select="$start"/>, 
        "srchfield", "<xsl:value-of select="$srchfield"/>", 
        "content", "<xsl:value-of select="$content"/>");
      </script>
    </xsl:if> -->

    <xsl:element name="p">
      <xsl:value-of select="$total"/> match<xsl:if test="$total != 1">es</xsl:if> found
    </xsl:element>
  </xsl:if> 
</xsl:template>


</xsl:stylesheet>
