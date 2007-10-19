<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

  <xsl:output method="xml"/>

  <xsl:template match="/">
    <xsl:apply-templates select="//teiHeader"/>
  </xsl:template>


  <!-- generate display name from tei tag -->
  <xsl:template name="pretty-name">
    <xsl:choose>
      <xsl:when test="name() = 'profileDesc'">
        categorization
      </xsl:when>
      <xsl:when test="contains(name(), 'Stmt')">
        <xsl:variable name="name">
          <xsl:value-of select="substring-before(name(), 'Stmt')"/>  
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$name = 'resp'">
            responsibility
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$name"/>
          </xsl:otherwise>
        </xsl:choose>
        statement
      </xsl:when>
      <xsl:when test="contains(name(), 'Desc')">
        <xsl:value-of select="substring-before(name(), 'Desc')"/> description
      </xsl:when>
      <xsl:when test="contains(name(), 'Decl')">
        <xsl:value-of select="substring-before(name(), 'Decl')"/> declaration
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="name()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- section-level items in paragraph display mode -->
  <xsl:template match="titleStmt|fileDesc|seriesStmt|sourceDesc|encodingDesc">
    <xsl:variable name="label">
      <xsl:call-template name="pretty-name"/>
    </xsl:variable>

    <div>
      <b><xsl:value-of select="$label"/></b>
      <ul>
        <xsl:apply-templates/>
      </ul>
    </div>
  </xsl:template>

  <!-- content-level items in paragraph display mode -->
  <xsl:template match="titleStmt/*|extent|publicationStmt|seriesStmt/title|respStmt|projectDesc|samplingDecl|editorialDecl|profileDesc|revisionDesc">
    <xsl:variable name="label">
      <xsl:call-template name="pretty-name"/>
    </xsl:variable>

    <div>
      <b><xsl:value-of select="$label"/>: </b> 

      <xsl:choose>
        <xsl:when test="name() = 'revisionDesc'">
          <ul>
            <xsl:apply-templates/>
          </ul>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </div>

  </xsl:template>

  <xsl:template match="respStmt/name">
    <xsl:if test="position() != 1">
      <xsl:text>, </xsl:text>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="respStmt/resp">
    (<xsl:apply-templates/>)
  </xsl:template>

  <xsl:template match="title">
    <i><xsl:apply-templates/></i>
  </xsl:template>

  <xsl:template match="creation/rs">
    <li>
      <b><xsl:value-of select="@type"/>: </b>
      <xsl:apply-templates/>
    </li>
  </xsl:template>

  <xsl:template match="creation/rs[@type='collection']">
    <li>
      <b>EWWRP collection: </b>
      <xsl:apply-templates/>
    </li>
  </xsl:template>

  <xsl:template match="creation/date">
    <li>
      <b>time period: </b>
      <xsl:apply-templates/>
    </li>
  </xsl:template>

  <!-- key to convert keyword scheme shorthand into full taxonomy name -->
  <xsl:key name="scheme-by-id" match="taxonomy/bibl/title" use="ancestor::taxonomy/@id"/>

  <!-- don't display taxonomy separately; only use to identify subject scheme -->
  <xsl:template match="taxonomy"/>

  <xsl:template match="keywords">
    <b>subjects:</b>
    (scheme : <xsl:value-of select="key('scheme-by-id', @scheme)"/>)
    <xsl:apply-templates select="list"/>
  </xsl:template>

  <xsl:template match="change">
    <li>
      <xsl:apply-templates select="date"/>. 
      <xsl:apply-templates select="item"/>
      <br/>
      <xsl:apply-templates select="respStmt"/>
    </li>
  </xsl:template>

  <!-- display revision description responsibility statement as formatted -->
  <xsl:template match="revisionDesc//respStmt|revisionDesc//resp|revisionDesc//name">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="creation[rs]">
    <ul>
      <xsl:apply-templates/>
    </ul>
  </xsl:template>

  <!-- generic templates -->
  <xsl:template match="list">
    <ul>
      <xsl:apply-templates/>
    </ul>
  </xsl:template>

  <xsl:template match="list/item">
    <li><xsl:apply-templates/></li>
  </xsl:template>

  <xsl:template match="title">
    <i><xsl:apply-templates/></i>
  </xsl:template>

  <xsl:template match="p">
    <p><xsl:apply-templates/></p>
  </xsl:template>

</xsl:stylesheet>
