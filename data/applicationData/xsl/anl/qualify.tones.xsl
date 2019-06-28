<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:custom="none"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:uuid="http://www.uuid.org"
    exclude-result-prefixes="xs math xd mei custom uuid" version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Nov 28, 2018</xd:p>
            <xd:p><xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    
    <xsl:template match="mei:note" mode="qualify.tones">
        
        <xsl:variable name="this.note" select="." as="node()"/>
        <xsl:variable name="harm" select="ancestor::mei:measure/mei:harm[@type='mfunc']//mei:annot[$this.note/@xml:id = tokenize(@plist,' ')]" as="node()*"/>
        
        <!-- DEBUG: spots that a tone changes it's role because of changing harmonies -->
        <!--<xsl:if test="count($harm) gt 1">
            <xsl:message select="'note ' || @xml:id || ' appears as ' || string-join($harm/@type,' - ')"/>
        </xsl:if>-->
        <xsl:variable name="mfunc" as="xs:string?">
            <xsl:if test="$harm">
                <xsl:value-of select="string-join(distinct-values(tokenize(replace(string-join($harm/@type,' '),' ct\d',''),' ')),' ')"/>
            </xsl:if>
        </xsl:variable>
        
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:if test="$harm">
                <xsl:attribute name="mfunc" select="$mfunc"/>
                <xsl:if test="matches($mfunc,'(sus|ret|n|pt)')">
                    <xsl:attribute name="type" select="'mod ' || $mfunc"/>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
        
    </xsl:template>
    
    <xsl:template match="mei:rend[matches(@type,'(sus|ret|n|pt)')]" mode="qualify.tones"/>
    
    <xsl:template match="mei:annot[@type = 'mfunc.tonelist']" mode="qualify.tones"/>
    
    
</xsl:stylesheet>
