<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:custom="none" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:uuid="http://www.uuid.org" exclude-result-prefixes="xs math xd mei custom uuid" version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Mar 26, 2018</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p>
                Algorithm implemented according to http://extras.humdrum.org/man/keycor/
                Attention: Simple profile uses 1, 0 for last two values of minor vector,
                other than stated on that website!
            </xd:p>
        </xd:desc>
    </xd:doc>

    <!-- requires circleOf5.xsl -->
    <!-- requires determine.pnum.xsl -->

    <!--<xsl:include href="determine.pnum.xsl"/>
    <xsl:include href="circleOf5.xsl"/>-->

    <xsl:function name="custom:getKrumhanslSchmuckler">
        <xsl:param name="input" as="xs:double*"/>
        <xsl:param name="profile" as="xs:string"/>
        <xsl:param name="best.n.matches" as="xs:integer"/>

        <xsl:variable name="keys" select="('C','Db','D','Eb','E','F','F#','G','Ab','A','Bb','B','Cm','C#m','Dm','Ebm','Em','Fm','F#m','Gm','G#m','Am','Bbm','Bm')" as="xs:string*"/>

        <!--  -->
        <xsl:variable name="ks.profile.simple" select="(2,0,1,0,1,1,0,2,0,1,0,1,2,0,1,1,0,1,0,2,1,0,1,0)" as="xs:double*"/>
        <xsl:variable name="ks.profile.krumhansl.kessler" select="(6.35,2.23,3.48,2.33,4.38,4.09,2.52,5.19,2.39,3.66,2.29,2.88,6.33,2.68,3.52,5.38,2.60,3.53,2.54,4.75,3.98,2.69,3.34,3.17)" as="xs:double*"/>
        <xsl:variable name="ks.profile.aarden.essen" select="(17.7661,0.145624,14.9265,0.160186,19.8049,11.3587,0.291248,22.062,0.145624,8.15494,0.232998,4.95122,18.2648,0.737619,14.0499,16.8599,0.702494,14.4362,0.702494,18.6161,4.56621,1.93186,7.37619,1.75623)" as="xs:double*"/>
        <xsl:variable name="ks.profile.bellman.budge" select="(16.8,0.86,12.95,1.41,13.49,11.93,1.25,20.28,1.8,8.04,0.62,10.57,18.16,0.69,12.99,13.34,1.07,11.15,1.38,21.07,7.49,1.53,0.92,10.21)" as="xs:double*"/>
        <xsl:variable name="ks.profile.temperley.kostka.payne" select="(0.748,0.06,0.488,0.082,0.067,0.46,0.096,0.715,0.104,0.366,0.057,0.4,0.712,0.084,0.474,0.618,0.049,0.460,0.105,0.747,0.404,0.067,0.133,0.33)" as="xs:double*"/>


        <xsl:variable name="comparison" as="xs:double*">
            <xsl:choose>
                <xsl:when test="$profile = 'simple'">
                    <xsl:sequence select="$ks.profile.simple"/>
                </xsl:when>
                <xsl:when test="$profile = 'krumhansl'">
                    <xsl:sequence select="$ks.profile.krumhansl.kessler"/>
                </xsl:when>
                <xsl:when test="$profile = 'aarden'">
                    <xsl:sequence select="$ks.profile.aarden.essen"/>
                </xsl:when>
                <xsl:when test="$profile = 'bellman'">
                    <xsl:sequence select="$ks.profile.bellman.budge"/>
                </xsl:when>
                <xsl:when test="$profile = 'temperley'">
                    <xsl:sequence select="$ks.profile.temperley.kostka.payne"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$ks.profile.simple"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="major" select="$comparison[position() lt 13]" as="xs:double*"/>
        <xsl:variable name="minor" select="$comparison[position() gt 12]" as="xs:double*"/>

        <xsl:variable name="results" as="node()*">
            <xsl:for-each select="1 to count($comparison)">
                <xsl:variable name="key.pos" select="position()" as="xs:integer"/><!-- 1 to 24 -->

                <xsl:variable name="this.comparison" as="xs:double*">
                    <xsl:for-each select="1 to 12">
                        <xsl:variable name="pitch.pos" select="." as="xs:integer"/><!-- 1 to 12 -->

                        <xsl:choose>
                            <!-- major mode -->
                            <xsl:when test="$key.pos lt 13">
                                <xsl:variable name="required.pos" select="(13 - $key.pos + $pitch.pos) mod 12" as="xs:integer"/>
                                <!-- don't ask, we've tested this properly ;-) -->
                                <xsl:value-of select="if($required.pos = 0) then($major[12]) else($major[$required.pos])"/>
                            </xsl:when>
                            <!-- minor mode -->
                            <xsl:otherwise>
                                <xsl:variable name="required.pos" select="(13 - ($key.pos mod 12) + $pitch.pos) mod 12" as="xs:integer"/>
                                <!-- don't ask, we've tested this properly ;-) -->
                                <xsl:value-of select="if($required.pos = 0) then($minor[12]) else($minor[$required.pos])"/>
                            </xsl:otherwise>
                        </xsl:choose>


                    </xsl:for-each>
                </xsl:variable>

                <xsl:variable name="input.sum" select="sum($input) div count($input)" as="xs:double"/>
                <xsl:variable name="comparison.sum" select="sum($this.comparison) div count($this.comparison)" as="xs:double"/>

                <xsl:variable name="x.values" as="xs:double*">
                    <xsl:for-each select="1 to 12">
                        <xsl:variable name="pos" select="position()"/>
                        <xsl:value-of select="$input[$pos] - $input.sum"/>
                    </xsl:for-each>
                </xsl:variable>

                <xsl:variable name="y.values" as="xs:double*">
                    <xsl:for-each select="1 to 12">
                        <xsl:variable name="pos" select="position()"/>
                        <xsl:value-of select="$this.comparison[$pos] - $comparison.sum"/>
                    </xsl:for-each>
                </xsl:variable>

                <xsl:variable name="x.times.y" as="xs:double*">
                    <xsl:for-each select="1 to 12">
                        <xsl:variable name="pos" select="position()"/>
                        <xsl:value-of select="$x.values[$pos] * $y.values[$pos]"/>
                    </xsl:for-each>
                </xsl:variable>

                <xsl:variable name="x.times2" as="xs:double*">
                    <xsl:for-each select="1 to 12">
                        <xsl:variable name="pos" select="position()"/>
                        <xsl:value-of select="math:pow($x.values[$pos],2)"/>
                    </xsl:for-each>
                </xsl:variable>

                <xsl:variable name="y.times2" as="xs:double*">
                    <xsl:for-each select="1 to 12">
                        <xsl:variable name="pos" select="position()"/>
                        <xsl:value-of select="math:pow($y.values[$pos],2)"/>
                    </xsl:for-each>
                </xsl:variable>

                <xsl:variable name="ratio" select="sum($x.times.y) div (math:sqrt((sum($x.times2) * sum($y.times2))))" as="xs:double"/>

                <key xmlns="none" profile="{$profile}" name="{$keys[$key.pos]}" rating="{round($ratio,3)}"/>

            </xsl:for-each>
        </xsl:variable>

        <xsl:for-each select="$results">
            <xsl:sort select="@rating" data-type="number" order="descending"/>
            <xsl:if test="position() le $best.n.matches">
                <xsl:copy-of select="."/>
            </xsl:if>
        </xsl:for-each>

    </xsl:function>

    <xsl:function name="custom:getKrumhanslSchmucklerHistogram" as="xs:double*">
        <xsl:param name="input" as="node()*"/>
        <xsl:param name="weighted.by.duration" as="xs:boolean"/>

        <xsl:variable name="identified.pitches">
            <xsl:apply-templates select="$input" mode="ks.add.chroma"/>
        </xsl:variable>

        <xsl:for-each select="1 to 12">
            <xsl:variable name="i" select="." as="xs:integer"/>
            <xsl:variable name="relevant.notes" select="$identified.pitches//mei:note[@chroma = $i]" as="node()*"/>

            <xsl:choose>
                <xsl:when test="$weighted.by.duration">
                    <xsl:variable name="relevant.durations" as="xs:double*">
                        <xsl:for-each select="$relevant.notes">
                            <xsl:value-of select="number(ancestor-or-self::mei:*/@tstamp2) - number(ancestor-or-self::mei:*/@tstamp)"/>
                        </xsl:for-each>
                    </xsl:variable>

                    <xsl:value-of select="sum($relevant.durations)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="count($relevant.notes)"/>
                </xsl:otherwise>
            </xsl:choose>


        </xsl:for-each>
    </xsl:function>

    <xsl:template match="mei:staff[not(parent::mei:ossia)]" mode="ks.add.chroma">
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

    <xsl:template match="mei:note" mode="ks.add.chroma">
        <xsl:param name="trans.semi" as="xs:integer" tunnel="yes" select="0"/>

        <!-- chroma is 1-12 for each (sounding) pitch class, 1=C, 2=C#, 3=D, …  -->
        <xsl:variable name="chroma" select="xs:integer(custom:getPnum(.,$trans.semi)) mod 12 + 1" as="xs:integer"/>

        <xsl:copy>
            <xsl:attribute name="chroma" select="$chroma"/>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
