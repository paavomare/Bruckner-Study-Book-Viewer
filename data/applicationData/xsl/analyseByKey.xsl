<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:custom="none"
    exclude-result-prefixes="xs math xd mei custom"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Oct 23, 2018</xd:p>
            <xd:p><xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:param name="windowSize" select="'4'" as="xs:string"/>
    <xsl:param name="profile" select="'simple'" as="xs:string"/>
    
    <!-- keyData folder isn't necessary anymore -->
    <!--<xsl:variable name="keyData.files.folder" select="'data_keydata'"/>-->
    
    <xsl:include href="data/circleOf5.xsl"/>
    <xsl:include href="anl/determine.pitch.xsl"/>
    <xsl:include href="tools/events.add.tstamp2.xsl"/>
    <xsl:include href="anl/determine.roman.numerals.xsl"/>
    <xsl:include href="anl/ks.analysis.xsl"/>
    <xsl:include href="anl/krumhansl.schmuckler.xsl"/>
    <xsl:include href="anl/determine.pnum.xsl"/>
    <xsl:include href="anl/qualify.tones.xsl"/>
    <xsl:include href="tools/add.next.xsl"/>
    <xsl:include href="tools/add.intm.xsl"/>
    <xsl:include href="anl/determine.chords.xsl"/>
    <xsl:include href="anl/base.harmonies.on.key.xsl"/>
    <xsl:include href="anl/decide.harmonies.xsl"/>
    
    <xsl:param name="full.path" as="xs:string"/>
    
    <xsl:variable name="key.data" select="custom:getKeyData(//mei:music,$profile,xs:integer($windowSize))" as="node()"/>
    
    <xsl:template match="/">
        
        <xsl:variable name="added.next" as="node()*">
            <xsl:apply-templates select="node()" mode="add.next"/>
        </xsl:variable>
        
        <xsl:variable name="added.intm" as="node()*">
            <xsl:apply-templates select="$added.next" mode="add.intm"/>
        </xsl:variable>
        
        <xsl:variable name="inserted.harmonies" as="node()*">
            <xsl:apply-templates select="$added.intm" mode="insert.harmonies">
                <xsl:with-param name="all.keys" select="tokenize($key.data/@keys,' ')" as="xs:string*" tunnel="yes"/>
            </xsl:apply-templates>    
        </xsl:variable>
        
        <xsl:variable name="decided.harmonies" as="node()*">
            <xsl:apply-templates select="$inserted.harmonies" mode="decide.harmonies"/>
        </xsl:variable>
        
        <xsl:variable name="qualified.tones" as="node()">
            <xsl:apply-templates select="$decided.harmonies" mode="qualify.tones"/>
        </xsl:variable>
        
        
        <xsl:apply-templates select="$qualified.tones" mode="cleanup.harmonies"/>
    </xsl:template>
    
    <xsl:template match="mei:measure" mode="insert.harmonies">
        <xsl:variable name="this.measure" select="." as="node()"/>
        <xsl:variable name="local.keys" select="$key.data//measure[@xml:id = $this.measure/@xml:id]/key/@name" as="xs:string+"/>
        
        <xsl:variable name="meter.count" select="preceding::mei:scoreDef[@meter.count][1]/xs:integer(@meter.count)" as="xs:integer?"/>
        <xsl:variable name="meter.unit" select="preceding::mei:scoreDef[@meter.unit][1]/xs:integer(@meter.unit)" as="xs:integer?"/>
        
        <xsl:variable name="lookup.keys" select="distinct-values((for $key in $local.keys return substring($key,1,1)))" as="xs:string*"/>
        
        <!--<xsl:message select="'Looking for ' || count($lookup.keys) || ' (' || count($local.keys) || ') keys in measure ' || $this.measure/@n || ': ' || string-join($lookup.keys,' – ') || ' (' || string-join($local.keys,' – ') || ')'"/>-->
        
        <xsl:variable name="harms" as="node()*">
            <xsl:for-each select="$lookup.keys">
                <xsl:variable name="local.key" select="." as="xs:string"/>
                <xsl:variable name="key.pos" select="position()" as="xs:integer"/>
                
                <xsl:variable name="determined.pitch" as="node()">
                    <xsl:apply-templates select="$this.measure" mode="determine.pitch">
                        <xsl:with-param name="current.key" select="$local.key" tunnel="yes"/>
                    </xsl:apply-templates>
                </xsl:variable>
                
                <!-- this will add @tstamp and @tstamp2 to notes within chords to avoid problems with the recognition later on -->
                <xsl:variable name="inherited.tstamps" as="node()">
                    <xsl:apply-templates select="$determined.pitch" mode="inherit.tstamps"/>
                </xsl:variable>
                
                <xsl:variable name="determined.chords" as="node()">
                    <xsl:apply-templates select="$inherited.tstamps" mode="determine.chords">
                        <xsl:with-param name="current.key" select="$local.key" tunnel="yes"/>
                        <xsl:with-param name="current.pos" select="$key.pos" tunnel="yes"/>
                    </xsl:apply-templates>
                </xsl:variable>
                
                <xsl:variable name="based.harmonies.on.key" as="node()">
                    <xsl:apply-templates select="$determined.chords" mode="base.harmonies.on.key">
                        <xsl:with-param name="current.key" select="$local.key" tunnel="yes"/>
                        <xsl:with-param name="current.pos" select="$key.pos" tunnel="yes"/>
                    </xsl:apply-templates>
                </xsl:variable>
                
                <!--<xsl:variable name="events.added.tstamp2" as="node()">
                    <xsl:apply-templates select="$based.harmonies.on.key" mode="events.add.tstamp2">
                        <xsl:with-param name="meter.count" select="$meter.count" tunnel="yes"/>
                        <xsl:with-param name="meter.unit" select="$meter.unit" tunnel="yes"/>
                    </xsl:apply-templates>
                </xsl:variable>-->
                
                <!--<xsl:variable name="determined.numerals" as="node()">
                    <xsl:apply-templates select="$events.added.tstamp2" mode="determine.roman.numerals">
                        <xsl:with-param name="current.key" select="$local.key" tunnel="yes"/>
                    </xsl:apply-templates>
                </xsl:variable>-->
                <!--<xsl:sequence select="$determined.numerals//mei:harm"/>-->
                
                <xsl:sequence select="$based.harmonies.on.key//mei:choice[@type = 'harmInterpretation']"/>
                
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:copy>
            <xsl:attribute name="type" select="string-join($local.keys, ' ')"/>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
            <xsl:sequence select="$harms"/>
        </xsl:copy>
        
    </xsl:template>
    
    <xsl:template match="mei:music" mode="cleanup.harmonies">
        
        <xsl:variable name="raw.keys" select="distinct-values(.//mei:measure/tokenize(@type,' '))" as="xs:string*"/>
        <xsl:variable name="keys" select="distinct-values((for $key in $raw.keys return substring($key,1,1)))" as="xs:string*"/>
        
        <xsl:next-match>
            <xsl:with-param name="keys" select="$keys" tunnel="yes"/>
        </xsl:next-match>
    </xsl:template>
    
    <xsl:template match="mei:harm" mode="cleanup.harmonies">
        <xsl:variable name="current.harm" select="." as="node()"/>
        <xsl:variable name="preceding.harm" select="preceding::mei:harm[@n = $current.harm/@n][1]" as="node()?"/>
        <!--<xsl:message select="'testing harm ' || string-join($current.harm//text()) || ', preceded by ' || string-join($preceding.harm//text())"/>-->
        <xsl:choose>
            <xsl:when test="@type = 'histogram'"/><!-- remove temporary ks histogram, as it's not supposed to be rendered -->
            <xsl:when test="not($preceding.harm)">
                <xsl:next-match/>
            </xsl:when>
            <xsl:when test="string-join($current.harm//text()) = string-join($preceding.harm//text())">
                <!--<xsl:message select="'skipping harm'"/>-->
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="mei:harm/@type" mode="cleanup.harmonies">
        <xsl:variable name="key" select="if(parent::mei:harm/@key) then(' ' || parent::mei:harm/@key) else('')" as="xs:string"/>
        <xsl:attribute name="type" select=". || $key"/>
    </xsl:template>
    
    <xsl:template match="mei:harm/@n" mode="cleanup.harmonies">
        <xsl:param name="keys" tunnel="yes" as="xs:string*"/>
        <xsl:variable name="key" select="parent::mei:harm/@key" as="xs:string"/>
        <xsl:variable name="index" select="index-of($keys,$key)" as="xs:integer?"/>
        <xsl:if test="not($index)">
            <xsl:message select="'Problem at harm ' || parent::mei:harm/@xml:id || ' with key ' || $key"/>
        </xsl:if>
        <xsl:attribute name="n" select="$index"/>
    </xsl:template>
    
    <xsl:template match="mei:harm/@key" mode="cleanup.harmonies"/>
    
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
    
</xsl:stylesheet>
