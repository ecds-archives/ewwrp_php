<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">

  <xsl:output method="xml"/>


  <xsl:param name="mode">kwic</xsl:param>
  <xsl:param name="url_suffix"/>

  <xsl:include href="common.xsl"/>
  <xsl:include href="kwic-words.xsl"/>


  <xsl:template match="/">
    <xsl:apply-templates select="//TEI.2"/>
  </xsl:template>


  <xsl:template match="TEI.2">
    <xsl:apply-templates select="teiHeader"/>

    
    <h2>Keyword in Context</h2>
    <xsl:apply-templates select="key('item-by-parentid', @id)"/>

  </xsl:template>


  <xsl:template match="TEI.2/item">

    <xsl:choose>
      <xsl:when test="not(@name='text' or @name='body' or @name='group')">

      <xsl:variable name="label">
        <xsl:call-template name="toc-label"/>
      </xsl:variable>
      <p>
        <a>
          <xsl:attribute name="href">content.php?level=<xsl:value-of select="@name"/>&amp;id=<xsl:value-of select="@id"/>&amp;<xsl:value-of select="$url_suffix"/></xsl:attribute>
          <xsl:value-of select="$label"/>
        </a>
      </p>

      <xsl:apply-templates select="context"/>
      
      <xsl:if test="key('item-by-parentid', @id)">
        <ul>
          <xsl:apply-templates select="key('item-by-parentid', @id)"/>
        </ul>
      </xsl:if>

    </xsl:when>
    <xsl:otherwise>
      <!-- no label; recurse without indentation -->
      <xsl:apply-templates select="key('item-by-parentid', @id)"/>
    </xsl:otherwise>
  </xsl:choose>

  </xsl:template>


  <xsl:key name="parent-by-id" match="item" use="@id"/>

  <!-- use kwic mode to show context # of words around match terms -->
  <xsl:template match="p|titlePart|note">
    <!-- FIXME: adding l shows only keyword, and not context -->
    <p><xsl:apply-templates select="." mode="kwic"/></p>
  </xsl:template>


</xsl:stylesheet>
