<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

<xsl:include href="common.xsl"/>
<xsl:include href="footnotes.xsl"/>


<xsl:param name="mode"/>
<xsl:param name="running-header">off</xsl:param> 
  <!-- on/off : show or hide running header in page breaks -->

<!-- paths for images -->
<xsl:variable name="imgserver">http://bohr.library.emory.edu/ewwrp/images/tgfw/</xsl:variable>
<xsl:variable name="figure-prefix"><xsl:value-of select="$imgserver"/></xsl:variable>
<xsl:variable name="thumbs-prefix"><xsl:value-of select="$imgserver"/>thumbs/</xsl:variable>
<xsl:variable name="figure-suffix">.jpg</xsl:variable>

<xsl:variable name="newline"><xsl:text>
</xsl:text></xsl:variable>

  <xsl:output method="xml"/>

  <xsl:template match="/">
    <xsl:apply-templates select="//teiHeader"/>
    <div class="searchnav"><xsl:text> </xsl:text></div>
      
    <xsl:apply-templates select="//content"/>
  </xsl:template>

  <xsl:template match="relative-toc">
    <ul class="relative-toc">
      <xsl:apply-templates select="item[@name='TEI.2']"/>
    </ul>
  </xsl:template>



<!-- Ordered list causes problems with non-integer labels (e.g., 4.1)
     Making all lists unordered, but passing type as class.  -->
<xsl:template match="list">
  <ul>
  <!-- pass list type as a class, in case formatting is desired -->
   <xsl:if test="@type">
     <xsl:attribute name="class"><xsl:value-of select="@type"/></xsl:attribute>
   </xsl:if>
     <xsl:apply-templates/>
  </ul>
</xsl:template>

<xsl:template match="item">
    <li>
        <xsl:if test="@n">    
            <xsl:attribute name="value">
                <xsl:value-of select='@n'/>
            </xsl:attribute>
        </xsl:if>    
        <xsl:apply-templates/>
    </li>
</xsl:template>


<xsl:template match="div1/head|head">
   <h1>
        <xsl:apply-templates/>
   </h1>
</xsl:template>

<xsl:template match="div2/head">
    <h2>
        <xsl:apply-templates/>
    </h2>
</xsl:template>

<xsl:template match="div3/head">
    <h3>
        <xsl:apply-templates/>
    </h3>
</xsl:template>

<xsl:template match="div4/head">
    <h4>
        <xsl:apply-templates/>
    </h4>
</xsl:template>

<xsl:template match="div5/head">
    <h5>
        <xsl:apply-templates/>
    </h5>
</xsl:template>

<xsl:template match="p">
    <p>
      <xsl:apply-templates/> 
    </p>
    <xsl:value-of select="$newline"/>
</xsl:template>

<xsl:template match="quote|q">
  <div class="quote">
    <xsl:apply-templates/>
  </div>
</xsl:template>

<!-- handle quotes inside epigraphs differently  -->
<xsl:template match="epigraph//q">
  <xsl:apply-templates/>
</xsl:template>


<xsl:template match="lg">
  <p class="lg"><xsl:apply-templates/></p>
</xsl:template>

<xsl:template match="l">
    <xsl:apply-templates/>
    <br/>
</xsl:template>


<xsl:template match="xref">
  <xsl:choose>
    <xsl:when test="@type='url'">
       <a>
 	<xsl:attribute name="href"><xsl:value-of select="."/></xsl:attribute>
	<xsl:value-of select="."/>
       </a>
    </xsl:when>
  </xsl:choose>
</xsl:template>


<xsl:template match="lb">
  <br/>
</xsl:template>

<xsl:template match="pb" name="pb">
  <xsl:variable name="pagenum">
    <xsl:choose>
      <xsl:when test="contains(@n, ' ')">
        <xsl:value-of select="substring-before(@n, ' ')"/>	<!-- format: ## running header -->
      </xsl:when>
      <xsl:when test="contains(@n, '[')">	<!-- format could also be [#] -->
        <xsl:value-of select="substring-before(substring-after(@n, '['),']')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@n"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- create an anchor for linking to a particular page -->
  <xsl:if test="@n != ''">	 <!-- if n is not blank (a few title pages) -->
    <xsl:element name="a">
      <xsl:attribute name="name">page<xsl:value-of select="$pagenum"/></xsl:attribute>
      <xsl:text> </xsl:text>
    </xsl:element>
  </xsl:if>

  <xsl:choose>
    <xsl:when test="$running-header = 'on'">
      <hr class="pagebreak"/>		<!-- page break is the beginning of the page; horizontal rule first -->
      <p>
        <xsl:attribute name="class">pagebreak</xsl:attribute>
        <xsl:call-template name="space-to-nbsp">
          <xsl:with-param name="str" select="@n"/>
        </xsl:call-template>
      </p>
    </xsl:when>
    <xsl:when test="$running-header = 'off'">
      <!-- put a non-breaking space before floating pagebreak 
      (ensures separation between the two words, in case it was not encoded with a space.) -->
	  <!-- non-breaking space -->
	 <xsl:variable name="space">&#160;</xsl:variable>
         <xsl:text> </xsl:text>
      <span>
        <xsl:attribute name="class">pagebreak</xsl:attribute>

        <!-- create an anchor for linking to a particular page -->
        <xsl:if test="@n != ''">	 <!-- if n is not blank (a few title pages) -->
          <xsl:attribute name="name">page<xsl:value-of select="$pagenum"/></xsl:attribute>
          <xsl:value-of select="$pagenum"/>
        </xsl:if>
      </span>
         <xsl:text> </xsl:text>
    </xsl:when>
  </xsl:choose>

  <!-- display page image thumbnail, if there is one -->
  <xsl:if test="@entity">
    <xsl:element name="a">		<!-- link to full size page image -->
      <xsl:attribute name="class">pageimage</xsl:attribute>
      <xsl:attribute name="href"><xsl:value-of select="concat($figure-prefix, @entity, $figure-suffix)"/></xsl:attribute>
      <xsl:element name="img">
        <xsl:attribute name="src"><xsl:value-of select="concat($thumbs-prefix, @entity, $figure-suffix)"/></xsl:attribute>
        <!-- only display colon & number if there is an n attribute -->
        <xsl:attribute name="alt">page image<xsl:if test="@n != ''"> : <xsl:value-of select="@n"/></xsl:if></xsl:attribute>
      </xsl:element>  <!-- img -->
    </xsl:element>  <!-- a -->
  </xsl:if>

</xsl:template>

<!-- figures -->
<!-- <xsl:template match="figure[@rend='inline']"> -->
<xsl:template match="figure">
  <xsl:element name="div">	<!-- wrap image in a div so it can be centered -->
    <xsl:attribute name="class">figure</xsl:attribute>
    <xsl:element name="img">
      <xsl:apply-templates select="@rend"/>
      <xsl:attribute name="src"><xsl:value-of select="concat($figure-prefix, @entity, $figure-suffix)"/></xsl:attribute>
      <xsl:attribute name="alt"><xsl:value-of select="normalize-space(figDesc)"/></xsl:attribute>
    </xsl:element>  <!-- img -->
  </xsl:element> <!-- div -->
</xsl:template>

<xsl:template match="figure/@rend">
  <xsl:attribute name="class"><xsl:value-of select="."/></xsl:attribute>
</xsl:template>


<xsl:template match="milestone">
  <xsl:element name="div">
    <xsl:attribute name="class">milestone</xsl:attribute>
    <xsl:choose>
      <xsl:when test="@rend = 'dots'">
        <xsl:element name="nobr">	<!-- don't wrap line -->
          <!-- dots are tagged individually so spacing can be managed with css -->
          <span class="dot"> . </span>
          <span class="dot"> . </span>
          <span class="dot"> . </span>
          <span class="dot"> . </span>
          <span class="dot"> . </span>
          <span class="dot"> . </span>
          <span class="dot"> . </span>
        </xsl:element>
      </xsl:when>
      <xsl:when test="@rend = 'stars'">
        <xsl:element name="nobr">	<!-- don't wrap line -->
          <!-- stars are tagged individually so spacing can be managed with css -->
          <span class="star"> * </span>
          <span class="star"> * </span>
          <span class="star"> * </span>
          <span class="star"> * </span>
          <span class="star"> * </span>
          <span class="star"> * </span>
          <span class="star"> * </span>
        </xsl:element>
      </xsl:when>
      <xsl:when test="@rend = 'line'">
        <xsl:element name="hr">
          <xsl:attribute name="class">milestone</xsl:attribute>
        </xsl:element>
      </xsl:when>
      <xsl:when test="@rend = 'blank-line'">
        <xsl:element name="p">        	<!-- blank paragraph -->
          <xsl:comment>blank-line milestone</xsl:comment>
        </xsl:element>
      </xsl:when>
    </xsl:choose>
  </xsl:element>
</xsl:template>

<!-- gap in text : show as an editorial comment -->
<xsl:template match="gap">
  <xsl:element name="span">
    <xsl:attribute name="class">editorial</xsl:attribute>
    [<xsl:value-of select="@reason"/> - <xsl:value-of select="@extent"/>]
  </xsl:element>
</xsl:template>

<!-- sic : show 'sic' as an editorial comment -->
<xsl:template match="sic">
  <xsl:apply-templates select="text()"/> <!-- show the text between the sic tags -->
  <xsl:element name="span">
    <xsl:attribute name="class">editorial</xsl:attribute>
	[sic]
  </xsl:element>
</xsl:template>

<!-- display corrections in the text; optionally change display with css -->
<xsl:template match="corr">
  <xsl:element name="span">
    <xsl:attribute name="class">correction</xsl:attribute>
    <xsl:apply-templates select="text()"/>
   </xsl:element>
</xsl:template>


<!-- generic template : put in a span, make tag name class name -->
<xsl:template match="title|label|bibl|stage|epigraph|docAuthor">
  <span>
  <xsl:attribute name="class"><xsl:value-of select="name()"/></xsl:attribute>
   <xsl:apply-templates/>
  </span>
</xsl:template>

<xsl:template match="cit">
  <div class="cit">
    <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template match="hi">
 <span>
   <xsl:attribute name="class"><xsl:value-of select="@rend"/></xsl:attribute>
  <xsl:apply-templates/>
 </span>
</xsl:template>


</xsl:stylesheet>
