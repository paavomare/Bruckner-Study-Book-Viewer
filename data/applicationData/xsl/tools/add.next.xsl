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
            <xd:p><xd:b>Created on:</xd:b> May 20, 2019</xd:p>
            <xd:p><xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p>This stylesheets adds the @next and @prev attributes to 
            notes, making it possible to follow "voices" through a list of 
            links. It requires @tstamp on all notes. It ignores @cue-notes
            and @grace-notes. It assumes that chords notes are ordered starting
            from the highest pitch downwards. Following measures are identified
            on the following-sibling axis, which means that mei:pb will stop 
            that identification.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:template match="mei:mdiv" mode="add.next">
        
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            
            <xsl:variable name="added.next" as="node()*">
                <xsl:apply-templates select="node()" mode="#current"/>
            </xsl:variable>
            
            <xsl:apply-templates select="$added.next" mode="add.next.add.prev"/>
        </xsl:copy>
        
    </xsl:template>
    
    <xsl:template match="mei:note[not(@grace) and not(@cue) and not(@next)]" mode="add.next">
        <xsl:variable name="current.layer" select="ancestor::mei:layer" as="node()"/>
        <xsl:variable name="current.staff" select="ancestor::mei:staff" as="node()"/>
        
        <xsl:if test="not(ancestor-or-self::mei:*/@tstamp)">
            <xsl:message terminate="yes" select="'[ERROR] //note/@xml:id=&quot;' || @xml:id || '&quot; has no @tstamp. Unable to generate @next. Processing stopped.'"/>
        </xsl:if>
        
        <!-- DEBUG -->
        <!--<xsl:if test="@xml:id = 'kitzler_061_m-81'">
            <xsl:message select="'Testing note kitzler_061_m-81'"/>
        </xsl:if>-->
        
        <!-- get current tstamp -->
        <xsl:variable name="current.tstamp" select="number(ancestor-or-self::mei:*/@tstamp)" as="xs:double"/>
        
        <!-- get all later events on staff / layer -->
        <xsl:variable name="later.events.on.staff" select="$current.staff//mei:*[number(@tstamp) gt $current.tstamp]" as="node()*"/>
        <xsl:variable name="later.events.on.layer" select="$current.layer//mei:*[number(@tstamp) gt $current.tstamp]" as="node()*"/>
        
        <!-- get the succeeding tstamp -->
        <xsl:variable name="follow-up.tstamp.on.staff" select="min(distinct-values($later.events.on.staff/number(@tstamp)))" as="xs:double?"/>
        <xsl:variable name="follow-up.tstamp.on.layer" select="min(distinct-values($later.events.on.layer/number(@tstamp)))" as="xs:double?"/>
        
        <!-- get the next events on staff / layer -->
        <xsl:variable name="direct.followers.on.staff" select="if($later.events.on.staff) then($later.events.on.staff[number(@tstamp) = $follow-up.tstamp.on.staff]) else()" as="node()*"/>
        <xsl:variable name="direct.followers.on.layer" select="if($later.events.on.layer) then($later.events.on.layer[number(@tstamp) = $follow-up.tstamp.on.layer]) else()" as="node()*"/>
        
        <!-- identify chords in this situation -->
        <xsl:variable name="this.chorded" select="exists(ancestor::mei:chord)" as="xs:boolean"/>
        <xsl:variable name="staff.successor.chorded" select="if($direct.followers.on.staff) then(every $event in $direct.followers.on.staff satisfies (local-name($event) = 'chord')) else(false())" as="xs:boolean"/>
        <xsl:variable name="layer.successor.chorded" select="if($direct.followers.on.layer) then(every $event in $direct.followers.on.layer satisfies (local-name($event) = 'chord')) else(false())" as="xs:boolean"/>
        
        <!-- identify spaces in this situation -->
        <xsl:variable name="staff.successor.space" select="if($direct.followers.on.staff) then(every $event in $direct.followers.on.staff satisfies (local-name($event) = 'space')) else(false())" as="xs:boolean"/>
        <xsl:variable name="layer.successor.space" select="if($direct.followers.on.layer) then(every $event in $direct.followers.on.layer satisfies (local-name($event) = 'space')) else(false())" as="xs:boolean"/>
        
        <xsl:choose>
            
            <!-- stopped by a rest -->
            <!-- TODO: Check if there are other situations where a rest should stop the chaining -->
            <xsl:when test="exists($direct.followers.on.layer) 
                and local-name($direct.followers.on.layer) = ('rest','space')">
                <xsl:next-match/>
            </xsl:when>
            
            <!-- there should be a direct successor -->
            <xsl:when test="exists($direct.followers.on.layer) 
                and not($this.chorded) 
                and not($layer.successor.chorded) 
                and not($layer.successor.space)">
                <xsl:copy>
                    <xsl:apply-templates select="@*" mode="#current"/>
                    <xsl:attribute name="next" select="'#' || $direct.followers.on.layer[1]/@xml:id"/>
                    <xsl:apply-templates select="node()" mode="#current"/>
                </xsl:copy>
            </xsl:when>
            
            <!-- find corresponding note in chord -->
            <xsl:when test="exists($direct.followers.on.layer) 
                and $this.chorded 
                and $layer.successor.chorded">
                
                <xsl:variable name="this.pos" select="count(preceding-sibling::mei:note) + 1" as="xs:integer"/>
                <xsl:variable name="matching.note" select="if(count($direct.followers.on.layer[1]//mei:note) ge $this.pos) 
                    then($direct.followers.on.layer[1]//mei:note[$this.pos]) 
                    else($direct.followers.on.layer[1]//mei:note[last()])" as="node()"/>
                
                <!-- info: this assumes that chords notes are ordered starting from highest pitch downwards -->
                <xsl:copy>
                    <xsl:apply-templates select="@*" mode="#current"/>
                    <xsl:attribute name="next" select="'#' || $matching.note/@xml:id"/>
                    <xsl:apply-templates select="node()" mode="#current"/>
                </xsl:copy>
            </xsl:when>
            
            <!-- this note isn't part of a chord, but is succeeded by a chord, i.e. voice "splits up" -->
            <xsl:when test="exists($direct.followers.on.layer) 
                and not($this.chorded) 
                and $layer.successor.chorded">
                
                <!-- info: this assumes that chords notes are ordered starting from highest pitch downwards -->
                <xsl:copy>
                    <xsl:apply-templates select="@*" mode="#current"/>
                    <xsl:attribute name="next" select="'#' || $direct.followers.on.layer[1]//mei:note[1]/@xml:id"/>
                    <xsl:apply-templates select="node()" mode="#current"/>    
                </xsl:copy>
                
            </xsl:when>
            
            <!-- this note is part of chord, but is followed by a single note, i.e. voice "unites" -->
            <xsl:when test="exists($direct.followers.on.layer) 
                and $this.chorded 
                and not($layer.successor.chorded) 
                and not($layer.successor.space)">
                
                <xsl:variable name="this.pos" select="count(preceding-sibling::mei:note) + 1" as="xs:integer"/>
                <xsl:choose>
                    
                    <!-- info: this assumes that chords notes are ordered starting from highest pitch downwards -->
                    <xsl:when test="$this.pos = 1">
                        <xsl:copy>
                            <xsl:apply-templates select="@*" mode="#current"/>
                            <xsl:attribute name="next" select="'#' || $direct.followers.on.layer[1]/@xml:id"/>
                            <xsl:apply-templates select="node()" mode="#current"/>
                        </xsl:copy>
                    </xsl:when>
                    
                    <!-- this is probably continued on other layer -->
                    <xsl:when test="exists($direct.followers.on.staff)
                        and $follow-up.tstamp.on.staff = $follow-up.tstamp.on.layer
                        and not($staff.successor.space)">
                        
                        <xsl:variable name="matching.note" select="($direct.followers.on.staff[not(local-name() = 'space')])[last()]" as="node()"/>
                        <xsl:copy>
                            <xsl:apply-templates select="@*" mode="#current"/>
                            <xsl:attribute name="next" select="'#' || $matching.note/@xml:id"/>
                            <xsl:apply-templates select="node()" mode="#current"/>
                        </xsl:copy>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            
            <!-- there is no follower either on the layer or staff, so look for next measure -->
            <xsl:when test="not(exists($direct.followers.on.layer)) 
                and not(exists($direct.followers.on.staff))">
                
                <!--<xsl:if test="@xml:id = 'kitzler_061_m-81'">
                    <xsl:message select="'    should look into next measure now'"/>
                </xsl:if>-->
                
                <xsl:variable name="next.staff" select="ancestor::mei:measure/following-sibling::mei:measure[1]/mei:staff[@n = $current.staff/@n]" as="node()?"/>
                <xsl:choose>
                    <xsl:when test="$next.staff">
                        
                        <xsl:variable name="next.layer" select="if($next.staff/mei:layer/@n = $current.layer/@n)
                            then($next.staff/mei:layer[@n = $current.layer/@n])
                            else($next.staff/mei:layer[1])" as="node()?"/>
                        
                        <!-- get the next events on staff / layer -->
                        <xsl:variable name="measure.followers.on.staff" select="$next.staff//mei:*[@tstamp = '1' and not(local-name() = ('rest','mRest','mSpace'))]" as="node()*"/>
                        <xsl:variable name="measure.followers.on.layer" select="$next.layer//mei:*[@tstamp = '1' and not(local-name() = ('rest','mRest','mSpace'))]" as="node()*"/>
                        
                        <!-- identify chords in this situation -->
                        <xsl:variable name="next.staff.successor.chorded" select="if($measure.followers.on.staff) then(local-name($measure.followers.on.staff) = 'chord') else(false())" as="xs:boolean"/>
                        <xsl:variable name="next.layer.successor.chorded" select="if($measure.followers.on.layer) then(local-name($measure.followers.on.layer) = 'chord') else(false())" as="xs:boolean"/>
                        
                        <!-- identify spaces in this situation -->
                        <xsl:variable name="next.staff.successor.space" select="if($measure.followers.on.staff) then(every $event in $measure.followers.on.staff satisfies (local-name($event) = 'space')) else(false())" as="xs:boolean"/>
                        <xsl:variable name="next.layer.successor.space" select="if($measure.followers.on.layer) then(every $event in $measure.followers.on.layer satisfies (local-name($event) = 'space')) else(false())" as="xs:boolean"/>
                        
                        <!--<xsl:if test="@xml:id = 'kitzler_061_m-81'">
                            <xsl:message select="'  measure.followers.on.layer: ' || string-join($measure.followers.on.layer/@xml:id,', ')"/>
                            <xsl:message select="'  next.layer.successor.chorded: ' || $next.layer.successor.chorded"/>
                            
                        </xsl:if>-->
                        
                        <xsl:choose>
                            
                            <!-- the measure starts with a rest -->
                            <!-- TODO: check for other situations with rests that need to stop the chaining -->
                            <xsl:when test="exists($measure.followers.on.layer) 
                                and local-name($measure.followers.on.layer) = ('rest','space')">
                                
                                <xsl:next-match/>
                                
                            </xsl:when>
                            
                            <!-- this note has a direct successor -->
                            <xsl:when test="exists($measure.followers.on.layer) 
                                and not($this.chorded) 
                                and not($next.layer.successor.chorded) 
                                and not($next.layer.successor.space)">
                                
                                <xsl:copy>
                                    <xsl:apply-templates select="@*" mode="#current"/>
                                    <xsl:attribute name="next" select="'#' || $measure.followers.on.layer[1]/@xml:id"/>
                                    <xsl:apply-templates select="node()" mode="#current"/>
                                </xsl:copy>
                                
                            </xsl:when>
                            
                            <!-- there are chords around -->
                            <xsl:when test="exists($measure.followers.on.layer) 
                                and $this.chorded 
                                and $next.layer.successor.chorded">
                                
                                <!--<xsl:if test="@xml:id = 'kitzler_061_m-81'">
                                    <xsl:message select="'    am I here?'"/>
                                </xsl:if>-->
                                
                                <xsl:variable name="this.pos" select="count(preceding-sibling::mei:note) + 1" as="xs:integer"/>
                                <xsl:variable name="matching.note" select="if(count($measure.followers.on.layer[1]//mei:note) ge $this.pos) 
                                    then($measure.followers.on.layer[1]//mei:note[$this.pos]) 
                                    else($measure.followers.on.layer[1]//mei:note[last()])" as="node()"/>
                                
                                <!-- info: this assumes that chords notes are ordered starting from highest pitch downwards -->
                                <xsl:copy>
                                    <xsl:apply-templates select="@*" mode="#current"/>
                                    <xsl:attribute name="next" select="'#' || $matching.note/@xml:id"/>
                                    <xsl:apply-templates select="node()" mode="#current"/>
                                </xsl:copy>
                                
                            </xsl:when>
                            
                            <!-- this note isn't part of a chord, but is succeeded by a chord, i.e. voice "splits up" -->
                            <xsl:when test="exists($measure.followers.on.layer) 
                                and not($this.chorded) 
                                and $next.layer.successor.chorded">
                                
                                <!-- info: this assumes that chords notes are ordered starting from highest pitch downwards -->
                                <xsl:copy>
                                    <xsl:apply-templates select="@*" mode="#current"/>
                                    <xsl:attribute name="next" select="'#' || $measure.followers.on.layer[1]//mei:note[1]/@xml:id"/>
                                    <xsl:apply-templates select="node()" mode="#current"/>
                                </xsl:copy>
                                
                            </xsl:when>
                            
                            <!-- this note is part of chord, but is followed by a single note, i.e. voice "unites" -->
                            <xsl:when test="exists($measure.followers.on.layer) 
                                and $this.chorded 
                                and not($next.layer.successor.chorded) 
                                and not($next.layer.successor.space)">
                                
                                <xsl:variable name="this.pos" select="count(preceding-sibling::mei:note) + 1" as="xs:integer"/>
                                <xsl:choose>
                                    
                                    <!-- info: this assumes that chords notes are ordered starting from highest pitch downwards -->
                                    <xsl:when test="$this.pos = 1">
                                        
                                        <xsl:copy>
                                            <xsl:apply-templates select="@*" mode="#current"/>
                                            <xsl:attribute name="next" select="'#' || $measure.followers.on.layer[1]/@xml:id"/>
                                            <xsl:apply-templates select="node()" mode="#current"/>    
                                        </xsl:copy>
                                        
                                    </xsl:when>
                                    
                                    <!-- this is probably continued on other layer -->
                                    <xsl:when test="exists($measure.followers.on.staff)
                                        and not($next.staff.successor.space)">
                                        
                                        <xsl:variable name="matching.note" select="($measure.followers.on.staff[not(local-name() = 'space')])[last()]" as="node()"/>
                                        <xsl:copy>
                                            <xsl:apply-templates select="@*" mode="#current"/>
                                            <xsl:attribute name="next" select="'#' || $matching.note/@xml:id"/>
                                            <xsl:apply-templates select="node()" mode="#current"/>
                                        </xsl:copy>
                                        
                                    </xsl:when>
                                    <!-- can't find a potential continuation, so skip @next for this note -->
                                    <xsl:otherwise>
                                        <xsl:next-match/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            
                            <!-- unable to find @next in next measure -->
                            <xsl:otherwise>
                                <xsl:next-match/>
                            </xsl:otherwise>
                        </xsl:choose>
                        
                    </xsl:when>
                    
                    <!-- unable to find @next anywhere -->
                    <xsl:otherwise>
                        <xsl:next-match/>
                    </xsl:otherwise>
                    
                </xsl:choose>
                
            </xsl:when>
            
            <!-- there is probably no successor to be found here, because of rests or so… -->
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="mei:note[not(@grace) and not(@cue) and not(@prev)]" mode="add.next.add.prev">
        <xsl:variable name="ref" select="'#' || @xml:id" as="xs:string"/>
        <xsl:variable name="match" select="ancestor::mei:section//mei:note[@next = $ref]" as="node()*"/>
        
        <!-- DEBUG -->
        <!--<xsl:if test="count($match) gt 1">
            <xsl:message select="'[INFO] //note[@xml:id=&quot;' || @xml:id || '&quot;] is referenced by more than one note through their @next. Only the first note (' || $match[1]/@xml:id || ') is referenced as @prev.'"/>
        </xsl:if>-->
        
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:if test="exists($match)">
                <!-- info: this takes only the first referring note's xml:id -->
                <xsl:attribute name="prev" select="'#' || $match[1]/@xml:id"/>
            </xsl:if>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>