<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:custom="none" xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:uuid="http://www.uuid.org" exclude-result-prefixes="xs math xd mei custom uuid" version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Mar 26, 2018</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mei:measure" mode="determine.roman.numerals">
        <xsl:param name="current.key" tunnel="yes"/>
        <xsl:param name="all.keys" tunnel="yes"/>
                
        <xsl:variable name="measure" select="." as="node()"/>
        
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
            <xsl:variable name="events" select=".//mei:layer//mei:*[@tstamp and @tstamp2 and local-name() = ('note','chord')]" as="node()*"/>
            <xsl:variable name="tstamps" select="distinct-values(.//@tstamp)" as="xs:string*"/>
            
            <xsl:for-each select="$tstamps">
                <xsl:sort select="." data-type="number"/>
                <xsl:variable name="current.tstamp" select="." as="xs:string"/>
                <xsl:variable name="current.notes" select="$events[number(@tstamp) le number($current.tstamp) and number(@tstamp2) gt number($current.tstamp)]/descendant-or-self::mei:note" as="node()*"/>
                <xsl:variable name="current.pitches" select="distinct-values($current.notes//@pitch)" as="xs:string*"/>
                <xsl:if test="count($current.pitches) gt 0">
                    <xsl:variable name="romanNumeral" select="custom:identifyRomanNumeral($current.pitches)" as="xs:string?"/>
                    <xsl:choose>
                        <xsl:when test="exists($romanNumeral)">
                            <harm xmlns="http://www.music-encoding.org/ns/mei">
                                <xsl:attribute name="tstamp" select="$current.tstamp"/>
                                <xsl:attribute name="staff" select="max($measure/mei:staff/number(@n))"/>
                                <xsl:attribute name="place" select="'below'"/>
                                <xsl:attribute name="n" select="index-of($all.keys,$current.key)"/>
                                <xsl:attribute name="type" select="$current.key"/>
                                <!--<rend fontweight="bold">-->
                                    <xsl:value-of select="$romanNumeral"/>
                                <!--</rend>-->
                            </harm>
                        </xsl:when>
                        <xsl:when test="count($current.pitches) gt 1">
                            <!-- when there is a single note, don't render a harm -->
                            <harm xmlns="http://www.music-encoding.org/ns/mei">
                                <xsl:attribute name="tstamp" select="$current.tstamp"/>
                                <xsl:attribute name="staff" select="max($measure/mei:staff/number(@n))"/>
                                <xsl:attribute name="place" select="'below'"/>
                                <xsl:attribute name="n" select="index-of($all.keys,$current.key)"/>
                                <xsl:variable name="pitches" as="xs:string*">
                                    <xsl:for-each select="$current.pitches">
                                        <xsl:sort select="substring(.,1,1)" data-type="number" order="descending"/>
                                        <xsl:variable name="current.pos" select="position()" as="xs:integer"/>
                                        <xsl:value-of select="."/>                                        
                                    </xsl:for-each>
                                </xsl:variable>
                                <xsl:attribute name="type" select="$current.key || ' ' || string-join($pitches,'-')"/>
                                <rend fontstyle="italic">
                                    <xsl:value-of select="'?'"/>
                                </rend>
                            </harm>
                            
                            
                        </xsl:when>
                    </xsl:choose>
                </xsl:if>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
            
    <xsl:function name="custom:identifyRomanNumeral" as="xs:string?">
        <xsl:param name="pitches" as="xs:string+"/>
        <xsl:variable name="input" as="xs:string+">
            <xsl:for-each select="$pitches">
                <xsl:sort select="substring(.,1,1)" order="ascending" data-type="number"/>
                <xsl:value-of select="."/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="string-join($input,'') = '135'">
                <xsl:value-of select="'I'"/>
            </xsl:when>
            <xsl:when test="string-join($input,'') = '13'">
                <xsl:value-of select="'I'"/>
            </xsl:when>
            <xsl:when test="string-join($input,'') = '15'">
                <xsl:value-of select="'I'"/>
            </xsl:when>
            <xsl:when test="string-join($input,'') = '146'">
                <xsl:value-of select="'IV'"/>
            </xsl:when>
            <xsl:when test="string-join($input,'') = '46'"><!-- less sure -->
                <xsl:value-of select="'IV'"/>
            </xsl:when>
            <xsl:when test="string-join($input,'') = '257'">
                <xsl:value-of select="'V'"/>
            </xsl:when>
            <xsl:when test="string-join($input,'') = '2457'">
                <xsl:value-of select="'V7'"/>
            </xsl:when>
            <xsl:when test="string-join($input,'') = '245'"><!-- here without 5 -->
                <xsl:value-of select="'V7'"/>
            </xsl:when>
            <xsl:when test="string-join($input,'') = '246'">
                <xsl:value-of select="'II'"/>
            </xsl:when>
            <xsl:when test="string-join($input,'') = '357'">
                <xsl:value-of select="'III'"/>
            </xsl:when>
            <xsl:when test="string-join($input,'') = '136'">
                <xsl:value-of select="'VI'"/>
            </xsl:when>
            <xsl:when test="string-join($input,'') = '247'">
                <xsl:value-of select="'VII'"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- DEBUG -->
                <!--<xsl:message select="'Unable to understand pitches ' || string-join($input,' ')"/>-->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>