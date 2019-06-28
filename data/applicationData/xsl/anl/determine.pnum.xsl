<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:key="none" xmlns:custom="none" xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:uuid="http://www.uuid.org" exclude-result-prefixes="xs math xd mei custom uuid" version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Mar 26, 2018</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    
    <!-- requires circleOf5.xsl -->
    
    <xsl:template match="mei:staff">
        <xsl:variable name="n" select="@n" as="xs:string"/>
        
        <xsl:variable name="staffDef" select="preceding::mei:staffDef[@n = $n and @trans.semi][1]" as="node()?"/>
        <xsl:variable name="trans.semi" as="xs:integer">
            <xsl:choose>
                <xsl:when test="exists($staffDef)">
                    <xsl:value-of select="xs:integer($staffDef/@trans.semi)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="0"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:next-match>
            <xsl:with-param name="trans.semi" select="$trans.semi" as="xs:integer" tunnel="yes"/>
        </xsl:next-match>
    </xsl:template>
    
    <xsl:template match="mei:note" mode="determine.pnum">
        <xsl:param name="trans.semi" tunnel="yes"/>
        
        <xsl:variable name="offset">
            <xsl:choose>
                <xsl:when test="not($trans.semi instance of xs:integer)">
                    <xsl:value-of select="0"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$trans.semi"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:copy>
            <xsl:attribute name="pnum" select="custom:getPnum(.,$offset)"/>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:function name="custom:getPnum" as="xs:string">
        <xsl:param name="note" as="node()"/>
        <xsl:param name="trans.semi" as="xs:integer"/>
        
        <xsl:variable name="oct" select="xs:integer($note/@oct) * 12" as="xs:integer"/>
        <xsl:variable name="pname" as="xs:integer">
            <xsl:choose>
                <xsl:when test="$note/@pname = 'c'">
                    <xsl:value-of select="0"/>
                </xsl:when>
                <xsl:when test="$note/@pname = 'd'">
                    <xsl:value-of select="2"/>
                </xsl:when>
                <xsl:when test="$note/@pname = 'e'">
                    <xsl:value-of select="4"/>
                </xsl:when>
                <xsl:when test="$note/@pname = 'f'">
                    <xsl:value-of select="5"/>
                </xsl:when>
                <xsl:when test="$note/@pname = 'g'">
                    <xsl:value-of select="7"/>
                </xsl:when>
                <xsl:when test="$note/@pname = 'a'">
                    <xsl:value-of select="9"/>
                </xsl:when>
                <xsl:when test="$note/@pname = 'b'">
                    <xsl:value-of select="11"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="accid" as="xs:integer">
            <xsl:choose>
                <xsl:when test="$note//@accid.ges">
                    <xsl:value-of select="xs:integer($accidental.values/descendant-or-self::key:accid.value/@*[local-name() = ($note//@accid.ges)[1]])"/>
                </xsl:when>
                <xsl:when test="$note//@accid">
                    <xsl:value-of select="xs:integer($accidental.values/descendant-or-self::key:accid.value/@*[local-name() = ($note//@accid)[1]])"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="0"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- the midi.offset is used to make @pnum compatible with MIDI piano numbers, where A0 = 1 -->
        <xsl:variable name="midi.offset" select="12" as="xs:integer"/>
        <xsl:value-of select="$pname + $oct + $accid + $trans.semi + $midi.offset"/>
    </xsl:function>
    
</xsl:stylesheet>