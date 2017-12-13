<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:svg="http://www.w3.org/2000/svg"
    exclude-result-prefixes="xs" version="2.0">

    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Apr 17, 2011</xd:p>
            <xd:p><xd:b>Author:</xd:b>Matej Vacek</xd:p>
        </xd:desc>
    </xd:doc>

    <xsl:output method="xml" media-type="image/svg+xml" indent="no" encoding="UTF-8"/>



    <!-- PAGE SIZE VARIABLES -->
    <xsl:variable name="pageWidth" as="xs:decimal"
        select="score-partwise/defaults/page-layout/page-width"/>
    <xsl:variable name="pageHeight" as="xs:decimal"
        select="score-partwise/defaults/page-layout/page-height"/>

    <!-- PRINTABLE AREA -->
    <xsl:variable name="leftMargin" as="xs:decimal"
        select="score-partwise/defaults/page-layout/page-margins/left-margin"/>
    <xsl:variable name="rightMargin" as="xs:decimal"
        select="score-partwise/defaults/page-layout/page-margins/right-margin"/>
    <xsl:variable name="topMargin" as="xs:decimal"
        select="score-partwise/defaults/page-layout/page-margins/top-margin"/>
    <xsl:variable name="bottomMargin" as="xs:decimal"
        select="score-partwise/defaults/page-layout/page-margins/bottom-margin"/>

    <!-- LINES DISTANCE (STAVE) -->
    <xsl:variable name="linesDistance" as="xs:decimal" select="9"/>

    <!-- LINES WIDTH -->
    <xsl:variable name="stemWidth" as="xs:decimal"
        select="score-partwise/defaults/appearance/line-width[@type='stem']"/>
    <xsl:variable name="beamWidth" as="xs:decimal"
        select="score-partwise/defaults/appearance/line-width[@type='beam']"/>
    <xsl:variable name="staffWidth" as="xs:decimal"
        select="score-partwise/defaults/appearance/line-width[@type='staff']"/>
    <xsl:variable name="barlineWidth" as="xs:decimal"
        select="score-partwise/defaults/appearance/line-width[@type='light barline']"/>
    <xsl:variable name="heavyBarlineWidth" as="xs:decimal"
        select="score-partwise/defaults/appearance/line-width[@type='heavy barline']"/>

    <!-- FONT SIZE -->
    <xsl:variable name="fontSize" as="xs:double"
        select="(score-partwise/defaults/music-font/@font-size)+15.5"/>

    <!-- DEFAULT MARGINS AND DISTANCES -->
    <xsl:variable name="defaultLeftSystemMargin"
        select="score-partwise/defaults/system-layout/system-margins/left-margin"/>
    <xsl:variable name="defaultRightSystemMargin"
        select="score-partwise/defaults/system-layout/system-margins/right-margin"/>
    <xsl:variable name="defaultSystemDistance"
        select="score-partwise/defaults/system-layout/system-distance"/>
    <xsl:variable name="defaultTopSystemDistance"
        select="score-partwise/defaults/system-layout/top-system-distance"/>

    <!-- NOTES PITCHES -->
    <xsl:variable name="pitches"
        select="'E3','F3','G3','A3','B3','C4','D4','E4','F4','G4','A4','B4','C5','D5','E5','F5','G5','A5','B5','C6','D6','E6'"/>
    <xsl:variable name="distances" select="for $i in reverse(-5 to 15) return $linesDistance div 2*$i"/>

    <!-- KEY SIGNATURE -->
    <xsl:variable name="alter" select="'F','C','G','D','A','E','B','','F','C','G','D','A','E','B'"/>
    <xsl:variable name="shifts"
        select="
        ($linesDistance) div 2*7,
        ($linesDistance) div 2*3,
        ($linesDistance) div 2*6,
        ($linesDistance) div 2*2,
        ($linesDistance) div 2*5,
        ($linesDistance) div 2*1,
        ($linesDistance) div 2*4,
        '0',
        ($linesDistance) div 2*0,
        ($linesDistance) div 2*3,
        ($linesDistance) div 2*-1,
        ($linesDistance) div 2*2,
        ($linesDistance) div 2*5,
        ($linesDistance) div 2*1,
        ($linesDistance) div 2*4
        "/>


    <!-- NEW STAVE TEMPLATE -->
    <xsl:template name="newStave">
        <xsl:param name="x1"/>
        <xsl:param name="x2"/>
        <xsl:param name="y1"/>
        <xsl:param name="y2"/>
        <svg:g stroke="black" stroke-width="{$staffWidth}">
            <svg:line x1="{$x1}" y1="{$y1}" x2="{$x2}" y2="{$y2}"/>
            <svg:line x1="{$x1}" y1="{($y1)+($linesDistance)}" x2="{$x2}"
                y2="{($y2)+($linesDistance)}"/>
            <svg:line x1="{$x1}" y1="{($y1)+(2*$linesDistance)}" x2="{$x2}"
                y2="{($y2)+(2*$linesDistance)}"/>
            <svg:line x1="{$x1}" y1="{($y1)+(3*$linesDistance)}" x2="{$x2}"
                y2="{($y2)+(3*$linesDistance)}"/>
            <svg:line x1="{$x1}" y1="{($y1)+(4*$linesDistance)}" x2="{$x2}"
                y2="{($y2)+(4*$linesDistance)}"/>
        </svg:g>
    </xsl:template>

    <!-- NEW KEY -->
    <xsl:template name="newKey">
        <xsl:param name="fifths"/>
        <xsl:param name="x"/>
        <xsl:param name="y"/>
        <xsl:if test="($fifths!=0) and (($fifths &gt; 1) or ($fifths &lt; (-1)))">
            <xsl:choose>
                <xsl:when test="$fifths &gt; 1">
                    <xsl:call-template name="newKey">
                        <xsl:with-param name="fifths" as="xs:double" select="($fifths)-(1)"/>
                        <xsl:with-param name="x" as="xs:double" select="$x"/>
                        <xsl:with-param name="y" as="xs:double" select="$y"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="newKey">
                        <xsl:with-param name="fifths" as="xs:double" select="($fifths)+(1)"/>
                        <xsl:with-param name="x" as="xs:double" select="($x)"/>
                        <xsl:with-param name="y" as="xs:double" select="($y)"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="$fifths &gt; 0">
                <svg:text x="{($x)+((abs($fifths))*14)-(14)}"
                    y="{($y)+(number($shifts[(abs($fifths))+(8)]))}" font-family="MusicalFont"
                    font-size="{($fontSize)+10}">#</svg:text>
            </xsl:when>
            <xsl:when test="$fifths &lt; 0">
                <svg:text x="{($x)+((abs($fifths))*14)-(14)}"
                    y="{($y)+(number($shifts[($fifths)+(8)]))}" font-family="MusicalFont"
                    font-size="{($fontSize)+10}">b</svg:text>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <!-- NEW LEDGER LINES -->
    <xsl:template name="newLedgerLines">
        <xsl:param name="x"/>
        <xsl:param name="y"/>
        <xsl:param name="topLine"/>
        <xsl:param name="direction"/>
        <xsl:choose>
            <xsl:when test="$direction='down'">
                <xsl:variable name="to"
                    select="(($y)-($topLine)-($linesDistance*4)) div $linesDistance"/>
                <xsl:if test="(($to)&gt;=1)">
                    <xsl:choose>
                        <xsl:when test="($to mod 1)=0.5">
                            <svg:line x1="{($x)-8}" y1="{($y)-($linesDistance div 2)}" x2="{($x)+8}"
                                y2="{($y)-($linesDistance div 2)}" stroke="black"
                                stroke-width="{$staffWidth}"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <svg:line x1="{($x)-8}" y1="{($y)}" x2="{($x)+8}" y2="{($y)}"
                                stroke="black" stroke-width="{$staffWidth}"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:call-template name="newLedgerLines">
                        <xsl:with-param name="x" select="$x"/>
                        <xsl:with-param name="y" select="($y)-($linesDistance)"/>
                        <xsl:with-param name="topLine" select="$topLine"/>
                        <xsl:with-param name="direction" select="$direction"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:when>
            <xsl:when test="$direction='up'">
                <xsl:variable name="to" select="(($y)-($topLine)) div $linesDistance"/>
                <xsl:if test="(($to)&lt;=(-1))">
                    <xsl:choose>
                        <xsl:when test="($to mod 1)=(-0.5)">
                            <svg:line x1="{($x)-8}" y1="{($y)+($linesDistance div 2)}" x2="{($x)+8}"
                                y2="{($y)+($linesDistance div 2)}" stroke="black"
                                stroke-width="{$staffWidth}"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <svg:line x1="{($x)-8}" y1="{($y)}" x2="{($x)+8}" y2="{($y)}"
                                stroke="black" stroke-width="{$staffWidth}"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:call-template name="newLedgerLines">
                        <xsl:with-param name="x" select="$x"/>
                        <xsl:with-param name="y" select="($y)+($linesDistance)"/>
                        <xsl:with-param name="topLine" select="$topLine"/>
                        <xsl:with-param name="direction" select="$direction"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <!-- NEW NOTE TEMPLATE -->
    <xsl:template name="newNote">
        <xsl:param name="notePitch"/>
        <xsl:param name="noteLength"/>
        <xsl:param name="dot"/>
        <xsl:param name="topLine"/>
        <xsl:param name="leftDistance"/>
        <xsl:param name="defaultx"/>
        <xsl:param name="stemDirection"/>
        <xsl:param name="stemDefaulty"/>
        <xsl:param name="accidental"/>
        <xsl:variable name="x" select="$leftDistance+$defaultx"/>
        <xsl:variable name="y" select="($topLine)+($distances[index-of($pitches,$notePitch)])"/>
        <xsl:choose>
            <xsl:when test="(($y)-($topLine))&gt;($linesDistance*4)">
                <xsl:call-template name="newLedgerLines">
                    <xsl:with-param name="x" select="$x"/>
                    <xsl:with-param name="y" select="$y"/>
                    <xsl:with-param name="topLine" select="$topLine"/>
                    <xsl:with-param name="direction" select="'down'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="(($y)-($topLine))&lt;(0)">
                <xsl:call-template name="newLedgerLines">
                    <xsl:with-param name="x" select="$x"/>
                    <xsl:with-param name="y" select="$y"/>
                    <xsl:with-param name="topLine" select="$topLine"/>
                    <xsl:with-param name="direction" select="'up'"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
        <xsl:if test="($accidental)!=('')">
            <xsl:choose>
                <xsl:when test="$accidental='b'">
                    <svg:text x="{($x)-(20)}" y="{$y}" font-family="MusicalFont"
                        font-size="{($fontSize)+10}">
                        <xsl:value-of select="'b'"/>
                    </svg:text>
                </xsl:when>
                <xsl:when test="$accidental='#'">
                    <svg:text x="{($x)-(20)}" y="{$y}" font-family="MusicalFont"
                        font-size="{($fontSize)+10}">
                        <xsl:value-of select="'#'"/>
                    </svg:text>
                </xsl:when>
                <xsl:when test="$accidental='n'">
                    <svg:text x="{($x)-(20)}" y="{$y}" font-family="MusicalFont"
                        font-size="{($fontSize)+10}">
                        <xsl:value-of select="'n'"/>
                    </svg:text>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="$noteLength=16">
                <svg:ellipse cx="{$x}" cy="{$y}" fill="black" stroke="black" stroke-width="1"
                    rx="4.5" ry="3.5"/>
                <xsl:choose>
                    <xsl:when test="$stemDirection='up'">
                        <svg:g stroke="black" stroke-width="{$stemWidth}">
                            <svg:line x1="{$x+4.5}" y1="{$y}" x2="{$x+4.5}"
                                y2="{($topLine)-($stemDefaulty)}"/>
                        </svg:g>
                        <svg:text x="{$x+4}" y="{($topLine)-($stemDefaulty)+(10)}"
                            font-size="{$fontSize}" font-family="MusicalFont">r</svg:text>
                    </xsl:when>
                    <xsl:when test="$stemDirection='down'">
                        <svg:g stroke="black" stroke-width="{$stemWidth}">
                            <svg:line x1="{($x)-(4.5)}" y1="{$y}" x2="{($x)-(4.5)}"
                                y2="{($topLine)-($stemDefaulty)}"/>
                        </svg:g>
                        <svg:text x="{($x)-(5)}" y="{($topLine)-($stemDefaulty)-(10)}"
                            font-size="{$fontSize}" font-family="MusicalFont">R</svg:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$noteLength=8">
                <svg:ellipse cx="{$x}" cy="{$y}" fill="black" stroke="black" stroke-width="1"
                    rx="4.5" ry="3.5"/>
                <xsl:choose>
                    <xsl:when test="$stemDirection='up'">
                        <svg:g stroke="black" stroke-width="{$stemWidth}">
                            <svg:line x1="{$x+4.5}" y1="{$y}" x2="{$x+4.5}"
                                y2="{($topLine)-($stemDefaulty)}"/>
                        </svg:g>
                        <svg:text x="{$x+4}" y="{($topLine)-($stemDefaulty)+(10)}"
                            font-size="{$fontSize}" font-family="MusicalFont">j</svg:text>
                    </xsl:when>
                    <xsl:when test="$stemDirection='down'">
                        <svg:g stroke="black" stroke-width="{$stemWidth}">
                            <svg:line x1="{($x)-(4.5)}" y1="{$y}" x2="{($x)-(4.5)}"
                                y2="{($topLine)-($stemDefaulty)}"/>
                        </svg:g>
                        <svg:text x="{($x)-(5)}" y="{($topLine)-($stemDefaulty)-(10)}"
                            font-size="{$fontSize}" font-family="MusicalFont">J</svg:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$noteLength=4">
                <svg:ellipse cx="{$x}" cy="{$y}" fill="black" stroke="black" stroke-width="1"
                    rx="4.5" ry="3.5"/>
                <xsl:choose>
                    <xsl:when test="$stemDirection='up'">
                        <svg:g stroke="black" stroke-width="{$stemWidth}">
                            <svg:line x1="{$x+4.5}" y1="{$y}" x2="{$x+4.5}"
                                y2="{($topLine)-($stemDefaulty)}"/>
                        </svg:g>
                    </xsl:when>
                    <xsl:when test="$stemDirection='down'">
                        <svg:g stroke="black" stroke-width="{$stemWidth}">
                            <svg:line x1="{($x)-(4.5)}" y1="{$y}" x2="{($x)-(4.5)}"
                                y2="{($topLine)-($stemDefaulty)}"/>
                        </svg:g>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$noteLength=2">
                <svg:ellipse cx="{$x}" cy="{$y}" fill="none" stroke="black" stroke-width="1"
                    rx="4.5" ry="3.5"/>
                <xsl:choose>
                    <xsl:when test="$stemDirection='up'">
                        <svg:g stroke="black" stroke-width="{$stemWidth}">
                            <svg:line x1="{$x+4.5}" y1="{$y}" x2="{$x+4.5}"
                                y2="{($topLine)-($stemDefaulty)}"/>
                        </svg:g>
                    </xsl:when>
                    <xsl:when test="$stemDirection='down'">
                        <svg:g stroke="black" stroke-width="{$stemWidth}">
                            <svg:line x1="{($x)-(4.5)}" y1="{$y}" x2="{($x)-(4.5)}"
                                y2="{($topLine)-($stemDefaulty)}"/>
                        </svg:g>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$noteLength=1">
                <svg:ellipse cx="{$x}" cy="{$y}" fill="none" stroke="black" stroke-width="1"
                    rx="4.5" ry="3.5"/>
            </xsl:when>
        </xsl:choose>
        <xsl:if test="$dot">
            <xsl:choose>
                <xsl:when test="(index-of($pitches,$notePitch) mod 2) = 0">
                    <svg:text x="{($x)+6}" y="{($y)-($linesDistance div 4)}" font-size="{$fontSize}">.</svg:text>    
                </xsl:when>
                <xsl:otherwise>
                    <svg:text x="{($x)+6}" y="{($y)}" font-size="{$fontSize}">.</svg:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>


    <!-- NEW SYLLABIC TEMPLATE -->
    <xsl:template name="newSyllabic">
        <xsl:param name="topLine"/>
        <xsl:param name="leftDistance"/>
        <xsl:param name="defaultx"/>
        <xsl:param name="defaulty"/>
        <xsl:param name="text"/>
        <xsl:param name="syllabicDash"/>
        <svg:text x="{($leftDistance)+($defaultx)}" y="{($topLine)-($defaulty)}" font-family="'Times New Roman', serif"
            style="text-anchor: middle;">
            <xsl:value-of select="$text"/>
        </svg:text>
        <xsl:if test="($syllabicDash)!=0">
            <svg:text x="{($leftDistance)+($defaultx)-($syllabicDash)}" y="{($topLine)-($defaulty)}" font-family="'Times New Roman', serif"
                style="text-anchor: middle;">-</svg:text>
        </xsl:if>
    </xsl:template>


    <!-- BEGINNING OF THE TRANSFORMATION  -->
    <xsl:template match="score-partwise">
        <svg:svg width="{$pageWidth}" height="{$pageHeight}">

            <!-- MUSICAL FONT -->
            <svg:defs>
                <xsl:call-template name="glyph"/>
            </svg:defs>

            <xsl:apply-templates select="./credit/credit-words"/>
            <xsl:apply-templates select="./part/measure"/>

        </svg:svg>
    </xsl:template>


    <!-- CREDIT WORDS -->
    <xsl:template match="credit-words">
        <svg:text x="{./@default-x}" y="{($pageHeight)-(./@default-y)}"
            font-family="'Times New Roman', serif" font-size="{(./@font-size)+15.5}"
            font-weight="{if(./@font-weight='bold') then('bold') else('normal')}"
            style="{if((./@justify='center') or (./@halign='center')) then('text-anchor: middle;') else('text-anchor: left;')}">
            <xsl:value-of select="."/>
        </svg:text>
    </xsl:template>


    <!-- MEASURE -->
    <xsl:template match="measure">

        <!-- TOP STAVE LINE FOR EACH MEASURE -->
        <xsl:variable as="xs:double" name="topLine">
            <xsl:choose>
                <xsl:when test="@number=1">
                    <select>
                        <xsl:value-of
                            select="(./print/system-layout/top-system-distance)+($topMargin)"/>
                    </select>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable as="xs:double" name="selfDistance">
                        <xsl:choose>
                            <xsl:when test="./print/system-layout/top-system-distance">
                                <select>
                                    <xsl:value-of
                                        select="(./print/system-layout/top-system-distance)+($linesDistance*4)"
                                    />
                                </select>
                            </xsl:when>
                            <xsl:when test="./print/system-layout/system-distance">
                                <select>
                                    <xsl:value-of
                                        select="(./print/system-layout/system-distance)+($linesDistance*4)"
                                    />
                                </select>
                            </xsl:when>
                            <xsl:when test="./print">
                                <select>
                                    <xsl:value-of select="$defaultSystemDistance"/>
                                </select>
                            </xsl:when>
                            <xsl:otherwise>
                                <select>0</select>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <select>
                        <xsl:value-of
                            select="($selfDistance)+(((count(preceding-sibling::measure/print))-1)*$linesDistance*4)+(preceding-sibling::measure[last()]/print/system-layout/top-system-distance)+sum(preceding-sibling::measure/print/system-layout/system-distance)+($topMargin)"/>
                    </select>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- LEFT BARLINE FOR EACH MEASURE, ALSO LEFT BEGINNING OF STAVE LINES -->
        <xsl:variable name="leftBarLine">
            <xsl:choose>
                <xsl:when test="./print">
                    <xsl:choose>
                        <xsl:when test="./print/system-layout/system-margins/left-margin">
                            <select>
                                <xsl:value-of
                                    select="./print/system-layout/system-margins/left-margin"/>
                            </select>
                        </xsl:when>
                        <xsl:otherwise>
                            <select>
                                <xsl:value-of select="$defaultLeftSystemMargin"/>
                            </select>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable as="xs:decimal" name="measurePrint"
                        select="preceding-sibling::measure[print][1]/@number"/>
                    <xsl:variable as="xs:decimal" name="measurePrintLeftMargin">
                        <xsl:choose>
                            <xsl:when
                                test="preceding-sibling::measure[print][1]/print/system-layout/system-margins/left-margin">
                                <select>
                                    <xsl:value-of
                                        select="preceding-sibling::measure[print][1]/print/system-layout/system-margins/left-margin"
                                    />
                                </select>
                            </xsl:when>
                            <xsl:otherwise>
                                <select>
                                    <xsl:value-of select="$defaultLeftSystemMargin"/>
                                </select>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <select>
                        <xsl:value-of
                            select="sum(preceding-sibling::measure[(@number) &gt;= ($measurePrint)]/@width)+($measurePrintLeftMargin)"
                        />
                    </select>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- NEW STAVE -->
        <xsl:if test="print">
            <xsl:call-template name="newStave">
                <xsl:with-param name="x1" select="($leftMargin)+($leftBarLine)"/>
                <xsl:with-param name="y1" select="($topMargin)+($topLine)"/>
                <xsl:with-param name="x2"
                    select="($pageWidth)-($rightMargin)-
                    (if(print/system-layout/system-margins/right-margin) then(print/system-layout/system-margins/right-margin) else($defaultRightSystemMargin))"/>
                <xsl:with-param name="y2" select="($topMargin)+($topLine)"/>
            </xsl:call-template>
            <!-- G CLEF -->
            <svg:text x="{($leftMargin)+($leftBarLine)}"
                y="{($topMargin)+($topLine)+(3*$linesDistance)}" font-size="{$fontSize}"
                font-family="MusicalFont">&#x26;</svg:text>
            <!-- KEY SIGNATURE -->
            <xsl:if test="not(attributes/key/fifths)">
                <xsl:call-template name="newKey">
                    <xsl:with-param name="fifths" as="xs:double">
                        <select>
                            <xsl:value-of select="preceding-sibling::measure[attributes/key/fifths][1]/attributes/key/fifths"/>
                        </select>
                    </xsl:with-param>
                    <xsl:with-param name="x" as="xs:double"
                        select="($leftMargin)+($leftBarLine)+(30)"/>
                    <xsl:with-param name="y" as="xs:double" select="($topMargin)+($topLine)"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:if>

        <xsl:variable name="clefDistance">
            <xsl:choose>
                <xsl:when test="print">
                    <select>
                        <xsl:value-of select="30"/>
                    </select>
                </xsl:when>
                <xsl:otherwise>
                    <select>
                        <xsl:value-of select="0"/>
                    </select>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- KEY SIGNATURE -->
        <xsl:if test="attributes/key/fifths">
            <xsl:call-template name="newKey">
                <xsl:with-param name="fifths" as="xs:double">
                    <select>
                        <xsl:value-of select="attributes/key/fifths"/>
                    </select>
                </xsl:with-param>
                <xsl:with-param name="x" as="xs:double"
                    select="($leftMargin)+($leftBarLine)+($clefDistance)"/>
                <xsl:with-param name="y" as="xs:double" select="($topMargin)+($topLine)"/>
            </xsl:call-template>
        </xsl:if>

        <xsl:variable name="keyDistance">
            <xsl:choose>
                <xsl:when test="attributes/key">
                    <select>
                        <xsl:value-of select="(abs((attributes/key/fifths))*14)+(14)"/>
                    </select>
                </xsl:when>
                <xsl:otherwise>
                    <select>
                        <xsl:value-of select="14"/>
                    </select>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- TIME SIGNATURE -->
        <xsl:if test="attributes/time/beats">
            <svg:text x="{($leftMargin)+($leftBarLine)+($clefDistance)+($keyDistance)}"
                y="{($topMargin)+($topLine)+($linesDistance)}" font-size="{$fontSize}"
                font-family="MusicalFont">
                <xsl:value-of select="attributes/time/beats"/>
            </svg:text>
        </xsl:if>
        <xsl:if test="attributes/time/beat-type">
            <svg:text x="{($leftMargin)+($leftBarLine)+($clefDistance)+($keyDistance)}"
                y="{($topMargin)+($topLine)+(3*$linesDistance)}" font-size="{$fontSize}"
                font-family="MusicalFont">
                <xsl:value-of select="attributes/time/beat-type"/>
            </svg:text>
        </xsl:if>

        <xsl:variable name="timeDistance">
            <xsl:choose>
                <xsl:when test="attributes/time">
                    <select>
                        <xsl:value-of select="20"/>
                    </select>
                </xsl:when>
                <xsl:otherwise>
                    <select>
                        <xsl:value-of select="0"/>
                    </select>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- BARLINE -->
        <xsl:choose>
            <xsl:when test="barline/repeat/@direction='backward'">
                <svg:text x="{($leftMargin)+($leftBarLine)+(@width)-15}"
                    y="{($topMargin)+($topLine)+($linesDistance*1.5)}" font-size="{$fontSize}">.</svg:text>
                <svg:text x="{($leftMargin)+($leftBarLine)+(@width)-15}"
                    y="{($topMargin)+($topLine)+($linesDistance*2.5)}" font-size="{$fontSize}">.</svg:text>
                <svg:g stroke="black" stroke-width="{$barlineWidth}">
                    <svg:line x1="{($leftMargin)+($leftBarLine)+(@width)-6}"
                        y1="{($topMargin)+($topLine)}"
                        x2="{($leftMargin)+($leftBarLine)+(@width)-6}"
                        y2="{($topMargin)+($topLine)+(4*$linesDistance)}"/>
                </svg:g>
                <svg:g stroke="black" stroke-width="{$heavyBarlineWidth}">
                    <svg:line x1="{($leftMargin)+($leftBarLine)+(@width)}"
                        y1="{($topMargin)+($topLine)}" x2="{($leftMargin)+($leftBarLine)+(@width)}"
                        y2="{($topMargin)+($topLine)+(4*$linesDistance)}"/>
                </svg:g>
            </xsl:when>
            <xsl:when test="barline/repeat/@direction='forward'">
                <svg:text x="{($leftMargin)+($leftBarLine)+15}"
                    y="{($topMargin)+($topLine)+($linesDistance*1.5)}" font-size="{$fontSize}">.</svg:text>
                <svg:text x="{($leftMargin)+($leftBarLine)+15}"
                    y="{($topMargin)+($topLine)+($linesDistance*2.5)}" font-size="{$fontSize}">.</svg:text>
                <svg:g stroke="black" stroke-width="{$barlineWidth}">
                    <svg:line x1="{($leftMargin)+($leftBarLine)+6}"
                        y1="{($topMargin)+($topLine)}"
                        x2="{($leftMargin)+($leftBarLine)+6}"
                        y2="{($topMargin)+($topLine)+(4*$linesDistance)}"/>
                </svg:g>
                <svg:g stroke="black" stroke-width="{$heavyBarlineWidth}">
                    <svg:line x1="{($leftMargin)+($leftBarLine)}"
                        y1="{($topMargin)+($topLine)}" x2="{($leftMargin)+($leftBarLine)}"
                        y2="{($topMargin)+($topLine)+(4*$linesDistance)}"/>
                </svg:g>
            </xsl:when>
            <xsl:when test="barline[@location='right']/bar-style='light-heavy'">
                <svg:g stroke="black" stroke-width="{$barlineWidth}">
                    <svg:line x1="{($leftMargin)+($leftBarLine)+(@width)-6}"
                        y1="{($topMargin)+($topLine)}"
                        x2="{($leftMargin)+($leftBarLine)+(@width)-6}"
                        y2="{($topMargin)+($topLine)+(4*$linesDistance)}"/>
                </svg:g>
                <svg:g stroke="black" stroke-width="{$heavyBarlineWidth}">
                    <svg:line x1="{($leftMargin)+($leftBarLine)+(@width)}"
                        y1="{($topMargin)+($topLine)}" x2="{($leftMargin)+($leftBarLine)+(@width)}"
                        y2="{($topMargin)+($topLine)+(4*$linesDistance)}"/>
                </svg:g>
            </xsl:when>
            <xsl:when test="barline[@location='left']/bar-style='light-heavy'">
                <svg:g stroke="black" stroke-width="{$barlineWidth}">
                    <svg:line x1="{($leftMargin)+($leftBarLine)-6}" y1="{($topMargin)+($topLine)}"
                        x2="{($leftMargin)+($leftBarLine)-6}"
                        y2="{($topMargin)+($topLine)+(4*$linesDistance)}"/>
                </svg:g>
                <svg:g stroke="black" stroke-width="{$heavyBarlineWidth}">
                    <svg:line x1="{($leftMargin)+($leftBarLine)}" y1="{($topMargin)+($topLine)}"
                        x2="{($leftMargin)+($leftBarLine)}"
                        y2="{($topMargin)+($topLine)+(4*$linesDistance)}"/>
                </svg:g>
            </xsl:when>
            <xsl:otherwise>
                <svg:g stroke="black" stroke-width="{$barlineWidth}">
                    <svg:line x1="{($leftMargin)+($leftBarLine)+(@width)}"
                        y1="{($topMargin)+($topLine)}" x2="{($leftMargin)+($leftBarLine)+(@width)}"
                        y2="{($topMargin)+($topLine)+(4*$linesDistance)}"/>
                </svg:g>
            </xsl:otherwise>
        </xsl:choose>

        <!-- CONTINUE TO WORDS -->
        <xsl:apply-templates select="./direction/direction-type/words">
            <xsl:with-param name="topLine" select="($topMargin)+($topLine)"/>
            <xsl:with-param name="leftDistance" select="($leftMargin)+($leftBarLine)"/>
        </xsl:apply-templates>

        <!-- CONTINUE TO NOTES -->
        <xsl:apply-templates select="./note">
            <xsl:with-param name="topLine" select="($topMargin)+($topLine)"/>
            <xsl:with-param name="leftDistance" select="($leftMargin)+($leftBarLine)"/>
        </xsl:apply-templates>

    </xsl:template>

    <xsl:template match="words">
        <xsl:param name="topLine"/>
        <xsl:param name="leftDistance"/>
        <svg:text x="{($leftDistance)+(./@default-x)}"
            y="{($topLine)-(./@default-y)+(4*$linesDistance)}" font-family="'Times New Roman', serif"
            font-size="{(./@font-size)+15.5}"
            font-weight="{if(./@font-weight='bold') then('bold') else('normal')}"
            style="{if((./@justify='center') or (./@halign='center')) then('text-anchor: middle;') else('text-anchor: left;')}">
            <xsl:value-of select="."/>
        </svg:text>
    </xsl:template>

    <xsl:template match="note">
        <xsl:param name="topLine"/>
        <xsl:param name="leftDistance"/>
        <xsl:choose>
            <xsl:when test="rest">
                <xsl:variable name="type">
                    <xsl:choose>
                        <xsl:when test="type">
                            <xsl:value-of select="type"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="''"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="$type='16th'">
                        <svg:circle fill="black" cx="{($leftDistance)+(./@default-x)}"
                            cy="{($topLine)+($linesDistance*1.5)}" r="3"/>
                        <svg:path stroke="black" fill="none" stroke-width="1"
                            d="M{($leftDistance)+(./@default-x)+1},{($topLine)+($linesDistance*1.5)+2} q4,3 5,-3 l-5,{$linesDistance*3}"/>
                        <svg:circle fill="black" cx="{($leftDistance)+(./@default-x)-1.5}"
                            cy="{($topLine)+($linesDistance*2.5)}" r="3"/>
                        <svg:path stroke="black" fill="none" stroke-width="1"
                            d="M{($leftDistance)+(./@default-x)+(1)-(1.5)},{($topLine)+($linesDistance*2.5)+2} q4,3 5,-3"
                        />
                    </xsl:when>
                    <xsl:when test="$type='eighth'">
                        <svg:circle fill="black" cx="{($leftDistance)+(./@default-x)}"
                            cy="{($topLine)+($linesDistance*1.5)}" r="3"/>
                        <svg:path stroke="black" fill="none" stroke-width="1"
                            d="M{($leftDistance)+(./@default-x)+1},{($topLine)+($linesDistance*1.5)+2} q4,3 5,-3 l-5,{$linesDistance*2}"
                        />
                    </xsl:when>
                    <xsl:when test="$type='quarter'">
                        <svg:text x="{($leftDistance)+(./@default-x)}"
                            y="{($topLine)+($linesDistance*2)}" font-size="{$fontSize}"
                            font-family="MusicalFont">&#x152;</svg:text>
                    </xsl:when>
                    <xsl:when test="$type='half'">
                        <svg:rect fill="black" x="{($leftDistance)+(./@default-x)}"
                            y="{($topLine)+($linesDistance*1.5)}" width="12"
                            height="{$linesDistance div 2}"/>
                    </xsl:when>
                    <xsl:when test="($type='whole')">
                        <svg:rect fill="black" x="{($leftDistance)+(./@default-x)}"
                            y="{($topLine)+($linesDistance)}" width="12"
                            height="{$linesDistance div 2}"/>
                    </xsl:when>
                    <xsl:when test="($type='')">
                        <svg:rect fill="black" x="{($leftDistance)+(../@width) div 2}"
                            y="{($topLine)+($linesDistance)}" width="12"
                            height="{$linesDistance div 2}"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="notePitch" select="concat(./pitch/step,./pitch/octave)"/>
                <xsl:variable name="noteLength">
                    <xsl:variable name="type">
                        <xsl:value-of select="type"/>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="$type='16th'">
                            <select>
                                <xsl:value-of select="16"/>
                            </select>
                        </xsl:when>
                        <xsl:when test="$type='eighth'">
                            <select>
                                <xsl:value-of select="8"/>
                            </select>
                        </xsl:when>
                        <xsl:when test="$type='quarter'">
                            <select>
                                <xsl:value-of select="4"/>
                            </select>
                        </xsl:when>
                        <xsl:when test="$type='half'">
                            <select>
                                <xsl:value-of select="2"/>
                            </select>
                        </xsl:when>
                        <xsl:when test="$type='whole'">
                            <select>
                                <xsl:value-of select="1"/>
                            </select>
                        </xsl:when>
                        <xsl:otherwise>
                            <select>
                                <xsl:value-of select="0"/>
                            </select>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="stemDirection">
                    <xsl:choose>
                        <xsl:when test="./stem">
                            <select>
                                <xsl:value-of select="./stem"/>
                            </select>
                        </xsl:when>
                        <xsl:otherwise>
                            <select/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="stemDefaulty">
                    <xsl:choose>
                        <xsl:when test="./stem">
                            <select>
                                <xsl:value-of select="./stem/@default-y"/>
                            </select>
                        </xsl:when>
                        <xsl:otherwise>
                            <select/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="accidental">
                    <xsl:choose>
                        <xsl:when test="accidental">
                            <xsl:choose>
                                <xsl:when test="accidental='flat'">
                                    <select>
                                        <xsl:value-of select="'b'"/>
                                    </select>
                                </xsl:when>
                                <xsl:when test="accidental='sharp'">
                                    <select>
                                        <xsl:value-of select="'#'"/>
                                    </select>
                                </xsl:when>
                                <xsl:when test="accidental='natural'">
                                    <xsl:value-of select="'n'"/>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <select>
                                <xsl:value-of select="''"/>
                            </select>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable as="xs:boolean" name="dot">
                    <xsl:choose>
                        <xsl:when test="dot">
                            <select>
                                <xsl:value-of select="true()"/>
                            </select>
                        </xsl:when>
                        <xsl:otherwise>
                            <select>
                                <xsl:value-of select="false()"/>
                            </select>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:call-template name="newNote">
                    <xsl:with-param name="notePitch" select="$notePitch"/>
                    <xsl:with-param name="noteLength" select="$noteLength"/>
                    <xsl:with-param name="dot" select="$dot"/>
                    <xsl:with-param name="topLine" select="$topLine"/>
                    <xsl:with-param name="leftDistance" select="$leftDistance"/>
                    <xsl:with-param name="defaultx" select="./@default-x"/>
                    <xsl:with-param name="stemDirection" select="$stemDirection"/>
                    <xsl:with-param name="stemDefaulty" select="$stemDefaulty"/>
                    <xsl:with-param name="accidental" select="$accidental"/>
                </xsl:call-template>
                <xsl:if test="./lyric">
                    <xsl:for-each select="./lyric">
                        <xsl:variable as="xs:double" name="syllabicDash">
                            <xsl:choose>
                                <xsl:when test="(syllabic='middle') or (syllabic='end')">
                                    <select>
                                        <xsl:value-of select="((../@default-x)-(preceding::note[lyric[@number='1']][1]/@default-x)) div 2"/>
                                    </select>
                                </xsl:when>
                                <xsl:otherwise>
                                    <select><xsl:value-of select="0"/></select>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:call-template name="newSyllabic">
                            <xsl:with-param name="topLine" select="$topLine"/>
                            <xsl:with-param name="leftDistance" select="$leftDistance"/>
                            <xsl:with-param name="defaultx" select="../@default-x"/>
                            <xsl:with-param name="defaulty" select="@default-y"/>
                            <xsl:with-param name="text" select="text"/>
                            <xsl:with-param name="syllabicDash" select="$syllabicDash"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
