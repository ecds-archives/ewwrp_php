<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

  <xsl:output method="xml"/>

  <xsl:template match="/">
    <table class="search">
      <tr><th>Title</th><th class="hits"># of matches</th></tr>
      <xsl:apply-templates/>
    </table>
  </xsl:template>

  <xsl:template match="TEI.2">
    <tr>
      <td><xsl:apply-templates select="title"/></td>
      <td class="hits"><xsl:apply-templates select="hits"/></td>
    </tr>
  </xsl:template>

  <xsl:template match="title">
    <a>
      <xsl:attribute name="href">toc.php?id=<xsl:value-of select="../doc"/></xsl:attribute>
      <b><xsl:apply-templates/></b>
    </a>
  </xsl:template>


</xsl:stylesheet>
