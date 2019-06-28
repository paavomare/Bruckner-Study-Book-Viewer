<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:mei="http://www.music-encoding.org/ns/mei"
  exclude-result-prefixes="xs math xd mei"
  version="3.0">
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> Oct 22, 2018</xd:p>
      <xd:p><xd:b>Author:</xd:b> johannes</xd:p>
      <xd:p>

        TODO: Right now, fTrem and bTrem are resolved as well, which results in ugly layout, but is processed correctly
        regarding analysis… 

      </xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:output method="xml" indent="yes"/>

  <xsl:include href="tools/add.id.xsl"/>
  <xsl:include href="tools/add.tstamps.xsl"/>
  <xsl:include href="anl/krumhansl.schmuckler.xsl"/>
  <xsl:include href="anl/determine.pnum.xsl"/>
  <xsl:include href="anl/determine.pitch.xsl"/>
  <xsl:include href="anl/determine.roman.numerals.xsl"/>
  <xsl:include href="data/circleOf5.xsl"/>
  <xsl:include href="bruckner/generateKeyData.xsl"/>

  <xsl:template match="/">
    <xsl:call-template name="process2work">
      <xsl:with-param name="mei" select="/mei:mei"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="process2work">
    <xsl:param name="mei"/>
    <xsl:variable name="current.file" select="$mei" as="node()"/>
    <xsl:variable name="extracted.work" as="node()">
      <xsl:apply-templates select="$current.file" mode="retrieve.workfile"/>
    </xsl:variable>

    <xsl:variable name="work.with.ids" as="node()">
      <xsl:apply-templates select="$extracted.work" mode="add.id"/>
    </xsl:variable>

    <xsl:variable name="work.with.tstamps" as="node()">
      <xsl:apply-templates select="$work.with.ids" mode="add.tstamps"/>
    </xsl:variable>

    <xsl:apply-templates select="$work.with.tstamps" mode="add.measure.profiles"/>
  </xsl:template>

  <!-- START MODE retrieve.workfile -->
  <xsl:template match="mei:choice" mode="retrieve.workfile">
    <xsl:apply-templates select="mei:expan/node() | mei:corr[1]/node() | mei:reg[1]/node()" mode="#current"/>
  </xsl:template>

  <xsl:template match="mei:abbr" mode="retrieve.workfile"/>
  <xsl:template match="mei:sic" mode="retrieve.workfile"/>
  <xsl:template match="mei:orig" mode="retrieve.workfile"/>
  <!-- XXX: maybe we should ignore these in the key-finding code instead -->
  <xsl:template match="mei:note[not(@pname)]" mode="retrieve.workfile"/>

  <xsl:template match="mei:corr" mode="retrieve.workfile">
    <xsl:apply-templates select="child::node()" mode="#current"/>
  </xsl:template>
  <xsl:template match="mei:expan" mode="retrieve.workfile">
    <xsl:apply-templates select="child::node()" mode="#current"/>
  </xsl:template>
  <xsl:template match="mei:reg" mode="retrieve.workfile">
    <xsl:apply-templates select="child::node()" mode="#current"/>
  </xsl:template>

  <xsl:template match="mei:subst" mode="retrieve.workfile">
    <xsl:apply-templates select="mei:add/node()" mode="#current"/>
  </xsl:template>

  <xsl:template match="mei:del" mode="retrieve.workfile"/>
  
  <xsl:template match="mei:restore" mode="retrieve.workfile">
    <xsl:apply-templates select=".//mei:del/child::node()" mode="#current"/>
  </xsl:template>

  <xsl:template match="mei:add" mode="retrieve.workfile">
    <xsl:apply-templates select="child::node()" mode="#current"/>
  </xsl:template>

  <!-- END MODE retrieve.workfile -->

  <xd:doc>
    <xd:desc>
      <xd:p>This is a generic copy template which will copy all content in all modes</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="node() | @*" mode="#all">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="xsl:*" priority="-1"/>

</xsl:stylesheet>
