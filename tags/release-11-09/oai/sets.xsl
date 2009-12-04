<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.openarchives.org/OAI/2.0/"
  version="1.0">


  <!-- no easy mapping between tags in TEI & set name -->
  <xsl:template match="rs[@type='form']" mode="set">
    <xsl:if test=". = 'Edited'">
      <setSpec>criticaledition</setSpec>
    </xsl:if>
  </xsl:template>

  <xsl:template match="rs" mode="set">
    <xsl:call-template name="setSpec">
      <xsl:with-param name="name" select="."/>
    </xsl:call-template>

    <!-- special case: TGFW American subset for Aquifer -->
    <xsl:if test=". = 'Genre Fiction' and ../rs[@type='geography'] = 'United States'">
      <xsl:call-template name="setSpec">
        <xsl:with-param name="name">Genre Fiction - American Literature</xsl:with-param>
      </xsl:call-template>
      
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
