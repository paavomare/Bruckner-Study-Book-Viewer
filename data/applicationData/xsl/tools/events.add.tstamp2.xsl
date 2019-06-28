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
            <xd:p><xd:b>Created on:</xd:b> Oct 23, 2018</xd:p>
            <xd:p><xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:template match="mei:staff//mei:*[@tstamp and @dur and not(@tstamp2)]" mode="events.add.tstamp2">
        <xsl:param name="meter.count" tunnel="yes"/>
        <xsl:param name="meter.unit" tunnel="yes"/>
        
        <xsl:variable name="dur" select="1 div number(@dur)" as="xs:double"/>
        <xsl:variable name="tupletFactor" as="xs:double">
            <xsl:choose>
                <xsl:when test="ancestor::mei:tuplet[@numbase and @num]">
                    <xsl:value-of select="(ancestor::mei:tuplet)[1]/number(@numbase) div (ancestor::mei:tuplet)[1]/number(@num)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="1"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="dots" as="xs:double">
            <xsl:choose>
                <xsl:when test="@dots">
                    <xsl:value-of select="number(@dots)"/>
                </xsl:when>
                <xsl:when test="local-name() = 'bTrem' and child::mei:*/@dots">
                    <xsl:value-of select="child::mei:*[@dots]/number(@dots)"/>
                </xsl:when>
                <xsl:when test="local-name() = 'fTrem' and child::mei:*/@dots">
                    <xsl:value-of select="child::mei:*[@dots][1]/number(@dots)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="0"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="total.dur" select="(2 * $dur - ($dur div math:pow(2,$dots))) * $tupletFactor" as="xs:double"/>
        <xsl:variable name="onset" select="number(@tstamp)" as="xs:double"/>
        
        <!--<xsl:message select="'Meter: ' || $meter.count || '/' || $meter.unit || ' - Dur:' || @dur || '.' || $dots || ' – totalDur: ' || $total.dur
            || ' – onset: ' || $onset || ' – addition: ' || ($total.dur * $meter.unit) || ' - offset: ' || ($onset + ($total.dur * $meter.unit))"/>
        -->
        <xsl:copy>
            <xsl:attribute name="tstamp2" select="($onset + ($total.dur * $meter.unit))"/>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>