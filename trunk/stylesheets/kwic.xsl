<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exist="http://exist.sourceforge.net/NS/exist"
  version="1.0">

  <xsl:output method="xml"/>


  <xsl:param name="mode">kwic</xsl:param>
  <xsl:include href="common.xsl"/>
  <xsl:include href="kwic-words.xsl"/>


  <xsl:template match="/">
    <xsl:apply-templates select="//TEI.2"/>
  </xsl:template>


  <xsl:template match="TEI.2">
    <xsl:apply-templates select="teiHeader"/>
    <!-- display nodes that are direct children of this one -->
    <!--    <xsl:if test="key('item-by-parentid', @id)">
        <h2>Table of Contents</h2>
      <ul>
        <xsl:apply-templates select="key('item-by-parentid', @id)"/>
      </ul>
    </xsl:if> -->
    
    <h2>Keyword in Context</h2>
    <xsl:apply-templates select="item[context/*]" mode="context"/>

  </xsl:template>


  <xsl:template match="TEI.2/item">
    <xsl:choose>
      <!-- only show one level of TOC -->
      <xsl:when test="@name='text' or @name='body' or @name='group'">
        <xsl:apply-templates select="key('item-by-parentid', @id)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="label">
          <xsl:call-template name="toc-label"/>
        </xsl:variable>
        
        <li>
          <a>
            <xsl:attribute name="href">content.php?level=<xsl:value-of select="@name"/>&amp;id=<xsl:value-of select="@id"/></xsl:attribute>
            <xsl:value-of select="$label"/>
          </a>
        </li>
        
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:key name="parent-by-id" match="item" use="@id"/>

  <!-- find nodes with content & work our way up the toc tree -->
  <xsl:template match="item[context/*]" mode="context">
    <xsl:apply-templates select="key('parent-by-id',parent/@id)" mode="context"/> 

    <xsl:variable name="label">
      <xsl:call-template name="toc-label"/>
    </xsl:variable>

          <p>
            <a>
              <xsl:attribute name="href">content.php?level=<xsl:value-of select="@name"/>&amp;id=<xsl:value-of select="@id"/></xsl:attribute>
              <xsl:value-of select="$label"/>
            </a>
            <xsl:apply-templates select="context"/>
          </p>
    
  </xsl:template>

  <xsl:template match="item" mode="context">
    <xsl:if test="parent != 'TEI.2'">
      <xsl:apply-templates select="key('parent-by-id',parent/@id)" mode="context"/> 
    </xsl:if>

    <xsl:if test="not(@name='text' or @name='body' or @name='group')">

      <xsl:variable name="label">
        <xsl:call-template name="toc-label"/>
      </xsl:variable>
      <p>
        <a>
          <xsl:attribute name="href">content.php?level=<xsl:value-of select="@name"/>&amp;id=<xsl:value-of select="@id"/></xsl:attribute>
          <xsl:value-of select="$label"/>
        </a>
        <xsl:apply-templates select="context"/>
      </p>
      
    </xsl:if>

  </xsl:template>

  <xsl:template match="p|titlePart">
    <p><xsl:apply-templates select="." mode="kwic"/></p>
  </xsl:template>

  <xsl:template match="exist:match">
    <span class="match"><xsl:apply-templates/></span>
  </xsl:template>

</xsl:stylesheet>
