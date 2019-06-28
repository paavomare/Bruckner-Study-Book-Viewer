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

  <xsl:variable name="raw.files.folder" select="'data_src'"/>
  <xsl:variable name="page.files.folder" select="'data_pages'"/>
  <xsl:variable name="work.files.folder" select="'data_works'"/>
  <xsl:variable name="pages.files.folder" select="'data_pages'"/>
  <xsl:variable name="keyData.files.folder" select="'data_keydata'"/>

  <xsl:include href="process2work.xsl"/>
  <xsl:include href="process2page.xsl"/>

  <xsl:param name="input.filename" as="xs:string?"/>

  <!-- NB: This now delegates to process2work.xsl.
           Setting the initial mode to "batch" is required!
  -->
  <xsl:template match="/" priority="1">
    <!--
      Process one file if "input.filename" is provided;
      otherwise, process all files in data_src/.
      Processing files one-at-a-time allows for parallelization
      (with e.g. xargs).
      A full run with 4 parallel processes still takes about 90min
      on my machine.
    -->
    <xsl:variable name="file.path" select="string-join(tokenize(document-uri(/),'/')[position() lt last() - 1],'/') || '/'" as="xs:string"/>
    <xsl:variable name="raw.files" as="node()*">
      <xsl:choose>
        <xsl:when test="not($input.filename)">
          <xsl:sequence select="collection($file.path || $raw.files.folder || '/?select=*.xml')//mei:mei"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="doc($input.filename)/mei:mei"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:message select="'INFO (processData.xsl): Trying to process ' || count($raw.files) || ' files'"/>

    <!-- prepare works -->
    <!--<xsl:for-each select="$raw.files">
      <xsl:variable name="current.file" select="." as="node()"/>
      <xsl:variable name="file.name" select="tokenize(document-uri($current.file/root()),'/')[last()]" as="xs:string"/>
      <xsl:message select="'INFO (processData.xsl): Processing ' || $file.name || ' for works'"/>
      <xsl:variable name="output.path.works" select="$file.path || $work.files.folder || '/' || $file.name" as="xs:string"/>
      <xsl:result-document href="{$output.path.works}">
        <xsl:call-template name="process2work">
          <xsl:with-param name="mei" select="."/>
        </xsl:call-template>
      </xsl:result-document>
    </xsl:for-each>-->
  
  
      <!-- prepare pages -->
      <xsl:for-each select="$raw.files">
          <xsl:variable name="current.file" select="." as="node()"/>
          <xsl:variable name="file.name" select="tokenize(document-uri($current.file/root()),'/')[last()]" as="xs:string"/>
          
          <xsl:variable name="output.path.pages" select="$file.path || $pages.files.folder || '/' || $file.name" as="xs:string"/>
          
          <xsl:message select="'[INFO] Starting process2page at ' || $file.name"/>
          
          <xsl:variable name="page.files" as="node()*">
              <xsl:call-template name="process2page">
                  <xsl:with-param name="mei" select="."/>
                  <xsl:with-param name="file.name" select="$file.name"/>
                  <xsl:with-param name="raw.files.path" select="$file.path || $raw.files.folder"/>
              </xsl:call-template>
          </xsl:variable>
          
          <xsl:for-each select="$page.files">
              <xsl:variable name="current.pos" select="position()" as="xs:integer"/>
              <xsl:variable name="current.file" select="." as="node()"/>
              <xsl:variable name="pb.n" select="($current.file//mei:pb)[1]/xs:integer(@n)" as="xs:integer"/>
              <xsl:variable name="new.name" as="xs:string">
                  <xsl:choose>
                      <xsl:when test="$pb.n lt 10">
                          <xsl:value-of select="'Bruckner_page_00' || $pb.n || '.xml'"/>
                      </xsl:when>
                      <xsl:when test="$pb.n lt 100">
                          <xsl:value-of select="'Bruckner_page_0' || $pb.n || '.xml'"/>
                      </xsl:when>
                      <xsl:otherwise>
                          <xsl:value-of select="'Bruckner_page_' || $pb.n || '.xml'"/>
                      </xsl:otherwise>
                  </xsl:choose>
              </xsl:variable>
              <xsl:result-document href="{$file.path || $pages.files.folder || '/' || $new.name}">
                  <xsl:sequence select="$current.file"/>
              </xsl:result-document>
          </xsl:for-each>
          
      </xsl:for-each>
  </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>This is a generic copy template which will copy all content in all modes</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="node() | @*" mode="#all" priority="0.5">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
