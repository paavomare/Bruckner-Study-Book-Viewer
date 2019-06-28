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
    
    <xsl:template match="mei:measure" mode="determine.pitch">
        <xsl:variable name="added.normalized.pitch" as="node()*">
            <xsl:apply-templates select="child::node()" mode="determine.pitch_add.normalized.pitch"/>
        </xsl:variable>
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:apply-templates select="$added.normalized.pitch" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="mei:staff" mode="determine.pitch_add.normalized.pitch">
        <xsl:param name="current.key" tunnel="yes"/>
        <xsl:variable name="staff.n" select="@n" as="xs:string"/>
        <xsl:variable name="staffDef.keysig" select="preceding::mei:scoreDef[.//@key.sig][1]//mei:staffDef[@n = $staff.n][@trans.diat and @key.sig]/@key.sig" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="not($staffDef.keysig)">
                <xsl:next-match/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="master.key" select="$circle.of.fifths//key:*[@name = $current.key]" as="node()"/>
                <xsl:variable name="local.key" select="$circle.of.fifths//key:*[@sig = $staffDef.keysig and local-name() = local-name($master.key)]" as="node()"/>
                <xsl:next-match>
                    <xsl:with-param name="current.key" select="$local.key" tunnel="yes"/>
                </xsl:next-match>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    <xsl:template match="mei:note" mode="determine.pitch_add.normalized.pitch">
        <xsl:param name="current.key" tunnel="yes"/>
        <xsl:copy>
            <xsl:attribute name="pitch" select="custom:qualifyPitch(., $current.key)"/>
            <xsl:attribute name="rel.oct" select="custom:determineOct(., $current.key)"/>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- required only as exist-db doesn't support the regular math:pow function: bug! -->
    <xsl:function name="math:pow">
        <xsl:param name="base"/>
        <xsl:param name="power"/>
        <xsl:choose>
            <xsl:when test="number($base) != $base or number($power) != $power">
                <xsl:value-of select="'NaN'"/>
            </xsl:when>
            <xsl:when test="$power = 0">
                <xsl:value-of select="1"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$base * math:pow($base, $power - 1)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="custom:qualifyPitch" as="xs:string">
        <xsl:param name="note" as="node()" required="yes"/>
        <xsl:param name="key" as="xs:string" required="yes"/>
        
        <xsl:variable name="key.elem" select="$circle.of.fifths//key:*[@name = $key]" as="node()?"/>
        
        <xsl:if test="not($key.elem)">
            <xsl:message select="'Unable to get key ' || $key" terminate="yes"/>
        </xsl:if>
        
        <xsl:variable name="base.step" select="number($key.elem//@*[local-name() = $note/@pname])" as="xs:double"/>
        
        <xsl:variable name="local.accid.name" as="xs:string">
            <xsl:choose>
                <xsl:when test="$note//@accid and $note//@accid.ges">
                    <xsl:value-of select="$note//@accid.ges"/>
                </xsl:when>
                <xsl:when test="$note//@accid">
                    <xsl:value-of select="$note//@accid"/>
                </xsl:when>
                <xsl:when test="$note//@accid.ges">
                    <xsl:value-of select="$note//@accid.ges"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'n'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="local.accid.value" select="$accidental.values/descendant-or-self::key:accid.value/number(@*[local-name() = $local.accid.name])" as="xs:double"/>
        
        <xsl:variable name="regular.accid.value" select="number($key.elem/parent::key:pos/@*[local-name() = $note/@pname])" as="xs:double"/>
        <xsl:variable name="accid.diff" select="$local.accid.value - $regular.accid.value" as="xs:double"/>
        
        <xsl:variable name="step.mod" as="xs:string">
            <xsl:choose>
                <xsl:when test="$accid.diff = -3">
                    <xsl:value-of select="'---'"/>
                </xsl:when>
                <xsl:when test="$accid.diff = -2">
                    <xsl:value-of select="'--'"/>
                </xsl:when>
                <xsl:when test="$accid.diff = -1">
                    <xsl:value-of select="'-'"/>
                </xsl:when>
                <xsl:when test="$accid.diff = 0">
                    <xsl:value-of select="''"/>
                </xsl:when>
                <xsl:when test="$accid.diff = 1">
                    <xsl:value-of select="'+'"/>
                </xsl:when>
                <xsl:when test="$accid.diff = 2">
                    <xsl:value-of select="'++'"/>
                </xsl:when>
                <xsl:when test="$accid.diff = 3">
                    <xsl:value-of select="'+++'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="concat($base.step,$step.mod)"/>
    </xsl:function>
    <xsl:function name="custom:determineOct" as="xs:string">
        <xsl:param name="note" as="node()" required="yes"/>
        <xsl:param name="key" as="xs:string" required="yes"/>
        <xsl:variable name="pitches" select="('c','d','e','f','g','a','b')" as="xs:string+"/>
        <xsl:variable name="index.of.key" select="index-of($pitches,lower-case(substring($key,1,1)))" as="xs:integer"/>
        <xsl:variable name="index.of.pname" select="index-of($pitches,$note/@pname)" as="xs:integer"/>
        <xsl:variable name="oct.mod" as="xs:integer">
            <xsl:choose>
                <xsl:when test="$index.of.key = 1">
                    <xsl:value-of select="0"/>
                </xsl:when>
                <xsl:when test="$index.of.key = 2 and $index.of.pname = 7">
                    <xsl:value-of select="-1"/>
                </xsl:when>
                <xsl:when test="$index.of.key = 3 and $index.of.pname lt 3">
                    <xsl:value-of select="-1"/>
                </xsl:when>
                <xsl:when test="$index.of.key = 4 and $index.of.pname lt 4">
                    <xsl:value-of select="-1"/>
                </xsl:when>
                <xsl:when test="$index.of.key = 5 and $index.of.pname ge 5">
                    <xsl:value-of select="1"/>
                </xsl:when>
                <xsl:when test="$index.of.key = 6 and $index.of.pname ge 6">
                    <xsl:value-of select="1"/>
                </xsl:when>
                <xsl:when test="$index.of.key = 7 and $index.of.pname = 7">
                    <xsl:value-of select="1"/>
                </xsl:when>
                <!--<xsl:when test="$index.of.pname lt $index.of.key">
                    <xsl:value-of select="-1"/>
                </xsl:when>-->
                <xsl:otherwise>
                    <xsl:value-of select="0"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="output" select="string($note/number(@oct) + $oct.mod)" as="xs:string"/>
        <xsl:value-of select="$output"/>
    </xsl:function>
</xsl:stylesheet>