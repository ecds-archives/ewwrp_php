<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exist="http://exist.sourceforge.net/NS/exist"
  version="1.0">

  <xsl:output method="xml"/>

  <!-- search terms -->
  <xsl:param name="field"/>
  <xsl:param name="value"/>

  <!-- information about current set of results  -->
  <xsl:variable name="position"><xsl:value-of select="//@exist:start"/></xsl:variable>
  <xsl:param name="max"/>
  <xsl:variable name="total"><xsl:value-of select="//@exist:hits"/></xsl:variable>

  <xsl:include href="utils.xsl"/>
  <xsl:include href="common.xsl"/>

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
    <tr>	<!-- calculate item's position in total result set -->
      <td><xsl:value-of select="position() + $position - 1"/>.</td>
      <xsl:value-of select="$nl"/>
      <xsl:apply-templates mode="table"/>
    </tr>
    <xsl:value-of select="$nl"/>
  </xsl:template>

  <xsl:template match="item/*" mode="table">
    <xsl:if test="name() != 'id'">
      <td><xsl:apply-templates select="."/></td>
      <xsl:value-of select="$nl"/>
    </xsl:if>
  </xsl:template>

  <!-- display multiple authors for a single text in one table cell -->
  <xsl:template match="item/author" mode="table">
    <xsl:if test="count(preceding-sibling::author) = 0">
      <td><xsl:apply-templates select="."/>
      <xsl:apply-templates select="following-sibling::author" mode="addauth"/>
      </td>
      <xsl:value-of select="$nl"/>
    </xsl:if>
  </xsl:template>

  <!-- additional author in table display: add a line break and display normally -->
  <xsl:template match="item/author" mode="addauth">
    <br/><xsl:apply-templates select="."/>
  </xsl:template>



<!-- display multiple subjects for a single text in one table cell -->
<xsl:template match="item/subject" mode="table">
  <xsl:if test="count(preceding-sibling::subject) = 0">
    <td>
      <xsl:apply-templates select="."/>
      <xsl:apply-templates select="following-sibling::subject" mode="addsubj"/>
    </td>
    <xsl:value-of select="$nl"/>
  </xsl:if>
</xsl:template>

  <!-- additional author in table display: add a line break and display normally -->
  <xsl:template match="item/subject" mode="addsubj">
    <br/><xsl:apply-templates select="."/>
  </xsl:template>


<xsl:template match="title">
  <a>
    <xsl:attribute name="href">toc.php?id=<xsl:value-of select="../id"/></xsl:attribute>
    <b><xsl:apply-templates/></b>
  </a>
</xsl:template>

<!-- browse list of unique authors: reg is attached to author, may include multiple names
  authoritative author name (title page name, other title page name(s)) --> 
<xsl:template match="author">
  <!-- canonical/regularized version of author name -->
  <xsl:variable name="reg">   	<!-- reg is in either one of these two places -->
    <xsl:value-of select="@reg"/>  
    <xsl:value-of select="name/@reg"/>
  </xsl:variable>
  <a>
    <xsl:attribute name="href">browse.php?field=author&amp;value=<xsl:value-of select="normalize-space($reg)"/></xsl:attribute>
    <xsl:value-of select="$reg"/>
  </a>
  <xsl:if test="$reg != name">	<!-- (only display if different) -->
    [<xsl:apply-templates select="name"/>] <!-- title page version(s) of author name -->
  </xsl:if>
</xsl:template>

<!-- possibly multiple names in authorlist mode -->
<xsl:template match="author/name">
  <a>
    <xsl:attribute name="href">browse.php?field=author&amp;value=<xsl:value-of select="normalize-space(.)"/></xsl:attribute>
    <xsl:apply-templates/>
  </a>
  <xsl:if test="position() != last()">
    <xsl:text>, </xsl:text>
  </xsl:if>
</xsl:template>


<!-- do nothing with id itself --> <xsl:template match="id"/>

<xsl:template name="total-jumplist">


  <!-- only display total & jump list if there are actually results -->
  <xsl:if test="$total > 0">

    <xsl:variable name="url">browse.php?field=<xsl:value-of select="$field"/><xsl:if test="$value">&amp;value=<xsl:value-of select="$value"/></xsl:if></xsl:variable>

    <div class="searchnav">
      <!-- first & prev -->
      <xsl:choose>
        <xsl:when test="$position != 1">
          <a>
            <xsl:attribute name="href"><xsl:value-of 
            select="concat($url, '&amp;position=1&amp;max=', $max)"/></xsl:attribute>
            &lt;&lt;First
          </a>          

          <!-- FIXME: correct the math here: start position shouldn't go below 1 -->
          <a>
            <xsl:attribute name="href"><xsl:value-of 
            select="concat($url, '&amp;position=', ($position - $max), '&amp;max=', $max)"/></xsl:attribute>
            &lt;Previous
          </a>          
        </xsl:when>
        <xsl:otherwise>
          <a> </a>	<!-- first -->
          <a> </a>	<!-- prev  -->
        </xsl:otherwise>
      </xsl:choose>

      <!-- next -->
      <xsl:choose>
        <xsl:when test="$max &lt; $total">
          <a>
            <xsl:attribute name="href"><xsl:value-of 
            select="concat($url, '&amp;position=', ($position + $max), '&amp;max=', $max)"/></xsl:attribute>
            Next&gt;
          </a>          

          <a>
            <xsl:attribute name="href"><xsl:value-of 
            select="concat($url, '&amp;position=', ($total - $max), '&amp;max=', $max)"/></xsl:attribute>
	     Last&gt;&gt;
          </a>          

        </xsl:when>


      </xsl:choose>

    </div>


  <xsl:variable name="chunksize"><xsl:value-of select="$max"/></xsl:variable>  
    <!-- only display jump list if there are more results than displayed here. -->
    <xsl:if test="$total > $chunksize">
      <form id="jumpnav" name="jumpnav" action="browse.php">
        <input name="field" type="hidden">
          <xsl:attribute name="value"><xsl:value-of select="$field"/></xsl:attribute>
        </input>
        <input name="value" type="hidden">
          <xsl:attribute name="value"><xsl:value-of select="$value"/></xsl:attribute>
        </input>

        <input name="max" type="hidden">
          <xsl:attribute name="value"><xsl:value-of select="$max"/></xsl:attribute>
        </input>
        <select name="position" onchange="submit();">
          <xsl:call-template name="jumpnav-option"/>
        </select>
      </form>
    </xsl:if> 

    <xsl:element name="p">
      <xsl:value-of select="$total"/> match<xsl:if test="$total != 1">es</xsl:if> found
    </xsl:element>
  </xsl:if> 
</xsl:template>

<xsl:template name="jumpnav-option">
  <!-- position, max, and total are global -->
  <xsl:param name="curpos">1</xsl:param>	<!-- start at 1 -->
  
  <xsl:variable name="curmax">    
    <xsl:call-template name="min">
      <xsl:with-param name="num1">
        <xsl:value-of select="$curpos + $max - 1"/>
      </xsl:with-param>
      <xsl:with-param name="num2">
        <xsl:value-of select="$total"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:variable>

  <option> 
    <xsl:attribute name="value"><xsl:value-of select="$curpos"/></xsl:attribute>
    <xsl:if test="$curpos = $position">
      <xsl:attribute name="selected">selected</xsl:attribute>
    </xsl:if>
    <xsl:value-of select="$curpos"/> - <xsl:value-of select="$curmax"/>
  </option>

  <!-- if the end of this section is less than the total, recurse -->
  <xsl:if test="$total > $curmax">
    <xsl:call-template name="jumpnav-option">
      <xsl:with-param name="curpos">
        <xsl:value-of select="$curpos + $max"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
