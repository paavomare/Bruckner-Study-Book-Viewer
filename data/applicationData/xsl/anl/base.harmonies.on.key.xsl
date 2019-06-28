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
            <xd:p><xd:b>Created on:</xd:b> May 27, 2019</xd:p>
            <xd:p><xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p>This stylesheets takes harm elements produced by determine.chords.xsl and 
                translates them into Stufen for a given key
            </xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:template match="mei:harm/@type" mode="base.harmonies.on.key">
        <xsl:param name="current.key" tunnel="yes" as="xs:string"/>
        <xsl:next-match/>
        <xsl:attribute name="key" select="substring($current.key,1,1)"/>
    </xsl:template>
    
    <!-- determine roman numeral -->
    <xsl:template match="mei:harm[@type='mfunc']/mei:rend[@type='root']" mode="base.harmonies.on.key">
        
        <xsl:param name="current.key" tunnel="yes" as="xs:string"/>
        
        <xsl:variable name="pitches" select="('C','D','E','F','G','A','B')" as="xs:string*"/>
        <xsl:variable name="numerals" select="('I','II','III','IV','V','VI','VII')" as="xs:string*"/>
        
        <xsl:variable name="index.of.current.key" select="index-of($pitches,substring($current.key,1,1))" as="xs:integer"/>
        <xsl:variable name="index.of.current.chord" select="index-of($pitches,substring(./text(),1,1))" as="xs:integer"/>
        
        <xsl:variable name="diff" select="$index.of.current.key - 1" as="xs:integer"/>
        <xsl:variable name="index.of.numeral" select="($index.of.current.chord - $diff + 7) mod 7" as="xs:integer"/>
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:attribute name="class" select="./text()"/>
            <xsl:value-of select="$numerals[if($index.of.numeral = 0) then(7) else($index.of.numeral)]"/>
        </xsl:copy>
        
    </xsl:template>
    
    <!-- filter out chord tones (unless they're bass tone) -->
    <xsl:template match="mei:harm[@type='mfunc']/mei:rend['ct' = tokenize(@type,' ')]" mode="base.harmonies.on.key">
        
        <xsl:variable name="types" select="tokenize(@type,' ')" as="xs:string*"/>
        
        <xsl:choose>
            <xsl:when test="'bass' = $types and 'ct3' = $types">
                <xsl:next-match/>
            </xsl:when>
            <xsl:when test="'bass' = $types and 'ct5' = $types">
                <xsl:next-match/>
            </xsl:when>
        </xsl:choose>
        
    </xsl:template>
    
</xsl:stylesheet>