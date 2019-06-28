<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:custom="none" xmlns:bw="http://www.beethovens-werkstatt.de/ns/bw" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xs math xd mei bw custom" version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Mar 23, 2018</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p>
                This file generates a structure where the results of the krumhansl-schmuckler algorithm can be collected
            </xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:template match="mei:measure" mode="add.measure.profiles">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
            <harm xmlns="http://www.music-encoding.org/ns/mei" type="histogram">
                <xsl:value-of select="string-join(custom:getKrumhanslSchmucklerHistogram(.,true()),'-')"/>
            </harm>
        </xsl:copy>
    </xsl:template>
     
    <xsl:template match="mei:mei" mode="generate.ks.profiles">
        <xsl:variable name="input.file" select="." as="node()"/>    
        
        <ks file="{$input.file/@xml:id}">
            <!-- ausrechnen, wie viele verschiedene Längen es gibt -->
            <xsl:variable name="max.length" select="count($input.file//mei:measure)" as="xs:integer"/>           
            <!-- zählt die Takte-->
            
            <xsl:for-each select="(1 to $max.length)">                                                             
                <!--die for-each-Schleife geht über das array von 1 bis max.Taktzahl-->
                <xsl:variable name="current.length" select="." as="xs:integer"/>
                <length l="{$current.length}">                                                                      
                    <!--legt element length mit l= aktuelle Länge an-->
                    <xsl:variable name="last.start" select="$max.length + 1 - $current.length" as="xs:integer"/>    <!--Berechnen, wann der letzte Startpunkt für einen bestimmten Ausschnitt ist: alle Punkte inkl letzter Startpunkt können Startpunkte sein-->
                    
                    <xsl:for-each select="(1 to $last.start)">                                                     
                        <!-- Über alle diese Punkt von 1 bis letzter Start wird eine Schleife zur Berechnung der Endpunkte laufen gelassen-->
                        <xsl:variable name="current.start" select="." as="xs:integer"/>
                        <xsl:variable name="current.end" select="$current.start + $current.length - 1" as="xs:integer"/> <!--Berechnung des aktuellen Endpunkts: Müsste es nicht ohne das -1 sein?? zB startpunkt 2 länge=4 = endpunkt 6?-->
                        <range start="{$current.start}" end="{$current.end}">
                            <xsl:variable name="measures" select="($input.file//mei:measure)[position() ge $current.start and position() le $current.end]" as="node()+"/>
                            
                            <!-- todo: $measures vorprozessieren: alle del etc. rauswerfen -->
                            
                            <!--Adressieren der Takte, die in diesem range liegen: alles was größer oder gleich startpunkt und kleiner oder gleich dem endpunkt ist-->
                            <xsl:variable name="histogram" select="custom:getKrumhanslSchmucklerHistogram($measures,true())" as="xs:double*"/>  <!--Aus diesen Takten wird das Histogram erstellt-->
                            
                            <xsl:attribute name="plist" select="'#' || string-join($measures/@xml:id,' #')"/> 
                            <!--Einfügen eines Attributs plist, das fürs Nachvollziehen/Übersichtlichkeit auf diese Takte verweist-->
                            <xsl:attribute name="histogram" select="string-join((for $value in $histogram return string($value)),'-')"/>
                            
                            <!--Berechnung der 24 Werte mit allen Profilen, speicherung in Variable-->
                            <xsl:variable name="simple" select="custom:getKrumhanslSchmuckler($histogram,'simple',24)" as="node()+"/>
                            <xsl:variable name="krumhansl" select="custom:getKrumhanslSchmuckler($histogram,'krumhansl',24)" as="node()+"/>
                            <xsl:variable name="aarden" select="custom:getKrumhanslSchmuckler($histogram,'aarden',24)" as="node()+"/>
                            <xsl:variable name="bellman" select="custom:getKrumhanslSchmuckler($histogram,'bellman',24)" as="node()+"/>
                            <xsl:variable name="temperley" select="custom:getKrumhanslSchmuckler($histogram,'temperley',24)" as="node()+"/>
                            
                            <!--Kindelemente profile mit Attributen top= bester errechneter Wert für Tonart, es wird aus der variable der Wert an der ersten Stelle genommen und davon das attribut name; @dist zeigt den Unterschied vom ersten top Wert zum zweithöchsten an: das rating, also der score des zweiten werts wird vom ersten abgezogen und auf 3 Stellen gerundet-->
                            <profile type="simple" top="{$simple[1]/@name}" dist="{round(number($simple[1]/@rating) - number($simple[2]/@rating),3)}">
                                <xsl:copy-of select="$simple"/>
                            </profile>
                            <profile type="krumhansl" top="{$krumhansl[1]/@name}" dist="{round(number($krumhansl[1]/@rating) - number($krumhansl[2]/@rating),3)}">
                                <xsl:copy-of select="$krumhansl"/>
                            </profile>
                            <profile type="aarden" top="{$aarden[1]/@name}" dist="{round(number($aarden[1]/@rating) - number($aarden[2]/@rating),3)}">
                                <xsl:copy-of select="$aarden"/>
                            </profile>
                            <profile type="bellman" top="{$bellman[1]/@name}" dist="{round(number($bellman[1]/@rating) - number($bellman[2]/@rating),3)}">
                                <xsl:copy-of select="$bellman"/>
                            </profile>
                            <profile type="temperley" top="{$temperley[1]/@name}" dist="{round(number($temperley[1]/@rating) - number($temperley[2]/@rating),3)}">
                                <xsl:copy-of select="$temperley"/>
                            </profile>
                            
                            <!--Erzeuge ein Profil "mix", mit dem Mittelwert aller Profile-->
                            
                            <xsl:variable name="all.profiles" select="($simple,$krumhansl,$aarden,$bellman,$temperley)" as="node()+"/> <!--schreibe alle Ergebnisse aller Profile in eine variable-->
                            
                            <xsl:variable name="mix.profile" as="node()*">
                                <xsl:for-each select="$simple//@name">
                                    <xsl:variable name="current.key" select="." as="xs:string"/>
                                    <key profile="mix" name="{$current.key}" rating="{round(sum($all.profiles//descendant-or-self::*:key[@name = $current.key]/number(@rating)) div 5 ,3)}"/> <!-- div 5 -->
                                </xsl:for-each>
                            </xsl:variable>
                            
                            <xsl:variable name="sorted.mix.profile" as="node()*">
                                <xsl:for-each select="$mix.profile">
                                    <xsl:sort select="@rating" data-type="number" order="descending"/>
                                    <xsl:copy-of select="."/>
                                </xsl:for-each>
                            </xsl:variable>
                            
                            <profile type="mix" top="{$sorted.mix.profile[1]/@name}" dist="{round(number($sorted.mix.profile[1]/@rating) - number($sorted.mix.profile[2]/@rating),3)}">
                                <xsl:copy-of select="$sorted.mix.profile"/>
                            </profile>
                        </range>
                    </xsl:for-each>
                </length>
            </xsl:for-each>
            
        </ks>
        
    </xsl:template>
            
    <xsl:template match="*:length" mode="generate.keys.list">
        <xsl:param name="mei.file" as="node()" tunnel="yes"/>
        
        <xsl:variable name="current.window.size" select="." as="node()"/>
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            
            <xsl:variable name="measure.ids" select="$mei.file//mei:measure/@xml:id" as="xs:string*"/>
            <xsl:variable name="profiles" select="distinct-values($current.window.size/*:range[1]/*:profile/@type)" as="xs:string*"/>
            
            <xsl:for-each select="$profiles">
                <xsl:variable name="current.profile" select="." as="xs:string"/>
                <profile type="{$current.profile}">
                    
                    <xsl:variable name="measures" as="node()*">
            <xsl:for-each select="$measure.ids">
                <xsl:variable name="current.measure.id" select="." as="xs:string"/>
                <xsl:variable name="ranges" select="$current.window.size/*:range[('#' || $current.measure.id) = tokenize(normalize-space(@plist),' ')]" as="node()*"/>
                
                            <measure xml:id="{$current.measure.id}" n="{position()}">
                            <xsl:for-each select="distinct-values($ranges/*:profile[@type = $current.profile]/@top)">
                                <key name="{.}"/>
                            </xsl:for-each>
                </measure>
            </xsl:for-each>
                    </xsl:variable>
                    
                    <xsl:attribute name="keys" select="string-join(distinct-values($measures//@name),' ')"/>
                    <xsl:variable name="indexed.measures" as="node()*">
                        <xsl:apply-templates select="$measures" mode="index.measure.keys">
                            <xsl:with-param name="all.keys" select="distinct-values($measures//@name)" tunnel="yes" as="xs:string*"/>
                        </xsl:apply-templates>
                    </xsl:variable>
                    <xsl:sequence select="$indexed.measures"/>
                </profile>
            </xsl:for-each>
            
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="key/@name" mode="index.measure.keys">
        <xsl:param name="all.keys" as="xs:string*" tunnel="yes"/>
        <xsl:next-match/>
        <xsl:attribute name="index" select="index-of($all.keys,string(.))"/>
    </xsl:template>
    
</xsl:stylesheet>