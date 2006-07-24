<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0"
  xmlns:exist="http://exist.sourceforge.net/NS/exist"
  exclude-result-prefixes="exist">

<xsl:param name="context">150</xsl:param>
<xsl:param name="minParaSize">10</xsl:param>

  <xsl:output method="xml" omit-xml-declaration="yes"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="context/p">
    <xsl:choose>
      <xsl:when test="string-length(.) &gt; $minParaSize">      
      <!-- only display a paragraph if it is larger than a certain size -->
      <!-- NOTE: this was added to deal with parts of Lincoln Sermon titles tagged as paragraphs -->
        <xsl:element name="p">
          <xsl:attribute name="class">kwic</xsl:attribute>
          <xsl:apply-templates mode="split"/> 
       </xsl:element>
     </xsl:when>
     <xsl:otherwise/>	<!-- don't display -->
    </xsl:choose>
  </xsl:template>

  <!-- keyword mark in exist -->
  <xsl:template match="exist:match">
    <match>
      <xsl:if test="../@rend">
         <xsl:attribute name="rend"><xsl:value-of select="../@rend"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </match>
  </xsl:template>

  <!-- get rid of figures (not needed for kwic) -->
  <xsl:template match="context//p/figure" mode="split"/>
  <!-- get rid of pbs also  -->
  <xsl:template match="context//p/pb" mode="split"/>

  <!-- added for Yeats. -->
  <!-- ignore stage directions in middle of paragraph -->
  <xsl:template match="context//p/stage" mode="split"/>
  <xsl:template match="context//p/ln" mode="split"/>

  <!-- make sure to tokenize text in hi tags, too -->
  <xsl:template match="context//p/hi" mode="split">
      <xsl:apply-templates mode="split"/>	<!-- handle text nodes -->
  </xsl:template>


  <!-- for anything besides text, do default action -->
  <xsl:template match="context//p//*" mode="split" priority="-1">   
    <xsl:apply-templates select="."/> 
 </xsl:template>  

  <!-- tokenization logic from Jeni Tennison -->
  <!-- revised July 2006 to preserve spaces in order to generate properly formatted text for output. -->
  <xsl:template match="text()" mode="split" name="split">
    <xsl:param name="string" select="string()"/>
    <xsl:param name="rend" select="../@rend"/>		<!-- if parent has a rend tag (e.g., hi), get it -->
    <xsl:variable name="space"><xsl:text> </xsl:text></xsl:variable>
      <xsl:variable name="multiword" select="contains($string, $space)"/>

      <xsl:variable name="word">
        <xsl:choose>
          <xsl:when test="$multiword">
            <xsl:value-of select="normalize-space(substring-before($string, $space))"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="normalize-space($string)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:if test="string($word)">
        <w>
          <xsl:if test="$rend">
            <xsl:attribute name="rend"><xsl:value-of select="$rend"/></xsl:attribute>
          </xsl:if>
          <!-- if string started with a space, preserve it by including it here -->
          <xsl:if test="starts-with(., ' ')">
            <xsl:text> </xsl:text>
          </xsl:if>

          <xsl:value-of select="$word"/>

          <!-- if this is a multiword string, preserve the following space by including it here -->
          <xsl:if test="$multiword">
            <xsl:text> </xsl:text>
          </xsl:if>
        </w> <!-- word -->
      </xsl:if>

      <xsl:if test="$multiword">
        <xsl:call-template name="split">
          <xsl:with-param name="string" select="substring-after($string, $space)"/>
        </xsl:call-template>
      </xsl:if>

  </xsl:template>


<!-- default template -->
<xsl:template match="@*|node()">
            <xsl:copy>
              <xsl:apply-templates select="@*|node()"/>
            </xsl:copy>

</xsl:template>


</xsl:stylesheet>
