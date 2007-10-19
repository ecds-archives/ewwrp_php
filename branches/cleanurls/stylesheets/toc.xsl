<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exist="http://exist.sourceforge.net/NS/exist"
  version="1.0">

  <xsl:output method="xml"/>

  <xsl:param name="mode">toc</xsl:param>
  <xsl:param name="url_suffix"/>
  <xsl:param name="id"/>	
  <xsl:include href="common.xsl"/> 

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>


  <xsl:template match="TEI.2">
    <xsl:apply-templates select="teiHeader"/>
    <!-- display nodes that are direct children of this one -->
      <h2>Table of Contents</h2>
      <ul>
        <xsl:apply-templates select="toc"/>
      </ul>
  </xsl:template>

  <xsl:template match="titleStmt/author">
    <xsl:if test="position() != 1">
      <br/>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>

</xsl:stylesheet>
