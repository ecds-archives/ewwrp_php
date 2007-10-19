<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

  <xsl:output method="xml"/>

  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="count(//div)">
        <ul class="essays">
          <xsl:apply-templates select="//div"/>
        </ul>
      </xsl:when>
      <xsl:otherwise>
        <!-- some kind of statement like: no essays in the current collection -->
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <xsl:template match="div">
    <li>
      <a>
        <xsl:attribute name="href">content.php?level=div&amp;id=<xsl:apply-templates select="@id"/></xsl:attribute>
      <xsl:apply-templates select="head"/>
    </a>
      <br/>
      <!-- essay author, date (if date is specified) -->
      <xsl:apply-templates select="docAuthor"/><xsl:if test="docDate">, 
	<xsl:apply-templates select="docDate"/>.</xsl:if>
      <br/>
      <xsl:apply-templates select="rs"/>
    </li>
  </xsl:template>

  <xsl:template match="head">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="title">
    <i><xsl:apply-templates/></i>
  </xsl:template>

  <xsl:template match="rs[@type='collection']">
    Collection: <xsl:apply-templates/>
  </xsl:template>

</xsl:stylesheet>
