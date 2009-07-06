<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

  <xsl:output method="xml" omit-xml-declaration="yes"/>

<xsl:include href="common.xsl"/>
<xsl:include href="footnotes.xsl"/>


<xsl:param name="mode"/>
<xsl:param name="url"/>
<xsl:param name="url_suffix"/>


<!-- node and id that were requested -->
<xsl:param name="node"/>
<xsl:param name="id"/>

<xsl:param name="running-header">off</xsl:param> 
  <!-- on/off : show or hide running header in page breaks -->

<!-- paths for images -->
<xsl:variable name="imgserver">http://bohr.library.emory.edu/ewwrp/image-content/</xsl:variable>
<xsl:variable name="genrefiction">tgfw/</xsl:variable>
<xsl:variable name="figure-prefix">
<xsl:choose>
  <xsl:when test="//rs[@type='collection'] = 'Genre Fiction'">
    <xsl:value-of select="concat($imgserver,$genrefiction)"/>
  </xsl:when>
  <xsl:otherwise>
    <xsl:value-of select="$imgserver"/>
  </xsl:otherwise>
</xsl:choose>
  
</xsl:variable>
<xsl:variable name="thumbs-prefix"><xsl:value-of select="$figure-prefix"/>thumbs/</xsl:variable>
<xsl:variable name="figure-suffix">.jpg</xsl:variable>

<xsl:variable name="newline"><xsl:text>
</xsl:text></xsl:variable>

<xsl:variable name="eebolink">
http://gateway.proquest.com/openurl?ctx_ver=Z39.88-2003&amp;res_id=xri:eebo&amp;rft_id=xri:eebo:image:</xsl:variable>



  <xsl:template match="/">
    <xsl:call-template name="footnote-init"/>

    <xsl:choose>
      <!-- special behavior for critical essays (no teiheader) -->
      <xsl:when test="//div[@type='critical essay']">
        <xsl:apply-templates select="//div/head"/>
       <xsl:apply-templates select="//relative-toc"/>
        <p>by <xsl:apply-templates select="//div/docAuthor"/></p>
        <p>
          <xsl:if test="//div/docDate">
            date: <xsl:value-of select="//div/docDate"/>
          </xsl:if>
                  <!-- include a date on critical essays ? -->
          <!-- include a publisher on critical essays ? -->
          <xsl:apply-templates select="//rs[@type='collection']"/>
        </p>
        <xsl:call-template name="doclinks"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- top-level information about this document content comes from -->
        <xsl:apply-templates select="//teiHeader"/>
      </xsl:otherwise>
    </xsl:choose>



    <!-- table of contents for items under this node (if there are any) -->
    <xsl:apply-templates select="//toc"/>

    <xsl:call-template name="breadcrumb-toc"/>

    <!-- navigation to sibling nodes (first/prev/next/last) -->
    <xsl:apply-templates select="//nav"/>

    <xsl:call-template name="running-header-toggle"/>

    <xsl:choose>
      <xsl:when test="//pb[@n] or //pb[@entity]">
        <!-- indent main content if there are page numbers or page
	     images to display in the margin -->
        <div class="pagedxml">
          <xsl:apply-templates select="//content"/>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="//content"/>
      </xsl:otherwise>
    </xsl:choose>

      <xsl:call-template name="endnotes"/>

    <!-- also supply navigation after content, if it is of any length -->
    <xsl:if test="count(//content//p) > 2">
      <xsl:apply-templates select="//nav"/>      
    </xsl:if>

  </xsl:template>


  <xsl:template name="breadcrumb-toc">
    <xsl:if test="//div[@type!='critical essay']|//pb">
    <p>
      <a>
        <xsl:attribute name="href">toc.php?id=<xsl:value-of select="//doc"/></xsl:attribute>
        Table of Contents
      </a>
    </p>

    <p class='breadcrumb'>
      <xsl:apply-templates select="//relative-toc/node[@name='TEI.2']" mode="breadcrumb"/>
      <xsl:apply-templates select="//relative-toc/node[@type='critical essay']"  mode="breadcrumb"/>
    </p>
    </xsl:if>
  </xsl:template>

  <xsl:template match="node" mode="breadcrumb">
    <xsl:param name="first">true</xsl:param>

    <xsl:variable name="label">
      <xsl:call-template name="toc-label">
        <xsl:with-param name="mode">breadcrumb</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>

    <!-- if label is empty, we still haven't hit the first (root) breadcrumb -->
    <xsl:variable name="empty">
      <xsl:choose>
        <xsl:when test="$label = '' and $first = 'true'">true</xsl:when>        
        <xsl:otherwise>false</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- if this is not the first label, output a breadcrumb separator -->
    <xsl:if test="$label != '' and $first = 'false'">
      <xsl:text> &gt; </xsl:text>
    </xsl:if>

    <xsl:choose>
      <!-- if this is the currently displayed node, don't make it a link -->
      <xsl:when test="@id = //content/*/@id">	<!-- could be div or titlePage -->
      <xsl:value-of select="$label"/>
    </xsl:when>
    <xsl:when test="@id = $id">
      <!-- this is the current node (may be displaying first content-level item under this node) -->
      <xsl:value-of select="$label"/>
    </xsl:when>
    <xsl:otherwise>
      <a>
        <xsl:attribute name="href">content.php?level=<xsl:value-of select="@name"/>&amp;id=<xsl:value-of select="@id"/>&amp;document=<xsl:value-of select="//doc"/><xsl:value-of select="$myurlsuffix"/></xsl:attribute>
        <xsl:value-of select="$label"/>
      </a>
    </xsl:otherwise>
  </xsl:choose>

  <xsl:apply-templates select="key('item-by-parentid-and-parent', 
                               concat(@id, ':', name(..)))" mode="breadcrumb"> 
    <xsl:with-param name="first"><xsl:value-of select="$empty"/></xsl:with-param>
  </xsl:apply-templates>
    
  </xsl:template>




  <xsl:template match="relative-toc">
    <xsl:if test="count(node) > 0">	<!-- don't generate an empty list -->
      <ul class="relative-toc">
        <xsl:apply-templates select="node[@name='TEI.2']"/>
        <xsl:apply-templates select="node[@type='critical essay']"/>
      </ul>
    </xsl:if>
  </xsl:template>


  <xsl:template match="toc">
    <xsl:if test="count(node) > 0">	<!-- don't generate an empty list -->
    <!-- label relative contents according to div type (section, book, chapter, etc.) -->
    <h2><xsl:value-of select="@type"/> Contents</h2>
      <ul>
        <!-- start with top-level items, which are children of the requested node -->
        <xsl:apply-templates select="node"/>
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
      <xsl:attribute name="href">content.php?level=<xsl:value-of select="@name"/>&amp;id=<xsl:value-of select="@id"/>&amp;document=<xsl:value-of select="//doc"/><xsl:value-of select="$myurlsuffix"/></xsl:attribute>

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
        <xsl:when test="@name = 'text'">
          <xsl:value-of select="titlePart"/>
        </xsl:when>
        <xsl:when test="@name= 'pb'">
          <xsl:if test="not(contains(@pages, 'page') or contains(@pages, 'Page') or contains(@pages, 'PAGE'))">
            Page 
          </xsl:if>
          <xsl:value-of select="@pages"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@type"/>
        </xsl:otherwise>
      </xsl:choose>

      <!-- n attribute is redundant in pb case; use everywhere else -->
      <xsl:if test="@name != 'pb'">
        <xsl:text> </xsl:text> 
        <xsl:value-of select="@n"/>
      </xsl:if>

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

<!-- divs are now unnumbered -->
<xsl:template match="div/div/div/div/div/head">
    <h5>
        <xsl:apply-templates/>
    </h5>
</xsl:template>

<xsl:template match="div/div/div/div/head">
    <h4>
        <xsl:apply-templates/>
    </h4>
</xsl:template>

<xsl:template match="div/div/div/head">
    <h3>
        <xsl:apply-templates/>
    </h3>
</xsl:template>

<xsl:template match="div/div/head">
    <h2>
        <xsl:apply-templates/>
    </h2>
</xsl:template>

<xsl:template match="div/head|head">
   <h1>
        <xsl:apply-templates/>
    <xsl:call-template name="next-note"/>
   </h1>
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
    <!-- display any following footnotes *with* the block quote -->
    <xsl:call-template name="next-note"/>
  </div>
</xsl:template>

<!-- handle quotes inside epigraphs differently  -->
<xsl:template match="epigraph//q">
  <xsl:apply-templates/>
</xsl:template>

<!-- don't want p for lg inside q; it makes the footnotes move to the next line -->
<xsl:template match="lg">
<xsl:choose>
<xsl:when test="parent::q">
  <xsl:apply-templates/>
</xsl:when>
<xsl:otherwise>
<p class="lg"><xsl:apply-templates/></p>
</xsl:otherwise>
</xsl:choose>
</xsl:template>


<xsl:template match="l">
  <xsl:choose>
    <xsl:when test="position() != last()">
      <xsl:apply-templates/>
      <br/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- match urls in document -->
<xsl:template match="xref">
  <xsl:choose>
    <xsl:when test="@url">
      <xsl:element name="a">
      <xsl:attribute name="href"><xsl:value-of select="@url"/></xsl:attribute>
      <xsl:value-of select="."/></xsl:element>
    </xsl:when>
    <xsl:when test="@type='url'">
       <a>
 	<xsl:attribute name="href"><xsl:value-of select="."/></xsl:attribute>
	<xsl:value-of select="."/>
       </a>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<!-- xptr is handled this way -->
<xsl:template match="xptr">
  <a>
    <xsl:attribute name="href"><xsl:value-of select="@url"/></xsl:attribute>
    <xsl:value-of select="@url"/>
  </a>
</xsl:template>

<!-- some essays have html-style urls -->
<xsl:template match="a">
  <xsl:element name="a">
    <xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute>
    <xsl:value-of select="."/>
  </xsl:element>
</xsl:template>
<xsl:template match="lb">
  <br/>
</xsl:template>

<!-- pb is main content item : display page image full size -->
<xsl:template match="content/pb[@id = $id]">
  <div class="figure">
     <p><xsl:value-of select="@pages"/></p>
<!-- special handling for mirrour links to eebo pages -->
   <xsl:variable name="imgsrc">
     <xsl:choose>
       <xsl:when test="contains(@id, 'mirrour')">
	 <xsl:value-of select="concat($eebolink, @entity)"/>
       </xsl:when>
       <xsl:otherwise>
	 <xsl:value-of select="concat($figure-prefix, @entity, $figure-suffix)"/>
       </xsl:otherwise>
     </xsl:choose>
   </xsl:variable>
  <xsl:element name="img">
      <xsl:attribute name="src"><xsl:value-of select="$imgsrc"/></xsl:attribute>
      <!-- only display colon & number if there is an n attribute -->
      <xsl:attribute name="alt">page image<xsl:if test="@n != ''"> : <xsl:value-of select="@n"/></xsl:if></xsl:attribute>
    </xsl:element>  <!-- img -->
  </div>
</xsl:template>




<xsl:template match="pb" name="pb">
  <xsl:variable name="pagenum">
    <xsl:choose>
      <xsl:when test="following-sibling::milestone[@ed]"><!-- for ibrahim and mirrour -->
	<xsl:value-of select="@n"/><xsl:text>/</xsl:text>
	<xsl:choose>
	  <xsl:when test="contains(following-sibling::milestone/@n, ' ')">
	    <xsl:value-of select="substring-before(following-sibling::milestone/@n, ' ')"/>
          </xsl:when>
          <xsl:otherwise>
	     <xsl:value-of select="following-sibling::milestone/@n"/>
          </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
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
    <xsl:when test="$running-header = 'off' and $pagenum != ''">
      <!-- note: don't display at all if there is no page number,
      because the empty float messes up any following formatting. -->


      <!-- put a non-breaking space before floating pagebreak 
      (ensures separation between the two words, in case it was not encoded with a space.) -->
	  <!-- non-breaking space -->
	 <xsl:variable name="space">&#160;</xsl:variable>
         <xsl:text> </xsl:text>

         <!-- Only display page mark if the page break occurs inside a paragraph.
              Check for preceding or following text nodes is to
              exclude paragraphs that only contain a page break. -->
         <xsl:variable name="show_pagemark">
           <xsl:if test="parent::p and preceding-sibling::text() or following-sibling::text()">
             <xsl:text>true</xsl:text>
           </xsl:if>
         </xsl:variable>

         <xsl:if test="$show_pagemark = 'true'">
           <span class="pagemark"><xsl:text> | </xsl:text></span>
         </xsl:if>

      <span>
        <xsl:attribute name="class">pagebreak <xsl:if test="$running-header = 'off'">lineup</xsl:if></xsl:attribute>

         <xsl:if test="$show_pagemark = 'true'">
           <span class="pagemark"><xsl:text> | </xsl:text></span>
         </xsl:if>

        <!-- create an anchor for linking to a particular page -->
        <xsl:if test="@n != ''">	 <!-- if n is not blank (a few title pages) -->
        <a>
          <xsl:attribute name="name">page<xsl:value-of select="$pagenum"/></xsl:attribute>
          <xsl:value-of select="$pagenum"/>
        </a>
        </xsl:if>
      </span>
         <xsl:text> </xsl:text>
    </xsl:when>
  </xsl:choose>

  <!-- display page image thumbnail, if there is one -->
<xsl:variable name="doccheck"><xsl:value-of select="//doc"/></xsl:variable>
<!-- <xsl:text>DEBUG: document name is </xsl:text> <xsl:value-of select="$doccheck"/> -->
<xsl:choose>
  <xsl:when test="$doccheck = 'mirrour'">
    <xsl:if test="@entity">
      <xsl:element name="a">     <!-- link to eebo image -->
	<xsl:attribute name="class">pageimage</xsl:attribute>
	<xsl:attribute name="href"><xsl:value-of select="$eebolink"/><xsl:value-of select="@entity"/></xsl:attribute>
	<xsl:element name="img">
	  <xsl:attribute name="src"/><xsl:attribute name="alt">EEBO page image<xsl:text>: </xsl:text><xsl:value-of select="@entity"/></xsl:attribute>
	</xsl:element>
      </xsl:element>
    </xsl:if>
  </xsl:when>
  <xsl:otherwise>
  <xsl:if test="@entity">
    <xsl:element name="a">		<!-- link to full size page image -->
      <xsl:attribute name="class">pageimage</xsl:attribute>
      <xsl:attribute name="href">content.php?level=pb&amp;id=<xsl:value-of select="@id"/>&amp;document=<xsl:value-of select="//doc"/><xsl:value-of select="$myurlsuffix"/></xsl:attribute>
      <xsl:element name="img">
        <xsl:attribute name="src"><xsl:value-of select="concat($thumbs-prefix, @entity, $figure-suffix)"/></xsl:attribute>
        <!-- only display colon & number if there is an n attribute -->
        <xsl:attribute name="alt">page image<xsl:if test="@n != ''"> : <xsl:value-of select="@n"/></xsl:if></xsl:attribute>
      </xsl:element>  <!-- img -->
    </xsl:element>  <!-- a -->
  </xsl:if>
  </xsl:otherwise>
</xsl:choose>
</xsl:template>


<!-- handle milestones used in Mirrour; ignore for now -->
<xsl:template match="milestone[@ed]"/>


<!-- handle catch words  -->
<xsl:template match="seg[@type='catch']|ab[@type='catch']">
  <xsl:choose>
    <xsl:when test="$running-header = 'on'">
      <p class="catch">
        <xsl:apply-templates/>
      </p>
    </xsl:when>
    <!-- when running header is turned off, don't display repeated word -->
    <xsl:when test="$running-header = 'off'"/>
  </xsl:choose>
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
<!-- note: sourceDesc publisher in teiHeader has a different template - links to browse search
     also exclude publishers in a bibliography (in critical editions)   -->
<xsl:template match="pubPlace|publisher[not(ancestor::sourceDesc)][not(ancestor::div[@type='Bibliography' or @type='bibliography'])]">
  <xsl:apply-templates/> <br/>
</xsl:template>


<xsl:template match="milestone">
  <xsl:element name="div">
    <xsl:attribute name="class">milestone</xsl:attribute>
    <xsl:choose>
      <xsl:when test="@rend = 'dots'">
          <!-- dots are tagged individually so spacing can be managed with css -->
          <span class="dot"> . </span>
          <span class="dot"> . </span>
          <span class="dot"> . </span>
          <span class="dot"> . </span>
          <span class="dot"> . </span>
          <span class="dot"> . </span>
          <span class="dot"> . </span>
      </xsl:when>
      <xsl:when test="@rend = 'stars'">
          <!-- stars are tagged individually so spacing can be managed with css -->
          <span class="star"> * </span>
          <span class="star"> * </span>
          <span class="star"> * </span>
          <span class="star"> * </span>
          <span class="star"> * </span>
          <span class="star"> * </span>
          <span class="star"> * </span>
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


<!-- critical essay content display -->
<xsl:template match="div[@type='critical essay']">
  <!-- don't show essay date & collection information here (already displayed earlier) -->
  <xsl:apply-templates select="*[not(self::rs) and not(self::docDate)]"/>
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

<!-- names in Mirrour are in a roman font in the black letter text. We are showing them as bold -->
<xsl:template match="name[@rend='roman']">
  <span>
    <xsl:attribute name="class">name</xsl:attribute>
    <xsl:apply-templates/>
  </span>
</xsl:template>

</xsl:stylesheet>
