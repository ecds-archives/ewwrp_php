<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

<xsl:include href="common.xsl"/>
<xsl:include href="footnotes.xsl"/>


<xsl:param name="mode"/>
<xsl:param name="url"/>
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

    <xsl:apply-templates select="//toc"/>

    <xsl:apply-templates select="//nav"/>

    <xsl:call-template name="running-header-toggle"/>
    <div class="xmlcontent">
      <xsl:apply-templates select="//content"/>
    </div>

    <!-- also supply navigation after content, if it is of any length -->
    <xsl:if test="count(//content//p) > 2">
      <xsl:apply-templates select="//nav"/>      
    </xsl:if>

  </xsl:template>

  <xsl:template match="relative-toc">
    <xsl:if test="count(item) > 0">	<!-- don't generate an empty list -->
      <ul class="relative-toc">
        <xsl:apply-templates select="item[@name='TEI.2']"/>
      </ul>
    </xsl:if>
  </xsl:template>


  <xsl:template match="toc">
    <xsl:if test="count(toc-item) > 0">	<!-- don't generate an empty list -->
    <h2>Table of Contents</h2>
      <ul>
        <xsl:apply-templates select="toc-item"/>
      </ul>
    </xsl:if>

  </xsl:template>

  <xsl:template match="nav">
    <table class="searchnav">
      <tr>
        <td><xsl:apply-templates select="first"/></td>
        <xsl:value-of select="$newline"/>
        <td><xsl:apply-templates select="prev"/></td>
        <xsl:value-of select="$newline"/>
        <td><xsl:apply-templates select="next"/></td>
        <xsl:value-of select="$newline"/>
        <td><xsl:apply-templates select="last"/></td>
        <xsl:value-of select="$newline"/>
      </tr>
    </table>
  </xsl:template>

  <xsl:template match="nav/first|nav/prev|nav/next|nav/last">
    <!-- don't display first/last if they are the same as next/prev -->
    <xsl:if test="not(name() = 'first' and @id = ../prev/@id) and
                  not(name() = 'last' and @id = ../next/@id)">
    <a>
      <xsl:attribute name="rel"><xsl:value-of select="name()"/></xsl:attribute>
      <xsl:attribute name="href">content.php?level=<xsl:value-of select="@name"/>&amp;id=<xsl:value-of select="@id"/></xsl:attribute>

      <!-- arrows to help user understand relation -->
      <xsl:choose>
        <xsl:when test="name() = 'first'">&lt;&lt; </xsl:when>
        <xsl:when test="name() = 'prev'">&lt; </xsl:when>
      </xsl:choose>

      <!-- for divs use the type attribute, but not for title pages -->
      <xsl:choose>
        <xsl:when test="@name = 'titlePage'">
          title page 
          <xsl:if test="@type">
            (<xsl:value-of select="@type"/>)
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@type"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text> </xsl:text> 
      <xsl:value-of select="@n"/>

      <!-- arrows to help user understand relation -->
      <xsl:choose>
        <xsl:when test="name() = 'next'"> &gt;</xsl:when>
        <xsl:when test="name() = 'last'"> &gt;&gt;</xsl:when>
      </xsl:choose>

    </a>
    </xsl:if>
  </xsl:template>

  <xsl:template name="running-header-toggle">
    <xsl:if test="//pb">
      <!-- toggle page-break & running header display style 
           (only display option if there are page breaks in the text)  -->
      <p class="pagebreak-toggle">
        <xsl:choose>
          <xsl:when test="$running-header = 'off'">
            <a><xsl:attribute name="href"><xsl:value-of select="$url"/>&amp;running-header=on</xsl:attribute>
            Display page layout</a>
          </xsl:when>
          <xsl:otherwise>
            <a><xsl:attribute name="href"><xsl:value-of select="$url"/>&amp;running-header=off</xsl:attribute>
            Hide page layout</a>
          </xsl:otherwise>
        </xsl:choose>
      </p>
    </xsl:if>
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

<!-- title page tags -->
<xsl:template match="titlePage">
  <xsl:element name="div">
    <xsl:attribute name="class">titlepage</xsl:attribute>
    <!-- pick up the appropriate page break to display page image -->
    <xsl:choose>
      <xsl:when test="@type='illustrated'">
        <!-- if displaying illustrated title page, only display illustrated page image -->
        <xsl:apply-templates select="//content/pb[@pages='Illustrated Title Page']" 
          mode="override"/>
      </xsl:when>
      <xsl:when test="@type='half'">
        <!-- if displaying half title page, only display half page image -->
        <xsl:apply-templates select="//content/pb[@pages='Half-Title Page']" 
          mode="override"/>
      </xsl:when>
      <xsl:otherwise>	<!-- default: full titlePage -->
        <xsl:apply-templates select="//content/pb[@pages='Title Page']" mode="override"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>


<!-- put each title part on its own line; keep type for styling -->
<xsl:template match="titlePart">
  <xsl:element name="p">
    <xsl:attribute name="class">titlepart <xsl:value-of select="@type"/></xsl:attribute>
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

<xsl:template match="byline|docImprint|docDate|docEdition">
  <xsl:element name="p">
    <xsl:attribute name="class"><xsl:value-of select="name()"/></xsl:attribute>
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

<!-- line break after every pubPlace and publisher -->
<!-- note: sourceDesc publisher in teiHeader has a different template - links to browse search -->
<xsl:template match="pubPlace|publisher[not(ancestor::sourceDesc)]">
  <xsl:apply-templates/> <br/>
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
