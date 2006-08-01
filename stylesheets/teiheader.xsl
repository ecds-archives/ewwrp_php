<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

  <xsl:output method="xml"/>

  <xsl:param name="mode"/>		<!-- paragraph or table -->

  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$mode = 'table'">
        <table>
          <xsl:apply-templates mode="table"/>
        </table>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="//teiHeader" mode="para"/>
      </xsl:otherwise>
    </xsl:choose>
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
  <xsl:template mode="para" match="titleStmt|fileDesc|seriesStmt|sourceDesc|encodingDesc">
    <xsl:variable name="label">
      <xsl:call-template name="pretty-name"/>
    </xsl:variable>

    <div>
      <b><xsl:value-of select="$label"/></b>
      <ul>
        <xsl:apply-templates mode="para"/>
      </ul>
    </div>
  </xsl:template>

  <!-- content-level items in paragraph display mode -->
  <xsl:template mode="para"
    match="titleStmt/*|extent|publicationStmt|seriesStmt/title|respStmt|projectDesc|samplingDecl|editorialDecl|profileDesc|revisionDesc">
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

  <xsl:template match="title" mode="para">
    <i><xsl:apply-templates/></i>
  </xsl:template>

  <!-- items to ignore -->
  <xsl:template mode="para" match="taxonomy"/>

  <!-- section-level items in table display mode -->
  <xsl:template mode="table" match="fileDesc|titleStmt|seriesStmt|sourceDesc|encodingDesc">
    <xsl:param name="level">0</xsl:param>

    <xsl:variable name="label">
      <xsl:call-template name="pretty-name"/>
    </xsl:variable>

    <tr>
      <th colspan="2">
        <xsl:attribute name="class">section level<xsl:value-of select="$level"/></xsl:attribute>
        <xsl:value-of select="$label"/></th>
    </tr>

    <xsl:apply-templates mode="table">
      <xsl:with-param name="level"><xsl:value-of select="($level + 1)"/></xsl:with-param>
    </xsl:apply-templates>

    <tr>
      <td colspan="2" class="endsection"/>
    </tr>
  </xsl:template>

  <!-- content-level items in table display mode -->
  <xsl:template mode="table"
    match="titleStmt/*|extent|publicationStmt|seriesStmt/title|respStmt|projectDesc|samplingDecl|editorialDecl|profileDesc|revisionDesc">
    <xsl:param name="level">0</xsl:param>
    <xsl:variable name="label">
      <xsl:call-template name="pretty-name"/>
    </xsl:variable>

    <tr>
      <th>
        <xsl:attribute name="class">level<xsl:value-of select="$level"/></xsl:attribute>
        <xsl:value-of select="$label"/></th> 
      <td><xsl:apply-templates/></td>
    </tr>

  </xsl:template>

  <xsl:template match="title" mode="table">
    <i><xsl:apply-templates/></i>
  </xsl:template>

  <!-- items to ignore -->
  <xsl:template mode="table" match="taxonomy"/>



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

  <xsl:key name="scheme-by-id" match="taxonomy/bibl/title" use="ancestor::taxonomy/@id"/>

  <!-- don't display separately; only use to identify subject scheme -->
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
