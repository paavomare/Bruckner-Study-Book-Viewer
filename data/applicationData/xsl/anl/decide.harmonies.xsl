<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:tools="no:link"
    exclude-result-prefixes="xs math xd mei tools"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> May 28, 2019</xd:p>
            <xd:p><xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p>This stylesheets treis to identify the right sequence of harm elements
            </xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:template match="mei:section" mode="decide.harmonies">
        
        <xsl:variable name="section" select="." as="node()"/>
        <xsl:variable name="found.keys" select="distinct-values(.//mei:choice[@type='harmInterpretation']/@key)" as="xs:string+"/>
        
        <xsl:variable name="sequences" as="xs:string*">
            <xsl:for-each select="$found.keys">
                <xsl:variable name="current.key" select="." as="xs:string"/>
                <xsl:variable name="harm.choices" as="node()*">
                    <xsl:for-each select="$section//mei:choice[@type = 'harmInterpretation'][@key = $current.key]">
                        <xsl:sort select="@measure" data-type="number" order="descending"/>
                        <xsl:sort select="@tstamp" data-type="number" order="descending"/>
                        <xsl:sequence select="."/>
                    </xsl:for-each>
                </xsl:variable>
                
                <xsl:value-of select="tools:findBestPrecedingHarmony($harm.choices,1,count($harm.choices),'')"/>
                
            </xsl:for-each>    
        </xsl:variable>
        
        <xsl:apply-templates select="." mode="decide.harmonies.pick.harms">
            <xsl:with-param name="harm.ids" select="tokenize(normalize-space(string-join($sequences,' ')),' ')" as="xs:string*" tunnel="yes"/>
        </xsl:apply-templates>
        
    </xsl:template>
    
    <xsl:template match="mei:choice[@type = 'harmInterpretation']" mode="decide.harmonies.pick.harms">
        <xsl:param name="harm.ids" as="xs:string*" tunnel="yes"/>
        
        <xsl:choose>
            <xsl:when test="count(.//mei:harm) = 1">
                <xsl:apply-templates select=".//mei:harm" mode="#current"/>
            </xsl:when>
            <xsl:when test="exists(.//mei:harm[@xml:id = $harm.ids])">
                <xsl:apply-templates select=".//mei:harm[@xml:id = $harm.ids]" mode="#current"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message select="."/>
                <xsl:message terminate="yes" select="'There should be a reference in $harm.ids… ' || ancestor::mei:measure/@n"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:function name="tools:findBestPrecedingHarmony" as="xs:string*">
        <xsl:param name="harms" as="node()*"/>
        <xsl:param name="index" as="xs:integer"/>
        <xsl:param name="last.index" as="xs:integer"/>
        <xsl:param name="selected.harm.id" as="xs:string"/>
        
        <xsl:variable name="current.harm" as="node()?">
            <xsl:choose>
                <xsl:when test="$index = 1">
                    <xsl:sequence select="($harms[1]//mei:harm)[1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$harms[$index]//mei:harm[@xml:id = $selected.harm.id]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="next.harm.id" as="xs:string">
            <xsl:choose>
               <xsl:when test="count($harms[$index + 1]//mei:harm) gt 1">
                   <!--<xsl:message select="'At index ' || ($index + 1) || ', there are ' || count($harms[$index + 1]//mei:harm) || ' harms'"/>-->
                   
                   <xsl:variable name="evaluation" as="node()+">
                       <xsl:for-each select="$harms[$index + 1]//mei:harm">
                           <xsl:variable name="preceding.harm" select="." as="node()"/>
                           <xsl:sequence select="tools:evaluateProgression($preceding.harm,$current.harm)"/>
                       </xsl:for-each>
                   </xsl:variable>
                   
                   <xsl:variable name="highest.rating" select="string(max($evaluation/number(@rating)))" as="xs:string"/>
                   
                   <xsl:if test="'d36446e0' = $harms[$index + 1]//mei:harm/@xml:id">
                       <xsl:message select="'Starting at ' || string-join($current.harm/mei:rend/text())"/>
                       <xsl:for-each select="$evaluation">
                           <xsl:variable name="pos" select="position()"/>
                           <xsl:message select="'    ' || string-join(($harms[$index + 1]//mei:harm)[$pos]/mei:rend/text()) || ': rating = ' || @rating"/>
                       </xsl:for-each>
                       <xsl:message select="'        Picking ' || ($evaluation[@rating = $highest.rating])[1]/@prev.chord || ' at ' || ($evaluation[@rating = $highest.rating])[1]/@prev.id"/>
                       
                       <xsl:message select="string(($evaluation[@rating = $highest.rating])[1]/@prev.id)"/>
                   </xsl:if>
                   
                   <!-- DEBUG -->
                   <!--<xsl:message select="'Starting at ' || string-join($current.harm/mei:rend/text())"/>
                   <xsl:for-each select="$evaluation">
                       <xsl:variable name="pos" select="position()"/>
                       <xsl:message select="'    ' || string-join(($harms[$index + 1]//mei:harm)[$pos]/mei:rend/text()) || ': rating = ' || @rating"/>
                   </xsl:for-each>
                   <xsl:message select="'        Picking ' || ($evaluation[@rating = $highest.rating])[1]/@prev.chord || ' at ' || ($evaluation[@rating = $highest.rating])[1]/@prev.id"/>-->
                   
                   <xsl:value-of select="string(($evaluation[@rating = $highest.rating])[1]/@prev.id)"/>
                   
               </xsl:when>
               <xsl:otherwise>
                   <xsl:value-of select="$harms[$index + 1]//mei:harm/@xml:id"/>
               </xsl:otherwise>
           </xsl:choose>
        </xsl:variable>
        
        <xsl:value-of select="$current.harm/@xml:id"/>
        
        <!-- DEBUG -->
        <!--<xsl:message select="'Next ID at : ' || $index || ': ' || $next.harm.id"/>-->
        
        <xsl:if test="$index lt $last.index">
            <xsl:value-of select="tools:findBestPrecedingHarmony($harms,($index + 1),$last.index,$next.harm.id)"/>
        </xsl:if>
        
    </xsl:function>
    
    <xsl:function name="tools:evaluateProgression" as="node()">
        <xsl:param name="prev.harm" as="node()"/>
        <xsl:param name="next.harm" as="node()"/>
        
        <xsl:variable name="prev.root" select="$prev.harm/mei:rend[@type='root']/text()" as="xs:string"/>
        <xsl:variable name="next.root" select="$next.harm/mei:rend[@type='root']/text()" as="xs:string"/>
        
        <xsl:variable name="sus.types" select="$prev.harm//mei:annot[ends-with(@type,'sus')]" as="node()*"/>
        <xsl:variable name="ret.types" select="$prev.harm//mei:annot[ends-with(@type,'ret')]" as="node()*"/>
        
        <xsl:variable name="sus.notes.count" select="sum($sus.types/count(tokenize(@plist,' ')))" as="xs:integer"/>
        <xsl:variable name="ret.notes.count" select="sum($ret.types/count(tokenize(@plist,' ')))" as="xs:integer"/>
        
        <xsl:variable name="factors" as="xs:double*">
            
            <xsl:choose>
                <!-- same root: suspensions are good -->
                <xsl:when test="$prev.root = $next.root">
                    <xsl:value-of select="(count($sus.types) + count($ret.types)) * 1"/>
                    <xsl:value-of select="($sus.notes.count + $ret.notes.count) * .5"/>
                </xsl:when>
                <!-- different root: suspensions are bad -->
                <xsl:otherwise>
                    <xsl:value-of select="(count($sus.types) + count($ret.types)) * -1"/>
                    <xsl:value-of select="($sus.notes.count + $ret.notes.count) * -.5"/>
                </xsl:otherwise>
            </xsl:choose>
            
            <xsl:if test="$prev.root = $next.root">
                <xsl:value-of select=".1"/>
            </xsl:if>
            
            <xsl:if test="$prev.root = 'V' and $next.root = 'I'">
                <xsl:value-of select="1"/>
            </xsl:if>
            
            <xsl:if test="$prev.root = 'IV' and $next.root = 'I'">
                <xsl:value-of select=".7"/>
            </xsl:if>
            
            <xsl:if test="$prev.root = 'I' and $next.root = 'IV'">
                <xsl:value-of select=".1"/>
            </xsl:if>
            
            <xsl:if test="$prev.root = 'IV' and $next.root = 'V'">
                <xsl:value-of select=".8"/>
            </xsl:if>
            
            <xsl:if test="$prev.root = 'II' and $next.root = 'V'">
                <xsl:value-of select=".4"/>
            </xsl:if>
            
            <!-- this is probably a rootless D7 -->
            <xsl:if test="$prev.root = 'VII' and $next.root = 'I'">
                <xsl:value-of select=".9"/>
            </xsl:if>
            
            <xsl:value-of select="0"/>
        </xsl:variable>
        
        <evaluation rating="{sum($factors)}" prev.id="{$prev.harm/@xml:id}" prev.chord="{string-join($prev.harm/mei:rend/text())}" next.id="{$next.harm/@xml:id}"/>
        
    </xsl:function>
    
</xsl:stylesheet>