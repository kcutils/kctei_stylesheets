<?xml version="1.0" encoding="UTF-8" ?>
<!--

  This stylesheet transforms Kiel Corpus ISO/TEI to TextGrid (praat).

  It produces five tiers:

    - words and non-verbal sounds (interval tier)
    - punctuations (point tier)
    - realized phones (interval tier)
    - canonical phones (point tier)
    - prosodic labels (point tier)

  Canonical phones are on a point tier since they contain unrealized phones
  with no duration. Therefore each canonical phone is placed as a point in
  the middle between its start point and end point.

  Prosodic labels follow the Kieler Intonationsmodell (KIM) and use symbols
  from PROLAB. Prosodic labels have no duration (same start/from and end/to
  points). Prosodic labels  which have the same start point will be
  concatenated using a certain symbol. The special label 'PG' marks the end
  of a phrase. After those marks a different symbol will be used for
  concatenating to show that the following labels belong to a different
  phrase.

  If there are gaps between intervals the end of a preceeding interval will not
  be shown correctly in praat. Praat needs an uninterrupted timesequence of
  intervals in an interval tier; meaning that each gap needs to be filled with
  an interval that has an empty text.
  While it seems to be difficult to go through all elements of certain type
  in XSLT and check values of a preceeding element and react dynamically (insert
  an element if the ending time of the preceeding element is not equal to the
  starting time of the current element and keep up with the correct IDs of all
  outputted elements ...) with Kiel Corpus annotations this problem can be
  solved easily, since there is either a word or a pause|vocal or
                       there is either a phone or a pause|vocal ...

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xdt="http://www.w3.org/2005/xpath-datatypes"
                xmlns:my="http://myohmy.example.com"
                xpath-default-namespace="http://www.tei-c.org/ns/1.0"
                version="2.0">

<xsl:output method="text"/>
  <xsl:variable name="first_timeline_entry" select="0" />
  <xsl:variable name="last_timeline_entry" select="max(/TEI/text/front/timeline/when/@interval)" />

  <xsl:variable name="word_amount" select="count(/TEI/text/body/annotationBlock/u/w)" />
  <xsl:variable name="first_word_start" select="my:getIntervalById(/TEI,replace(/TEI/text/body/annotationBlock[1]/u/w[1]/@synch,'#', ''))" />
  <xsl:variable name="last_word_end" select="my:getIntervalById(/TEI,replace((/TEI/text/body/annotationBlock[last()]/u/anchor)[last()]/@synch,'#', ''))" />

  <xsl:variable name="punctuations_amount" select="count(/TEI/text/body/annotationBlock/u/pc)" />

  <xsl:variable name="incidents_amount" select="count(//(vocal|pause)) + 2" />
  <xsl:variable name="first_inci_start" select="if (//(vocal|pause)[1]/@start) then
                                                   my:getIntervalById(/TEI,replace(//(vocal|pause)[1]/@start, '#', '')) else
                                                   xs:integer(0)
                                               " />
  <xsl:variable name="last_inci_end" select="if (//(vocal|pause)[last()]/@end) then
                                                my:getIntervalById(/TEI,replace(//(vocal|pause)[last()]/@end, '#', '')) else
                                                xs:integer(0)
                                            " />

  <xsl:variable name="word_inc_amount" select="$word_amount + $incidents_amount" />
  <xsl:variable name="word_inc_start" select="min(($first_word_start, $first_inci_start))" />
  <xsl:variable name="word_inc_end" select="max(($last_word_end, $last_inci_end))" />

  <xsl:variable name="pho-realized_amount" select="count(/TEI/text/body/annotationBlock/spanGrp[@type='pho-realized']/span) + $incidents_amount" />
  <xsl:variable name="pho-realized_first_from" select="my:getIntervalById(/TEI,replace(/TEI/text/body/annotationBlock[1]/spanGrp[@type='pho-realized'][1]/span[1]/@from,'#', ''))" />
  <xsl:variable name="pho-realized_last_to" select="my:getIntervalById(/TEI,replace(/TEI/text/body/annotationBlock[last()]/spanGrp[@type='pho-realized'][last()]/span[last()]/@to,'#', ''))" />

  <xsl:variable name="first_pho-realized_from" select="min(($pho-realized_first_from, $first_inci_start ))" />
  <xsl:variable name="last_pho-realized_to" select="max(($pho-realized_last_to, $last_inci_end))" />

  <xsl:variable name="pho-canonical_amount" select="count(/TEI/text/body/annotationBlock/spanGrp[@type='pho-canonical']/span)" />

  <xsl:function name="my:getIntervalById">
    <xsl:param name="root_node" />
    <xsl:param name="ID" />
    <xsl:value-of select="$root_node/text/front/timeline/when[@xml:id=$ID]/@interval" />
  </xsl:function>

<xsl:template name="header">
  <xsl:text>File type = "ooTextFile"
Object class = "TextGrid"

xmin = 0
xmax = </xsl:text><xsl:value-of select="$last_timeline_entry" /><xsl:text>
tiers? &lt;exists&gt;
size = 5
item []:
</xsl:text>
</xsl:template>

<xsl:template name="wordinc_header">
  <xsl:text>    item [1]:
        class = "IntervalTier" 
        name = "words and incidents" 
        xmin = 0 
        xmax = </xsl:text><xsl:value-of select="$last_timeline_entry" /><xsl:text>
        intervals: size = </xsl:text><xsl:value-of select="$word_inc_amount" /><xsl:text>
        intervals [1]:
            xmin = </xsl:text><xsl:value-of select="$first_timeline_entry" /><xsl:text>
            xmax = </xsl:text><xsl:value-of select="$word_inc_start" /><xsl:text>
            text = &quot;&quot;
</xsl:text>
</xsl:template>

<xsl:template name="wordinc_footer">
  <xsl:text>        intervals [</xsl:text><xsl:value-of select="$word_inc_amount" /><xsl:text>]:
            xmin = </xsl:text><xsl:value-of select="$word_inc_end" /><xsl:text>
            xmax = </xsl:text><xsl:value-of select="$last_timeline_entry" /><xsl:text>
            text = &quot;&quot;
</xsl:text>
</xsl:template>

<xsl:template name="incident_header">
  <xsl:text>    item [2]:
        class = "IntervalTier" 
        name = "incidents" 
        xmin = 0 
        xmax = </xsl:text><xsl:value-of select="$last_timeline_entry" /><xsl:text>
        intervals: size = </xsl:text><xsl:value-of select="$incidents_amount" /><xsl:text>
        intervals [1]:
            xmin = </xsl:text><xsl:value-of select="$first_timeline_entry" /><xsl:text>
            xmax = </xsl:text><xsl:value-of select="$first_inci_start" /><xsl:text>
            text = &quot;&quot;
</xsl:text>
</xsl:template>

<xsl:template name="incident_footer">
  <xsl:text>        intervals [</xsl:text><xsl:value-of select="$incidents_amount" /><xsl:text>]:
            xmin = </xsl:text><xsl:value-of select="$last_inci_end" /><xsl:text>
            xmax = </xsl:text><xsl:value-of select="$last_timeline_entry" /><xsl:text>
            text = &quot;&quot;
</xsl:text>
</xsl:template>

<xsl:template name="punctuations_header">
  <xsl:text>    item [2]:
        class = "TextTier" 
        name = "punctuations" 
        xmin = 0 
        xmax = </xsl:text><xsl:value-of select="$last_timeline_entry" /><xsl:text>
        points: size = </xsl:text><xsl:value-of select="$punctuations_amount" /><xsl:text>
</xsl:text>
</xsl:template>

<xsl:template name="pho-realized_header">
  <xsl:text>    item [3]:
        class = "IntervalTier" 
        name = "pho-realized" 
        xmin = 0 
        xmax = </xsl:text><xsl:value-of select="$last_timeline_entry" /><xsl:text>
        intervals: size = </xsl:text><xsl:value-of select="$pho-realized_amount" /><xsl:text>
        intervals [1]:
            xmin = </xsl:text><xsl:value-of select="$first_timeline_entry" /><xsl:text>
            xmax = </xsl:text><xsl:value-of select="$first_pho-realized_from" /><xsl:text>
            text = &quot;&quot;
</xsl:text>
</xsl:template>

<xsl:template name="pho-realized_footer">
  <xsl:text>        intervals [</xsl:text><xsl:value-of select="$pho-realized_amount" /><xsl:text>]:
            xmin = </xsl:text><xsl:value-of select="$last_pho-realized_to" /><xsl:text>
            xmax = </xsl:text><xsl:value-of select="$last_timeline_entry" /><xsl:text>
            text = &quot;&quot;
</xsl:text>
</xsl:template>

<xsl:template name="pho-canonical_header">
  <xsl:text>    item [4]:
        class = "TextTier"
        name = "pho-canonical"
        xmin = 0
        xmax = </xsl:text><xsl:value-of select="$last_timeline_entry" /><xsl:text>
        points: size = </xsl:text><xsl:value-of select="$pho-canonical_amount" /><xsl:text>
</xsl:text>
</xsl:template>

<xsl:template match="/">
  <xsl:call-template name="header" />

  <!-- build tier for words and incidents -->

  <xsl:call-template name="wordinc_header" />

  <xsl:for-each select="/TEI/text/body/((vocal|pause)|(annotationBlock/u/(w|vocal|pause)))">
    <xsl:variable name="current_interval" select="position() + 1"/>
    <xsl:variable name="start" select="if (name(.) = 'w')           then
                                          replace(./@synch,'#', '') else
                                          replace(./@start,'#', '')
                                      " />
    <xsl:variable name="end" select="if (name(.) = 'w') then
                                        replace(following::anchor[1]/@synch,'#', '') else
                                        replace(./@end,'#', '')
                                    " />
    <xsl:variable name="text" select="if (name(.) = 'w') then
                                         .               else
                                         (if (name(.) = 'vocal')            then
                                             concat('&lt;', ./desc, '&gt;') else
                                             '&lt;pause&gt;'
                                         )
                                     " />

    <xsl:text>        intervals [</xsl:text><xsl:value-of select="$current_interval" /><xsl:text>]:
            xmin = </xsl:text><xsl:value-of select="my:getIntervalById(/TEI,$start)" /><xsl:text>
            xmax = </xsl:text><xsl:value-of select="my:getIntervalById(/TEI,$end)" /><xsl:text>
            text = &quot;</xsl:text><xsl:value-of select="$text" /><xsl:text>&quot;
</xsl:text>
  </xsl:for-each>

  <xsl:call-template name="wordinc_footer" />

  <!-- build punctuation tier -->

  <xsl:call-template name="punctuations_header" />

  <xsl:for-each select="/TEI/text/body/annotationBlock/u/pc">
    <xsl:variable name="current_point" select="position()"/>
    <xsl:variable name="end" select="replace(./../../@end,'#', '')" />

    <xsl:text>        points [</xsl:text><xsl:value-of select="$current_point" /><xsl:text>]:
            num = </xsl:text><xsl:value-of select="my:getIntervalById(/TEI,$end)" /><xsl:text>
            text = &quot;</xsl:text><xsl:value-of select="." /><xsl:text>&quot;
</xsl:text>
  </xsl:for-each>

  <!-- build tier of realized phones -->

  <xsl:call-template name="pho-realized_header" />

  <xsl:for-each select="/TEI/text/body/((vocal|pause)|annotationBlock/(spanGrp[@type='pho-realized']/span|u/(vocal|pause)))">
    <xsl:variable name="current_interval" select="position() + 1"/>
    <xsl:variable name="from" select="if (name(.) = 'span')       then
                                         replace(./@from,'#', '') else
                                         replace(./@start,'#', '')
                                     " />
    <xsl:variable name="to" select="if (name(.) = 'span')     then
                                       replace(./@to,'#', '') else
                                       replace(./@end,'#', '')
                                   " />
    <xsl:variable name="text" select="if (name(.) = 'span') then
                                         . else
                                         ''
                                     " />

    <xsl:text>        intervals [</xsl:text><xsl:value-of select="$current_interval" /><xsl:text>]:
            xmin = </xsl:text><xsl:value-of select="my:getIntervalById(/TEI,$from)" /><xsl:text>
            xmax = </xsl:text><xsl:value-of select="my:getIntervalById(/TEI,$to)" /><xsl:text>
            text = &quot;</xsl:text><xsl:value-of select="$text" /><xsl:text>&quot;
</xsl:text>
  </xsl:for-each>

  <xsl:call-template name="pho-realized_footer" />

  <!-- build tier of canonical phones -->

  <xsl:call-template name="pho-canonical_header" />

  <xsl:for-each select="/TEI/text/body/annotationBlock/spanGrp[@type='pho-canonical']/span">
    <xsl:variable name="current_point" select="position()"/>
    <xsl:variable name="from_id" select="replace(./@from,'#', '')" />
    <xsl:variable name="to_id" select="replace(./@to,'#', '')" />
    <xsl:variable name="from" select="my:getIntervalById(/TEI,$from_id)" />
    <xsl:variable name="to" select="my:getIntervalById(/TEI,$to_id)" />
    <xsl:variable name="point" select="($to - $from) div 2 + $from" />

    <xsl:text>        points [</xsl:text><xsl:value-of select="$current_point" /><xsl:text>]:
            num = </xsl:text><xsl:value-of select="$point" /><xsl:text>
            text = &quot;</xsl:text><xsl:value-of select="." /><xsl:text>&quot;
</xsl:text>
  </xsl:for-each>

  <!-- build tier of prosodic information -->

  <xsl:variable name="groups">
    <xsl:for-each-group select="/TEI/text/body/annotationBlock/spanGrp[@type='prolab']/span" group-by="@from">
      <xsl:variable name="point" select ="my:getIntervalById(/TEI,replace(current-grouping-key(),'#',''))" />
      <group point="{$point}">
        <xsl:copy-of select="current-group()" />
      </group>
    </xsl:for-each-group>
  </xsl:variable>

  <xsl:variable name="prosodic_labels">
    <xsl:for-each select="$groups/*">
      <xsl:variable name="previous_group_size" select="count(preceding-sibling::group[1]/*)" />
      <entry point="{@point}">
        <xsl:text>        points [</xsl:text><xsl:value-of select="$previous_group_size + position()"/><xsl:text>]:
              num = </xsl:text><xsl:value-of select="@point"/><xsl:text>
              text = &quot;</xsl:text>

        <xsl:for-each select="*">
          <xsl:variable name="text" select="."/>
          <xsl:value-of select="$text"/>
          <xsl:if test="position() != last()">
            <xsl:choose>
              <xsl:when test="contains($text, 'PG')">
                <xsl:text>    </xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>_</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>
        </xsl:for-each>

        <xsl:text>&quot;
</xsl:text>
      </entry>
    </xsl:for-each>
  </xsl:variable>

  <!-- header for prosodic tier -->
  <xsl:text>    item [5]:
        class = "TextTier"
        name = "prolab"
        xmin = 0
        xmax = </xsl:text><xsl:value-of select="if ($prosodic_labels/*[last()]/@point) then
                                                    $prosodic_labels/*[last()]/@point  else
                                                    xs:integer(0)
                                               " /><xsl:text>
        points: size = </xsl:text><xsl:value-of select="count($prosodic_labels/*)" /><xsl:text>
</xsl:text>

  <xsl:for-each select="$prosodic_labels/*">
    <xsl:value-of select="."/>
  </xsl:for-each>

</xsl:template>

<xsl:template match="/TEI/teiHeader"></xsl:template>
<xsl:template match="/TEI/text/front"></xsl:template>

<xsl:template match="/TEI/text/body/annotationBlock">
  <xsl:variable name="block_start_mark" select="@start" />
  <xsl:variable name="block_end_mark" select="@end" />
  <!-- get words -->
  <xsl:value-of select="u/w" />
  <xsl:text> </xsl:text>
</xsl:template>

<xsl:template match="*/text()[normalize-space()]">
  <xsl:value-of select="normalize-space()"/>
</xsl:template>

<xsl:template match="*/text()[not(normalize-space())]" />

</xsl:stylesheet>
