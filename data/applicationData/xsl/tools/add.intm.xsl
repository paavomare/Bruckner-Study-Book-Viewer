<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:tools="no:link"
    exclude-result-prefixes="xs math xd mei"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> May 20, 2019</xd:p>
            <xd:p><xd:b>Author:</xd:b> Johannes Kepper</xd:p>
            <xd:p>This XSLT generates @intm on all notes having a @prev attribute.
                It does not consider octave displacement that start or end
                between this and the preceding note. It depends on circleOf5.xsl to be loaded.
            </xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:template match="mei:mdiv" mode="add.intm">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            
            <xsl:variable name="added.intm" as="node()*">
                <xsl:apply-templates select="node()" mode="#current"/>
            </xsl:variable>
            
            <xsl:apply-templates select="$added.intm" mode="add.next.intm"/>
        </xsl:copy>
        
    </xsl:template>
    
    <xsl:template match="mei:note[@prev]" mode="add.intm">
        
        <xsl:variable name="this" select="." as="node()"/>
        <xsl:variable name="prev" select="ancestor::mei:mdiv//mei:note[@xml:id = substring($this/@prev,2)]" as="node()"/>
        
        <xsl:variable name="diat.pitches" select="('c','d','e','f','g','a','b')" as="xs:string*"/>
        <xsl:variable name="semi.pitches" select="('c','','d','','e','f','','g','','a','','b')" as="xs:string*"/>
        
        <xsl:variable name="this.pname.string" select="@pname" as="xs:string"/>
        <xsl:variable name="this.oct" select="xs:integer(@oct)" as="xs:integer"/>
        <xsl:variable name="this.pname.diat.int" select="$this.oct * 7 + index-of($diat.pitches,$this.pname.string)" as="xs:integer"/>
        <xsl:variable name="this.pname.semi.int" select="$this.oct * 12 + index-of($semi.pitches,$this.pname.string)" as="xs:integer"/>
        <xsl:variable name="this.pname.semi.offset" select="tools:retrieveAccidentalOffset($this)" as="xs:integer"/>
        <xsl:variable name="this.pname.semi.total" select="$this.pname.semi.int + $this.pname.semi.offset" as="xs:integer"/>
        
        <xsl:variable name="prev.pname.string" select="$prev/@pname" as="xs:string"/>
        <xsl:variable name="prev.oct" select="xs:integer($prev/@oct)" as="xs:integer"/>
        <xsl:variable name="prev.pname.diat.int" select="$prev.oct * 7 + index-of($diat.pitches,$prev.pname.string)" as="xs:integer"/>
        <xsl:variable name="prev.pname.semi.int" select="$prev.oct * 12 + index-of($semi.pitches,$prev.pname.string)" as="xs:integer"/>
        <xsl:variable name="prev.pname.semi.offset" select="tools:retrieveAccidentalOffset($prev)" as="xs:integer"/>
        <xsl:variable name="prev.pname.semi.total" select="$prev.pname.semi.int + $prev.pname.semi.offset" as="xs:integer"/>
        
        <xsl:variable name="diats" select="$this.pname.diat.int - $prev.pname.diat.int" as="xs:integer"/>
        <xsl:variable name="semis" select="$this.pname.semi.total - $prev.pname.semi.total" as="xs:integer"/>
        
        <xsl:variable name="interval" select="tools:qualifyInterval($diats,$semis)" as="xs:string"/>
        
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:attribute name="intm" select="$interval"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
        
    </xsl:template>
    
    <xsl:template match="mei:note[@next]" mode="add.next.intm">
        <xsl:variable name="ref" select="'#' || @xml:id" as="xs:string"/>
        <xsl:variable name="match" select="ancestor::mei:section//mei:note[@prev = $ref]" as="node()*"/>
        
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:if test="exists($match)">
                <!-- info: this takes only the first referring note's xml:id -->
                <xsl:attribute name="next.intm" select="$match[1]/@intm"/>
            </xsl:if>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:function name="tools:qualifyInterval" as="xs:string">
        <xsl:param name="diats" as="xs:integer"/>
        <xsl:param name="semis" as="xs:integer"/>
        
        <xsl:variable name="intervals" as="node()*">
            
            <tools:interval name="Duodezime" diat="-11" semi-17="-d12" semi-18="-P12" semi-19="-A12"/>
            <tools:interval name="Undezime" diat="-10" semi-16="-d11" semi-17="-P11" semi-18="-A11"/>
            <tools:interval name="Dezime" diat="-9" semi-14="-d10" semi-15="-m10" semi-16="-M10" semi-17="-A10"/>
            <tools:interval name="None" diat="-8" semi-12="-d9" semi-13="-m9" semi-14="-M9" semi-15="-A9"/>
            <tools:interval name="Oktave" diat="-7" semi-11="-d8" semi-12="-P8" semi-13="-A8"/>
            <tools:interval name="Septime" diat="-6" semi-9="-d7" semi-10="-m7" semi-11="-M7" semi-12="-A7"/>
            <tools:interval name="Sexte" diat="-5" semi-7="-d6" semi-8="-m6" semi-9="-M6" semi-10="-A6"/>
            <tools:interval name="Quinte" diat="-4" semi-6="-d5" semi-7="-P5" semi-8="-A5"/>
            <tools:interval name="Quarte" diat="-3" semi-4="-d4" semi-5="-P4" semi-6="-A4"/>
            <tools:interval name="Terz" diat="-2" semi-2="-d3" semi-3="-m3" semi-4="-M3" semi-5="-A3"/>
            <tools:interval name="Sekunde" diat="-1" semi0="-d2" semi-1="-m2" semi-2="-M2" semi-3="-A2"/>
            
            <tools:interval name="Prime" diat="0" semi-1="-d1" semi0="P1" semi1="+A1"/>
            <tools:interval name="Sekunde" diat="1" semi0="+d2" semi1="+m2" semi2="+M2" semi3="+A2"/>
            <tools:interval name="Terz" diat="2" semi2="+d3" semi3="+m3" semi4="+M3" semi5="+A3"/>
            <tools:interval name="Quarte" diat="3" semi4="+d4" semi5="+P4" semi6="+A4"/>
            <tools:interval name="Quinte" diat="4" semi6="+d5" semi7="+P5" semi8="+A5"/>
            <tools:interval name="Sexte" diat="5" semi7="+d6" semi8="+m6" semi9="+M6" semi10="+A6"/>
            <tools:interval name="Septime" diat="6" semi9="+d7" semi10="+m7" semi11="+M7" semi12="+A7"/>
            <tools:interval name="Oktave" diat="7" semi11="+d8" semi12="+P8" semi13="+A8"/>
            <tools:interval name="None" diat="8" semi12="+d9" semi13="+m9" semi14="+M9" semi15="+A9"/>
            <tools:interval name="Dezime" diat="9" semi14="+d10" semi15="+m10" semi16="+M10" semi17="+A10"/>
            <tools:interval name="Undezime" diat="10" semi16="+d11" semi17="+P11" semi18="+A11"/>
            <tools:interval name="Duodezime" diat="11" semi17="+d12" semi18="+P12" semi19="+A12"/>
        </xsl:variable>
    
        <xsl:value-of select="$intervals/descendant-or-self::tools:interval[xs:integer(@diat) = $diats]/@*[local-name() = ('semi' || string($semis))]"/>
    
    </xsl:function>
    
    <xsl:function name="tools:retrieveAccidentalOffset" as="xs:integer">
        <xsl:param name="note" as="node()"/>
        <xsl:variable name="str" as="xs:string">
            <xsl:choose>
                <xsl:when test="$note//@accid.ges">
                    <xsl:value-of select="$note//@accid.ges"/>
                </xsl:when>
                <xsl:when test="$note//@accid">
                    <xsl:value-of select="$note//@accid"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'n'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="$accidental.values//xs:integer(@*[local-name()=$str])"/>
    </xsl:function>
    
</xsl:stylesheet>