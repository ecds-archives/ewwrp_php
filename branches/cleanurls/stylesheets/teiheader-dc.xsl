<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns:dc="http://purl.org/dc/elements/1.1/"
                version="1.0">

  <xsl:output method="xml" omit-xml-declaration="yes"/>

  <xsl:template match="/">
    <dc>
      <!-- <xsl:apply-templates select="//bibl"/> -->
      <xsl:apply-templates select="//teiHeader"/>
    <dc:type>Text</dc:type>
    <dc:format>text/xml</dc:format>
    </dc>
  </xsl:template>

  <xsl:template match="title">
    <xsl:element name="dc:title">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>


  <xsl:template match="author">
    <xsl:element name="dc:creator">
      <xsl:apply-templates/> <xsl:if test="name/@reg != name"> [<xsl:value-of select="name/@reg"/>]</xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template match="editor">
    <xsl:element name="dc:contributor">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>


  <xsl:template match="publisher[not(parent::imprint)]">
    <xsl:element name="dc:publisher">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>


  <!-- ignore source publisher & date for now; included in dc:source -->
  <xsl:template match="imprint/publisher"/>
  <xsl:template match="bibl//date"/>

  <xsl:template match="date">
    <xsl:element name="dc:date">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>


  <!-- ignore for now; do these fit anywhere? -->
  <xsl:template match="publicationStmt/address"/>
  <xsl:template match="publicationStmt/pubPlace|imprint/pubPlace|pubPlace"/>
  <xsl:template match="respStmt"/>

  <xsl:template match="availability">
    <xsl:element name="dc:rights">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="seriesStmt/title">
    <xsl:element name="dc:relation">
      <!-- fixme: should we specify isPartOf? -->
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="sourceDesc/bibl">
    <xsl:element name="dc:source">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <!-- apply templates normally inside the bibl -->
  <xsl:template match="bibl/author|bibl/title|bibl/pubPlace|bibl/publisher|bibl/date">
    <xsl:apply-templates/>
  </xsl:template> 

  <xsl:template match="encodingDesc/projectDesc">
    <xsl:element name="dc:description">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="profileDesc/creation/date">
    <xsl:element name="dc:coverage">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="profileDesc/creation/rs[@type='geography']">
    <xsl:element name="dc:coverage">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <!-- ignore other rs types for now -->
  <xsl:template match="profileDesc/creation/rs[@type!='geography']"/>


  <!-- subject headings -->
  <xsl:template match="keywords/list/item">
    <xsl:element name="dc:subject">
      <xsl:if test="ancestor::keywords/@scheme">
        <xsl:attribute name="scheme"><xsl:value-of select="ancestor::keywords/@scheme"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <!-- ignore these: encoding specific information -->
  <xsl:template match="encodingDesc/tagsDecl"/>
  <xsl:template match="encodingDesc/refsDecl"/>
  <xsl:template match="encodingDesc/editorialDecl"/>
  <xsl:template match="revisionDesc"/>

  <!-- normalize space for all text nodes -->
  <xsl:template match="text()">
    <!-- normalization will lose beginning & ending spaces, so add them back if they are present -->
    <xsl:if test="starts-with(., ' ')">
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:value-of select="normalize-space(.)"/>

    <xsl:variable name="len">
      <xsl:value-of select="string-length(.)"/>
    </xsl:variable>
    <xsl:if test="substring(., $len, $len+1) = ' '">
      <xsl:text> </xsl:text>
    </xsl:if>

  </xsl:template>


</xsl:stylesheet>
