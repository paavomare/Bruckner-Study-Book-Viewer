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
            <xd:p><xd:b>Author:</xd:b> agnesseipelt</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    
    <xsl:function name="custom:getKeyData" as="node()">
        <xsl:param name="file" as="node()"/>
        <xsl:param name="profile" as="xs:string"/>
        <xsl:param name="windowSize" as="xs:integer"/>
        
        <xsl:variable name="measures" select="$file//mei:measure" as="node()*"/>
        <xsl:variable name="windows" as="node()*">
            <xsl:for-each select="(1 to (count($measures) - $windowSize +1))">
                <xsl:variable name="pos" select="." as="xs:integer"/>
                <xsl:variable name="first.measure" select="$measures[$pos]" as="node()"/>
                <xsl:variable name="following.measures" select="$first.measure/following::mei:measure[position() lt $windowSize]" as="node()*"/>
                <xsl:variable name="this.windows.measures" select="$first.measure | $following.measures" as="node()+"/>
                <xsl:variable name="histogram" as="xs:double*">
                    <xsl:for-each select="(1 to 12)">
                        <xsl:variable name="pitch" select="." as="xs:integer"/>
                        <xsl:value-of select="sum($this.windows.measures/mei:harm[@type='histogram']/number(tokenize(text(), '-')[$pitch]))"/>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:variable name="ks.result" select="custom:getKrumhanslSchmuckler($histogram,$profile,1)" as="node()"/>
                <xsl:for-each select="$this.windows.measures">
                    <measure id="{@xml:id}" n="{@n}">
                       <key name="{$ks.result/@name}"/> 
                    </measure>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="used.keys" select="distinct-values($windows//key/@name)" as="xs:string+"/>
        
        <profile type="{$profile}" keys="{string-join($used.keys,' ')}">
            <xsl:for-each select="$measures">
                <xsl:variable name="current.measure" select="." as="node()"/>
                <xsl:variable name="matches" select="$windows/self::measure[@id = $current.measure/@xml:id]" as="node()+"/>
                <measure xml:id="{$current.measure/@xml:id}" n="{$current.measure/@n}">
                    <xsl:for-each select="distinct-values($matches//@name)">
                        <xsl:variable name="current.key" select="." as="xs:string"/>
                        <key name="{$current.key}" index="{index-of($used.keys,$current.key)}"/>
                    </xsl:for-each>    
                </measure>                     
            </xsl:for-each>
        </profile>
        
    </xsl:function>
    
</xsl:stylesheet>
