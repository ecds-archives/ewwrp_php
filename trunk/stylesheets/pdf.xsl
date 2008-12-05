<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  version="1.0">

  <xsl:output method="xml"/>

  <!--  <xsl:include href="common.xsl"/> -->

  <xsl:param name="imgpath">http://bohr.library.emory.edu/ewwrp/image-content/tgfw/</xsl:param>

  <xsl:template match="/">

    <fo:root>
      <fo:layout-master-set>
        
        <!-- first page (no header) -->
        <fo:simple-page-master master-name="first"
          page-height="11in" 
          page-width="8.5in"
          margin-top="0.2in" 
          margin-bottom="0.5in"
          margin-left="0.5in" 
          margin-right="0.5in">
          <fo:region-body margin-bottom="0.7in" 
            column-gap="0.25in" 
            margin-left="0.5in" 
            margin-right="0.5in" 
            margin-top="0.5in"/>
          <fo:region-before extent="1.0in"/>
          <fo:region-after extent="0.5in" region-name="firstpage-footer"/>
        </fo:simple-page-master>

        <fo:simple-page-master master-name="basic"
          page-height="11in" 
          page-width="8.5in"
          margin-top="0.2in" 
          margin-bottom="0.5in"
          margin-left="0.5in" 
          margin-right="0.5in">
          <fo:region-body margin-bottom="0.7in" 
            column-gap="0.25in" 
            margin-left="0.5in" 
            margin-right="0.5in" 
            margin-top="0.5in"/>
          <!-- named header region; to keep from displaying on first page -->
          <fo:region-before extent="1.0in" region-name="header"/>
          <fo:region-after extent="0.5in" region-name="footer"/>
        </fo:simple-page-master>
        
        <!-- one first page, followed by as many basic pages as necessary -->
        <fo:page-sequence-master master-name="all-pages">
          <fo:single-page-master-reference master-reference="first"/>
          <fo:repeatable-page-master-reference master-reference="basic"/>
        </fo:page-sequence-master>
        
      </fo:layout-master-set> 	
      
      <fo:page-sequence master-reference="all-pages" font-family="Times New Roman">

        <!-- display collection name / collection # at top of all pages after the first -->
        <fo:static-content flow-name="header">
          <fo:table left="0in" font-size="10pt" margin-left="0.25in">
            <fo:table-column column-width="4.5in"/>
            <fo:table-column column-width="2.5in"/>
            <fo:table-body> 
            <fo:table-row>
              <fo:table-cell>
                <fo:block text-align="start">
                  <xsl:value-of select="//div[@id='title']"/>
                </fo:block>
              </fo:table-cell>
              <fo:table-cell>
                <fo:block text-align="end">
                  <xsl:value-of select="//span[@id='unitid']"/>
                </fo:block>
              </fo:table-cell>
            </fo:table-row>
          </fo:table-body>
        </fo:table>
        
      </fo:static-content>

      <!-- display MARBL disclaimer at the foot of the first page -->
      <!--      <fo:static-content flow-name="firstpage-footer">
        <fo:block text-align="start" font-family="any" font-style="italic"
          font-size="10pt" margin-left="0.5in" margin-right="0.5in">
          <xsl:value-of select="normalize-space($disclaimer)"/>
        </fo:block>
      </fo:static-content> -->

        
      <fo:static-content flow-name="xsl-footnote-separator">
        <fo:block color="grey"> 
          <fo:leader leader-length="75%" leader-pattern="rule" rule-thickness="1pt"/>
        </fo:block>
      </fo:static-content>

      <fo:static-content flow-name="footer">
        <fo:block text-align="center">
          <fo:page-number/>
        </fo:block>
      </fo:static-content>
      
      <fo:flow flow-name="xsl-region-body">
        
        <fo:block>
          <xsl:apply-templates select="//front/pb[@entity]"/>

          <xsl:call-template name="toc"/>

          <xsl:apply-templates select="/TEI.2/text"/>
        </fo:block>		  
        
        </fo:flow>
        
      </fo:page-sequence>	
      
    </fo:root>

  </xsl:template>

  <xsl:template match="front"/>	<!-- temporary ... -->

  <xsl:template match="front/pb[@entity]">
    <!-- full-page -->
    <fo:external-graphic content-height="scale-to-fit" width="100%" height="100%">
      <xsl:attribute name="src"><xsl:value-of select="concat($imgpath, @entity, '.jpg')"/></xsl:attribute>
    </fo:external-graphic>
  </xsl:template>


  <!-- table of contents -->
  <xsl:template name="toc">
    <fo:block>
      <xsl:attribute name="break-after">page</xsl:attribute>

      <fo:block font-weight="bold" font-size="14pt" text-align="center">Table of Contents</fo:block>
      <xsl:apply-templates mode="toc" select="/TEI.2/text"/>    
    </fo:block>
  </xsl:template>

  <xsl:template match="front" mode="toc"/>	<!-- temporary -->

  <xsl:template match="body" mode="toc">
    <xsl:apply-templates select="div" mode="toc"/>
  </xsl:template>

  <xsl:template match="div|back" mode="toc">
    <fo:block>
      <xsl:if test="@id">  <!-- don't justify if no id / no page # -->
        <xsl:attribute name="text-align-last">justify</xsl:attribute>
      </xsl:if>
      <xsl:variable name="label">
        <xsl:call-template name="toc-label"/>
      </xsl:variable>

      <!--      <xsl:apply-templates select="head" mode="toc"/> -->
      <xsl:value-of select="$label"/>
      <xsl:if test="@id">	<!-- if no id, no way to reference page # -->
        <fo:leader leader-pattern="dots"/>
        <fo:page-number-citation>
          <xsl:attribute name="ref-id"><xsl:value-of select="@id"/></xsl:attribute>
        </fo:page-number-citation>
      </xsl:if>
    </fo:block>

    <xsl:if test="count(./div) > 0">	<!-- fixme: how to determine how deep to go? -->
      <fo:block margin-left="0.25in">
        <xsl:apply-templates select="div" mode="toc"/>
      </fo:block>
    </xsl:if>

  </xsl:template>

  <!--  <xsl:template match="back" mode="toc">
    <fo:block>back matter</fo:block>
    <fo:block margin-left="0.25in">
      <xsl:apply-templates select="div" mode="toc"/>
    </fo:block>
  </xsl:template> -->

  <!-- convert line breaks into spaces when building TOC -->
  <xsl:template match="head/lb|head/milestone" mode="toc">
    <xsl:text> </xsl:text>
  </xsl:template>

  <!-- don't display footnotes or footnote marks in TOC -->
  <xsl:template match="head/note|head/ref" mode="toc"/>

  <xsl:template match="div[not(ancestor::q)]">
    <fo:block>
      <xsl:if test="@type != 'subsection'"><xsl:attribute name="break-before">page</xsl:attribute></xsl:if>
      <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>

      <!-- if immediately-preceding node is pb, output it again -->
      <xsl:apply-templates select="preceding-sibling::*[1][name() = 'pb']"/>
      <!-- fixme: should it NOT be displayed on the preceding page? -->

      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="head">
    <fo:block font-weight="bold" text-align="center" space-after="15pt" space-before.optimum="15pt" keep-with-next="always">
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="p">
    <fo:block>
      <xsl:attribute name="text-indent">10pt</xsl:attribute>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <!-- quotes, letters -->

  <xsl:template match="q">
    <fo:block margin-left="0.5in" margin-right="0.5in" space-before="5pt" space-after="5pt">
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="q//div">
    <fo:block>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="opener">
    <fo:block keep-with-next="always">
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="closer">
    <fo:block text-align="right" keep-with-previous="always">
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <!-- footnotes  -->


  <xsl:template match="ref">
    <!-- fixme: what about refs that don't target notes? links within doc-->
    <fo:basic-link color="blue">
      <xsl:attribute name="internal-destination"><xsl:value-of select="@target"/></xsl:attribute>
      <xsl:apply-templates/>
    </fo:basic-link>
  </xsl:template>


  <xsl:template match="note">
    <fo:footnote>
      <fo:inline font-size="0.83em" baseline-shift="super">
        <xsl:apply-templates select="//ref[@target = ./@id]"/>
      </fo:inline>
      <fo:footnote-body>
        <fo:block text-indent="0pt">
          <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
          <xsl:value-of select="concat(@n, '. ')"/>
          <xsl:apply-templates/>
        </fo:block>
      </fo:footnote-body>
    </fo:footnote>

  </xsl:template>


  <!-- lists -->

  <xsl:template match="list">
    <fo:list-block>
      <xsl:apply-templates/>
    </fo:list-block>
  </xsl:template>

  <xsl:template match="list/head">
    <fo:list-item>
     <fo:list-item-label>
       <fo:block/>
     </fo:list-item-label>
     <fo:list-item-body>
       <fo:block font-weight="bold">
         <xsl:apply-templates/>
       </fo:block>
     </fo:list-item-body>
   </fo:list-item>
  </xsl:template>

  <xsl:template match="list/item">
    <fo:list-item>
     <fo:list-item-label>
       <fo:block/>
     </fo:list-item-label>
     <fo:list-item-body>
       <fo:block>
         <xsl:apply-templates/>
       </fo:block>
     </fo:list-item-body>
   </fo:list-item>
  </xsl:template>

  <!-- tables -->

  <xsl:template match="table[contains(@rend, 'landscape')]">
    <!-- landscape (not quite right...)  -->
    <fo:block-container reference-orientation="90" inline-progression-dimension="12cm" 
      width="10in">
      <xsl:call-template name="table"/>
        </fo:block-container> 

  </xsl:template>

  <xsl:template match="table" name="table">

    <fo:table-and-caption>
      <!-- FIXME: need to use @rend attribute 
table.borders, table.borders td {
 border-collapse:collapse;
 border:1px solid black; 
 margin-left:1px;
 margin-bottom:0.25in;
}
 -->
      <fo:table-caption>    
        <xsl:apply-templates select="head"/>
      </fo:table-caption>

      <fo:table>
        <!--        <xsl:if test="@rend = 'borders'">
          <xsl:attribute name="border-collapse">collapse</xsl:attribute>
          <xsl:attribute name="border-style">solid</xsl:attribute>
          <xsl:attribute name="border-width">1pt</xsl:attribute>
        </xsl:if> -->
        <fo:table-body>
          <xsl:apply-templates select="row"/>
        </fo:table-body>
      </fo:table>
    </fo:table-and-caption>
        
  </xsl:template>

  <xsl:template match="table/head">
      <fo:block>
        <xsl:apply-templates/>
      </fo:block>
  </xsl:template>

  <xsl:template match="table/row">
    <fo:table-row>
      <xsl:apply-templates/>
    </fo:table-row>
  </xsl:template>

  <xsl:template match="table/row/cell">
    <fo:table-cell>
      <xsl:if test="@role = 'label'">
        <xsl:attribute name="font-weight">bold</xsl:attribute>
      </xsl:if>
      <xsl:if test="contains(ancestor::table/@rend, 'borders')">
        <xsl:attribute name="border-collapse">collapse</xsl:attribute>
        <xsl:attribute name="border-style">solid</xsl:attribute>
        <xsl:attribute name="border-width">1pt</xsl:attribute>
      </xsl:if>
      <fo:block>
        <xsl:apply-templates/>        
      </fo:block>
    </fo:table-cell>
  </xsl:template>

  <xsl:template match="cell/label">
    <fo:inline font-weight="bold"><xsl:apply-templates/></fo:inline>
  </xsl:template>

  <xsl:template match="table//pb"/>	<!-- ignore for now (float can't be in table? -->


  <!-- figures -->
  <xsl:template match="figure[@rend = 'inline']">
    <fo:float float="end">
      <fo:block>
        <fo:external-graphic>
          <xsl:attribute name="src"><xsl:value-of select="concat($imgpath, @entity, '.jpg')"/></xsl:attribute>
        </fo:external-graphic>
      </fo:block>
    </fo:float>
    
  </xsl:template>
  
  <!-- poetry -->

  <!-- div type='poem' ? -->
  <xsl:template match="lg | l">
    <fo:block>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>


  <!-- general, common formatting -->

 <xsl:template match="lb">
   <fo:block/>
 </xsl:template>

 <xsl:template match="hi">
   <fo:inline> 
     <xsl:choose>
       <xsl:when test="@rend='italic'">
         <xsl:attribute name="font-style">italic</xsl:attribute>
       </xsl:when>
       <xsl:when test="@rend='bold'">
         <xsl:attribute name="font-weight">bold</xsl:attribute>
       </xsl:when>
     </xsl:choose>

   <xsl:apply-templates/>
   </fo:inline>
 </xsl:template>

 <xsl:template match="title">
   <fo:inline font-style="italic"><xsl:apply-templates/></fo:inline>
 </xsl:template>

 <xsl:template match="milestone">
   <fo:block text-align="center" space-before="10pt" space-after="15pt">
     <fo:leader leader-length="50%" text-align="center">
       <xsl:attribute name="leader-pattern">
         <xsl:choose>
           <xsl:when test="@rend = 'blank-line'">space</xsl:when>
           <xsl:when test="@rend = 'line'">rule</xsl:when>
         </xsl:choose>
       </xsl:attribute>
     </fo:leader>
   </fo:block>
 </xsl:template>
 
 <xsl:template match="milestone[@rend='dots'] | milestone[@rend='stars']">
   
   <!-- using non-breaking spaces to spread out the markers; don't know a more xsl-foish way to do it -->
   <xsl:variable name="pattern">
     &#160;&#160;&#160;&#160;
     <xsl:choose>
       <xsl:when test="@rend='dots'">.</xsl:when>
       <xsl:when test="@rend='stars'">*</xsl:when>
     </xsl:choose>
     &#160;&#160;&#160;&#160;
   </xsl:variable>
   
   <fo:block text-align="center" space-before="10pt" space-after="15pt">
     <xsl:value-of select="concat($pattern,$pattern,$pattern,$pattern,$pattern,$pattern,$pattern)"/>
   </fo:block>
   
 </xsl:template>


 <xsl:template match="pb">
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

  <xsl:variable name="show_pagemark">
    <xsl:if test="parent::p and (preceding-sibling::text() or following-sibling::text())">
      <xsl:text>true</xsl:text>
    </xsl:if>
  </xsl:variable>
  
  <xsl:if test="$show_pagemark = 'true'">
    <fo:inline color="grey"><xsl:text> | </xsl:text></fo:inline>
  </xsl:if>

  <!-- note: because of how floats work, # is currently showing in margin by the NEXT line -->
  <!-- using negative margins to put beyond text; float and align to outside (two-page layout) -->
   <fo:float float="outside" clear="outside" start-indent="-0.5in" end-indent="-0.5in" 
     text-indent="0pt" text-align="outside">
    <fo:block color="grey"><xsl:value-of select="$pagenum"/></fo:block> 
  </fo:float> 
 </xsl:template>


 <xsl:template match="back">
   <fo:block>	<!-- fixme: does this need to be a block? -->
     <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
   </fo:block>
   <xsl:apply-templates/>
 </xsl:template>


 <!-- modified version from common.xsl -->


  <xsl:template name="toc-label">
    <xsl:param name="mode"/>
      <xsl:choose>
        <xsl:when test="name() = 'front'">front matter</xsl:when>
        <xsl:when test="name() = 'back'">back matter</xsl:when>
        <xsl:when test="name() = 'titlePage'">
          title page
          <xsl:if test="@type">
            : <xsl:value-of select="@type"/>
        </xsl:if>
      </xsl:when>
      <xsl:when test="name() = 'text' and name(parent::node) = 'group'">
        <!-- texts under group (composite text) : display title from titlepage -->
        <xsl:apply-templates select="titlePart"/>
      </xsl:when>
      <xsl:when test="name() = 'div'">
        <!-- only display type if it is not duplicated in the head (e.g., chapter) -->
        <xsl:if test="not(contains(
                      translate(head,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),
                      translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')))">
          <xsl:value-of select="@type"/>
          <xsl:if test="head"><xsl:text>: </xsl:text></xsl:if>
        </xsl:if>
        <xsl:if test="head != ''">	<!-- a couple of the outer, wrapping divs are blank -->
          <xsl:choose>
            <xsl:when test="$mode = 'breadcrumb'">
              <xsl:apply-templates select="head" mode="short-toc"/> 
            </xsl:when>        
            <xsl:otherwise>
              <xsl:apply-templates select="head" mode="toc"/> 
            </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
