<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:custom="none"
    xmlns:key="none"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:uuid="http://www.uuid.org" exclude-result-prefixes="xs math xd mei custom uuid"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Aug 9, 2018</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    
    <xsl:variable name="accidental.values" as="node()">
        <key:accid.value s="1" f="-1" x="2" ss="2" ff="-2" xs="3" tb="-3" n="0" nf="-1" ns="1"/>
    </xsl:variable>
    
    <xsl:variable name="circle.of.fifths" as="node()">
        
        <key:circle5>
            <key:pos n="-12" major="Dbb" minor="Bbbm" c="-1" d="-2" e="-2" f="-1" g="-2" a="-2" b="-2">
                <key:major name="Dbb" sig="12f" n1="dff" n2="eff" n3="ff" n4="gff" n5="aff" n6="bff" n7="cf"
                    c="7" d="1" e="2" f="3" g="4" a="5" b="6"/>
                <key:minor name="Bbbm" sig="12f" n1="bff" n2="cf" n3="dff" n4="eff" n5="ff" n6="gff" n7="aff"
                    c="2" d="3" e="4" f="5" g="6" a="7" b="1"/>
            </key:pos>
            <key:pos n="-11" major="Abb" minor="Fbm" c="-1" d="-2" e="-2" f="-1" g="-1" a="-2" b="-2">
                <key:major name="Abb" sig="11f" n1="aff" n2="bff" n3="cf" n4="dff" n5="eff" n6="ff" n7="gf"
                    c="3" d="4" e="5" f="6" g="7" a="1" b="2"/>
                <key:minor name="Fbm" sig="11f" n1="ff" n2="gf" n3="aff" n4="bff" n5="cf" n6="dff" n7="eff"
                    c="5" d="6" e="7" f="1" g="2" a="3" b="4"/>
            </key:pos>
            <key:pos n="-10" major="Ebb" minor="Cbm" c="-1" d="-1" e="-2" f="-1" g="-1" a="-2" b="-2">
                <key:major name="Ebb" sig="10f" n1="eff" n2="ff" n3="gf" n4="aff" n5="bff" n6="cf" n7="df"
                    c="6" d="7" e="1" f="2" g="3" a="4" b="5"/>
                <key:minor name="Cbm" sig="10f" n1="cf" n2="df" n3="eff" n4="ff" n5="gf" n6="aff" n7="bff"
                    c="1" d="2" e="3" f="4" g="5" a="6" b="7"/>
            </key:pos>
            <key:pos n="-9" major="Bbb" minor="Gbm" c="-1" d="-1" e="-2" f="-1" g="-1" a="-1" b="-2">
                <key:major name="Bbb" sig="9f" n1="bff" n2="cf" n3="df" n4="eff" n5="ff" n6="gf" n7="af"
                    c="2" d="3" e="4" f="5" g="6" a="7" b="1"/>
                <key:minor name="Gbm" sig="9f" n1="gf" n2="af" n3="bff" n4="cf" n5="df" n6="eff" n7="ff"
                    c="4" d="5" e="6" f="7" g="1" a="2" b="3"/>
            </key:pos>
            
            <key:pos n="-8" major="Fb" minor="Dbm" c="-1" d="-1" e="-1" f="-1" g="-1" a="-1" b="-2">
                <key:major name="Fb" sig="8f" n1="ff" n2="gf" n3="af" n4="bff" n5="cf" n6="df" n7="ef"
                    c="5" d="6" e="7" f="1" g="2" a="3" b="4"/>
                <key:minor name="Dbm" sig="8f" n1="df" n2="ef" n3="ff" n4="gf" n5="af" n6="bff" n7="cf"
                    c="7" d="1" e="2" f="3" g="4" a="5" b="6"/>
            </key:pos>
            <key:pos n="-7" major="Cb" minor="Abm" c="-1" d="-1" e="-1" f="-1" g="-1" a="-1" b="-1">
                <key:major name="Cb" sig="7f" n1="cf" n2="df" n3="ef" n4="ff" n5="gf" n6="af" n7="bf"
                    c="1" d="2" e="3" f="4" g="5" a="6" b="7"/>
                <key:minor name="Abm" sig="7f" n1="af" n2="bf" n3="cf" n4="df" n5="ef" n6="ff" n7="gf"
                    c="3" d="4" e="5" f="6" g="7" a="1" b="2"/>
            </key:pos>
            <key:pos n="-6" major="Gb" minor="Ebm" c="-1" d="-1" e="-1" f="0" g="-1" a="-1" b="-1">
                <key:major name="Gb" sig="6f" n1="gf" n2="af" n3="bf" n4="cf" n5="df" n6="ef" n7="f"
                    c="4" d="5" e="6" f="7" g="1" a="2" b="3"/>
                <key:minor name="Ebm" sig="6f" n1="ef" n2="f" n3="gf" n4="af" n5="bf" n6="cf" n7="df"
                    c="6" d="7" e="1" f="2" g="3" a="4" b="5"/>
            </key:pos>
            <key:pos n="-5" major="Db" minor="Bbm" c="0" d="-1" e="-1" f="0" g="-1" a="-1" b="-1">
                <key:major name="Db" sig="5f" n1="df" n2="ef" n3="f" n4="gf" n5="af" n6="bf" n7="c"
                    c="7" d="1" e="2" f="3" g="4" a="5" b="6"/>
                <key:minor name="Bbm" sig="5f" n1="bf" n2="c" n3="df" n4="ef" n5="f" n6="gf" n7="af"
                    c="2" d="3" e="4" f="5" g="6" a="7" b="1"/>
            </key:pos>
            <key:pos n="-4" major="Ab" minor="Fm" c="0" d="-1" e="-1" f="0" g="0" a="-1" b="-1">
                <key:major name="Ab" sig="4f" n1="af" n2="bf" n3="c" n4="df" n5="ef" n6="f" n7="g"
                    c="3" d="4" e="5" f="6" g="7" a="1" b="2"/>
                <key:minor name="Fm" sig="4f" n1="f" n2="g" n3="af" n4="bf" n5="c" n6="df" n7="ef"
                    c="5" d="6" e="7" f="1" g="2" a="3" b="4"/>
            </key:pos>
            <key:pos n="-3" major="Eb" minor="Cm" c="0" d="0" e="-1" f="0" g="0" a="-1" b="-1">
                <key:major name="Eb" sig="3f" n1="ef" n2="f" n3="g" n4="af" n5="bf" n6="c" n7="d"
                    c="6" d="7" e="1" f="2" g="3" a="4" b="5"/>
                <key:minor name="Cm" sig="3f" n1="c" n2="d" n3="ef" n4="f" n5="g" n6="af" n7="bf"
                    c="1" d="2" e="3" f="4" g="5" a="6" b="7"/>
            </key:pos>
            <key:pos n="-2" major="Bb" minor="Gm" c="0" d="0" e="-1" f="0" g="0" a="0" b="-1">
                <key:major name="Bb" sig="2f" n1="bf" n2="c" n3="d" n4="ef" n5="f" n6="g" n7="a"
                    c="2" d="3" e="4" f="5" g="6" a="7" b="1"/>
                <key:minor name="Gm" sig="2f" n1="g" n2="a" n3="bf" n4="c" n5="d" n6="ef" n7="f"
                    c="4" d="5" e="6" f="7" g="1" a="2" b="3"/>
            </key:pos>
            
            <key:pos n="-1" major="F" minor="Dm" c="0" d="0" e="0" f="0" g="0" a="0" b="-1">
                <key:major name="F" sig="1f" n1="f" n2="g" n3="a" n4="bf" n5="c" n6="d" n7="e"
                    c="5" d="6" e="7" f="1" g="2" a="3" b="4"/>
                <key:minor name="Dm" sig="1f" n1="d" n2="e" n3="f" n4="g" n5="a" n6="bf" n7="c"
                    c="7" d="1" e="2" f="3" g="4" a="5" b="6"/>
            </key:pos>
            <key:pos n="0" major="C" minor="Am" c="0" d="0" e="0" f="0" g="0" a="0" b="0">
                <key:major name="C" sig="0" n1="c" n2="d" n3="e" n4="f" n5="g" n6="a" n7="b"
                    c="1" d="2" e="3" f="4" g="5" a="6" b="7"/>
                <key:minor name="Am" sig="0" n1="a" n2="b" n3="c" n4="d" n5="e" n6="f" n7="g"
                    c="3" d="4" e="5" f="6" g="7" a="1" b="2"/>
            </key:pos>
            <key:pos n="1" major="G" minor="Em" c="0" d="0" e="0" f="1" g="0" a="0" b="0">
                <key:major name="G" sig="1s" n1="g" n2="a" n3="b" n4="c" n5="d" n6="e" n7="fs"
                    c="4" d="5" e="6" f="7" g="1" a="2" b="3"/>
                <key:minor name="Em" sig="1s" n1="e" n2="fs" n3="g" n4="a" n5="b" n6="c" n7="d"
                    c="6" d="7" e="1" f="2" g="3" a="4" b="5"/>
            </key:pos>
            <key:pos n="2" major="D" minor="Bm" c="1" d="0" e="0" f="1" g="0" a="0" b="0">
                <key:major name="D" sig="2s" n1="d" n2="e" n3="fs" n4="g" n5="a" n6="b" n7="cs"
                    c="7" d="1" e="2" f="3" g="4" a="5" b="6"/>
                <key:minor name="Bm" sig="2s" n1="b" n2="cs" n3="d" n4="e" n5="fs" n6="g" n7="a"
                    c="2" d="3" e="4" f="5" g="6" a="7" b="1"/>
            </key:pos>
            <key:pos n="3" major="A" minor="F#m" c="1" d="0" e="0" f="1" g="1" a="0" b="0">
                <key:major name="A" sig="3s" n1="a" n2="b" n3="cs" n4="d" n5="e" n6="fs" n7="gs"
                    c="3" d="4" e="5" f="6" g="7" a="1" b="2"/>
                <key:minor name="F#m" sig="3s" n1="fs" n2="gs" n3="a" n4="b" n5="cs" n6="d" n7="e"
                    c="5" d="6" e="7" f="1" g="2" a="3" b="4"/>
            </key:pos>
            <key:pos n="4" major="E" minor="C#m" c="1" d="1" e="0" f="1" g="1" a="0" b="0">
                <key:major name="E" sig="4s" n1="e" n2="fs" n3="gs" n4="a" n5="b" n6="cs" n7="ds"
                    c="6" d="7" e="1" f="2" g="3" a="4" b="5"/>
                <key:minor name="C#m" sig="4s" n1="cs" n2="ds" n3="e" n4="fs" n5="gs" n6="a" n7="b"
                    c="1" d="2" e="3" f="4" g="5" a="6" b="7"/>
            </key:pos>
            <key:pos n="5" major="B" minor="G#m" c="1" d="1" e="0" f="1" g="1" a="1" b="0">
                <key:major name="B" sig="5s" n1="b" n2="cs" n3="ds" n4="e" n5="fs" n6="gs" n7="as"
                    c="2" d="3" e="4" f="5" g="6" a="7" b="1"/>
                <key:minor name="G#m" sig="5s" n1="gs" n2="as" n3="b" n4="cs" n5="ds" n6="e" n7="fs"
                    c="4" d="5" e="6" f="7" g="1" a="2" b="3"/>
            </key:pos>
            
            <key:pos n="6" major="F#" minor="D#m" c="1" d="1" e="1" f="1" g="1" a="1" b="0">
                <key:major name="F#" sig="6s" n1="fs" n2="gs" n3="as" n4="b" n5="cs" n6="ds" n7="es"
                    c="5" d="6" e="7" f="1" g="2" a="3" b="4"/>
                <key:minor name="D#m" sig="6s" n1="ds" n2="es" n3="fs" n4="gs" n5="as" n6="b" n7="cs"
                    c="7" d="1" e="2" f="3" g="4" a="5" b="6"/>
            </key:pos>
            <key:pos n="7" major="C#" minor="A#m" c="1" d="1" e="1" f="1" g="1" a="1" b="1">
                <key:major name="C#" sig="7s" n1="cs" n2="ds" n3="es" n4="fs" n5="gs" n6="as" n7="bs"
                    c="1" d="2" e="3" f="4" g="5" a="6" b="7"/>
                <key:minor name="A#m" sig="7s" n1="as" n2="bs" n3="cs" n4="ds" n5="es" n6="fs" n7="gs"
                    c="3" d="4" e="5" f="6" g="7" a="1" b="2"/>
            </key:pos>
            <key:pos n="8" major="G#" minor="E#m" c="1" d="1" e="1" f="2" g="1" a="1" b="1">
                <key:major name="G#" sig="8s" n1="gs" n2="as" n3="bs" n4="cs" n5="ds" n6="es" n7="fss"
                    c="4" d="5" e="6" f="7" g="1" a="2" b="3"/>
                <key:minor name="E#m" sig="8s" n1="es" n2="fss" n3="gs" n4="as" n5="bs" n6="cs" n7="ds"
                    c="6" d="7" e="1" f="2" g="3" a="4" b="5"/>
            </key:pos>
            <key:pos n="9" major="D#" minor="B#m" c="2" d="1" e="1" f="2" g="1" a="1" b="1">
                <key:major name="D#" sig="9s" n1="ds" n2="es" n3="fss" n4="gs" n5="as" n6="bs" n7="css"
                    c="7" d="1" e="2" f="3" g="4" a="5" b="6"/>
                <key:minor name="B#m" sig="9s" n1="bs" n2="css" n3="ds" n4="es" n5="fss" n6="gs" n7="as"
                    c="2" d="3" e="4" f="5" g="6" a="7" b="1"/>
            </key:pos>
            <key:pos n="10" major="A#" minor="F##m" c="2" d="1" e="1" f="2" g="2" a="1" b="1">
                <key:major name="A#" sig="10s" n1="as" n2="bs" n3="css" n4="ds" n5="es" n6="fss" n7="gss"
                    c="3" d="4" e="5" f="6" g="7" a="1" b="2"/>
                <key:minor name="F##m" sig="10s" n1="fss" n2="gss" n3="as" n4="bs" n5="css" n6="ds" n7="es"
                    c="5" d="6" e="7" f="1" g="2" a="3" b="4"/>
            </key:pos>
            <key:pos n="11" major="E#" minor="C##m" c="2" d="2" e="1" f="2" g="2" a="1" b="1">
                <key:major name="E#" sig="11s" n1="es" n2="fss" n3="gss" n4="as" n5="bs" n6="css" n7="dss"
                    c="6" d="7" e="1" f="2" g="3" a="4" b="5"/>
                <key:minor name="C##m" sig="11s" n1="css" n2="dss" n3="es" n4="fss" n5="gss" n6="as" n7="bs"
                    c="1" d="2" e="3" f="4" g="5" a="6" b="7"/>
            </key:pos>
            <key:pos n="12" major="B#" minor="G##m" c="2" d="2" e="1" f="2" g="2" a="2" b="1">
                <key:major name="B#" sig="12s" n1="bs" n2="css" n3="dss" n4="es" n5="fss" n6="gss" n7="ass"
                    c="2" d="3" e="4" f="5" g="6" a="7" b="1"/>
                <key:minor name="G##m" sig="12s" n1="gss" n2="ass" n3="bs" n4="css" n5="dss" n6="es" n7="fss"
                    c="4" d="5" e="6" f="7" g="1" a="2" b="3"/>
            </key:pos>
        </key:circle5>
        
    </xsl:variable>
    
    <!--<xsl:variable name="pnum.by.pitch">
        <custom:keys>
            <custom:major>
                <custom:key name="c" cff="1-\-" cf="1-" c="1" cs="1+" css="1++" dff="2-\-" df="2-"
                    d="2" ds="2+" dss="2++" eff="3-\-" ef="3-" e="3" es="3+" ess="3++" fff="4-\-"
                    ff="4-" f="4" fs="4+" fss="4++" gff="5-\-" gf="5-" g="5" gs="5+" gss="5++"
                    aff="6-\-" af="6-" a="6" as="6+" ass="6++" bff="7-\-" bf="7-" b="7" bs="7+"
                    bss="7++"/>
                <custom:key name="d" cff="7-\-\-" cf="7-\-" c="7-" cs="7" css="7+" dff="1-\-" df="1-"
                    d="1" ds="1+" dss="1++" eff="" ef="" e="2" es="" ess="" fff=""
                    ff="" f="3-" fs="" fss="" gff="" gf="" g="4" gs="" gss=""
                    aff="" af="" a="5" as="" ass="" bff="" bf="" b="6" bs=""
                    bss=""/>
                <custom:key name="e" cff="" cf="" c="" cs="" css="" dff="" df=""
                    d="" ds="" dss="" eff="" ef="" e="" es="" ess="" fff=""
                    ff="" f="" fs="" fss="" gff="" gf="" g="" gs="" gss=""
                    aff="" af="" a="" as="" ass="" bff="" bf="" b="" bs=""
                    bss=""/>
                <custom:key name="f" cff="" cf="" c="" cs="" css="" dff="" df=""
                    d="" ds="" dss="" eff="" ef="" e="" es="" ess="" fff=""
                    ff="" f="" fs="" fss="" gff="" gf="" g="" gs="" gss=""
                    aff="" af="" a="" as="" ass="" bff="" bf="" b="" bs=""
                    bss=""/>
                <custom:key name="g" cff="" cf="" c="" cs="" css="" dff="" df=""
                    d="" ds="" dss="" eff="" ef="" e="" es="" ess="" fff=""
                    ff="" f="" fs="" fss="" gff="" gf="" g="" gs="" gss=""
                    aff="" af="" a="" as="" ass="" bff="" bf="" b="" bs=""
                    bss=""/>
                <custom:key name="a" cff="" cf="" c="" cs="" css="" dff="" df=""
                    d="" ds="" dss="" eff="" ef="" e="" es="" ess="" fff=""
                    ff="" f="" fs="" fss="" gff="" gf="" g="" gs="" gss=""
                    aff="" af="" a="" as="" ass="" bff="" bf="" b="" bs=""
                    bss=""/>
                <custom:key name="b" cff="" cf="" c="" cs="" css="" dff="" df=""
                    d="" ds="" dss="" eff="" ef="" e="" es="" ess="" fff=""
                    ff="" f="" fs="" fss="" gff="" gf="" g="" gs="" gss=""
                    aff="" af="" a="" as="" ass="" bff="" bf="" b="" bs=""
                    bss=""/>
            </custom:major>
        </custom:keys>
    </xsl:variable>-->
</xsl:stylesheet>
