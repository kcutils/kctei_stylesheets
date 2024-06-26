<?xml version="1.0" encoding="UTF-8" ?>
<!--

  This stylesheet transforms Kiel Corpus ISO/TEI to TextGrid (praat).

  It produces six tiers:

    - words and non-verbal sounds (interval tier)
    - syntax (punctuations, false starts and truncations) (point tier)
    - canonical phones (point tier)
    - realized phones and non-verbal sounds (interval tier)
    - misc labels (point tier)
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
  <xsl:variable name="last_timeline_entry" select="max(/TEI/text/timeline/when/@interval)" />

  <xsl:variable name="word_amount" select="count(/TEI/text/body/annotationBlock/u/w)" />
  <xsl:variable name="first_word_start" select="if ((//w)[1]/@synch) then
                                                   my:getIntervalById(/TEI,replace((//w)[1]/@synch,'#', '')) else
                                                   xs:integer(0)
                                               " />
  <xsl:variable name="last_word_end" select="if ((//anchor)[last()]/@synch) then
                                                my:getIntervalById(/TEI,replace((//anchor)[last()]/@synch,'#', '')) else
                                                xs:integer(0)
                                            " />

  <!-- count punctuations and false starts and truncations on error-spanGrp -->
  <xsl:variable name="syntax_amount" select="count(/TEI/text/body/annotationBlock/u/pc) + count(/TEI/text/body/annotationBlock/spanGrp[@type='error']/span)" />

  <xsl:variable name="incidents_amount" select="count(//(vocal|pause)) + 2" />
  <xsl:variable name="first_inci_start" select="if (//(vocal|pause)[1]/@start) then
                                                   my:getIntervalById(/TEI,replace((//(vocal|pause))[1]/@start, '#', '')) else
                                                   xs:integer(0)
                                               " />
  <xsl:variable name="last_inci_end" select="if (//(vocal|pause)[last()]/@end) then
                                                my:getIntervalById(/TEI,replace((//(vocal|pause))[last()]/@end, '#', '')) else
                                                xs:integer(0)
                                            " />

  <xsl:variable name="word_inc_amount" select="$word_amount + $incidents_amount" />
  <xsl:variable name="word_inc_start" select="min(($first_word_start, $first_inci_start))" />
  <xsl:variable name="word_inc_end" select="max(($last_word_end, $last_inci_end))" />

  <xsl:variable name="pho-realized_amount" select="count(/TEI/text/body/annotationBlock/spanGrp[@type='pho-realized']/span) + $incidents_amount" />
  <xsl:variable name="pho-realized_first_from" select="if ((//spanGrp[@type='pho-realized'])[1]/span[1]/@from) then
                                                          my:getIntervalById(/TEI,replace((//spanGrp[@type='pho-realized'])[1]/span[1]/@from,'#', '')) else
                                                          xs:integer(0)
                                                      " />
  <xsl:variable name="pho-realized_last_to" select="if ((//spanGrp[@type='pho-realized'])[last()]/span[last()]/@to) then
                                                       my:getIntervalById(/TEI,replace((//spanGrp[@type='pho-realized'])[last()]/span[last()]/@to,'#', '')) else
                                                       xs:integer(0)
                                                   " />

  <xsl:variable name="first_pho-realized_from" select="min(($pho-realized_first_from, $first_inci_start ))" />
  <xsl:variable name="last_pho-realized_to" select="max(($pho-realized_last_to, $last_inci_end))" />

  <xsl:function name="my:getIntervalById">
    <xsl:param name="root_node" />
    <xsl:param name="ID" />
    <xsl:value-of select="$root_node/text/timeline/when[@xml:id=$ID]/@interval" />
  </xsl:function>

<xsl:template name="header">
  <xsl:text>File type = "ooTextFile"
Object class = "TextGrid"

xmin = 0
xmax = </xsl:text><xsl:value-of select="$last_timeline_entry" /><xsl:text>
tiers? &lt;exists&gt;
size = 6
item []:
</xsl:text>
</xsl:template>

<xsl:template name="wordinc_header">
  <xsl:text>    item [1]:
        class = "IntervalTier" 
        name = "Wörter und Geräusche" 
        xmin = 0 
        xmax = </xsl:text><xsl:value-of select="$last_timeline_entry" /><xsl:text>
        intervals: size = </xsl:text><xsl:value-of select="$word_inc_amount" /><xsl:text>
        intervals [1]:
            xmin = </xsl:text><xsl:value-of select="$first_timeline_entry" /><xsl:text>
            xmax = </xsl:text><xsl:value-of select="$word_inc_start" /><xsl:text>
            text = &quot;"
</xsl:text>
</xsl:template>

<xsl:template name="wordinc_footer">
  <xsl:text>        intervals [</xsl:text><xsl:value-of select="$word_inc_amount" /><xsl:text>]:
            xmin = </xsl:text><xsl:value-of select="$word_inc_end" /><xsl:text>
            xmax = </xsl:text><xsl:value-of select="$last_timeline_entry" /><xsl:text>
            text = &quot;"
</xsl:text>
</xsl:template>

<xsl:template name="incident_header">
  <xsl:text>    item [2]:
        class = "IntervalTier" 
        name = "Geräusche" 
        xmin = 0 
        xmax = </xsl:text><xsl:value-of select="$last_timeline_entry" /><xsl:text>
        intervals: size = </xsl:text><xsl:value-of select="$incidents_amount" /><xsl:text>
        intervals [1]:
            xmin = </xsl:text><xsl:value-of select="$first_timeline_entry" /><xsl:text>
            xmax = </xsl:text><xsl:value-of select="$first_inci_start" /><xsl:text>
            text = &quot;"
</xsl:text>
</xsl:template>

<xsl:template name="incident_footer">
  <xsl:text>        intervals [</xsl:text><xsl:value-of select="$incidents_amount" /><xsl:text>]:
            xmin = </xsl:text><xsl:value-of select="$last_inci_end" /><xsl:text>
            xmax = </xsl:text><xsl:value-of select="$last_timeline_entry" /><xsl:text>
            text = &quot;"
</xsl:text>
</xsl:template>

<xsl:template name="syntax_header">
  <xsl:text>    item [2]:
        class = "TextTier" 
        name = "Syntax"
        xmin = 0 
        xmax = </xsl:text><xsl:value-of select="$last_timeline_entry" /><xsl:text>
        points: size = </xsl:text><xsl:value-of select="$syntax_amount" /><xsl:text>
</xsl:text>
</xsl:template>

<xsl:template name="pho-realized_header">
  <xsl:text>    item [4]:
        class = "IntervalTier" 
        name = "Phonetik (realisiert)"
        xmin = 0 
        xmax = </xsl:text><xsl:value-of select="$last_timeline_entry" /><xsl:text>
        intervals: size = </xsl:text><xsl:value-of select="$pho-realized_amount" /><xsl:text>
        intervals [1]:
            xmin = </xsl:text><xsl:value-of select="$first_timeline_entry" /><xsl:text>
            xmax = </xsl:text><xsl:value-of select="$first_pho-realized_from" /><xsl:text>
            text = &quot;"
</xsl:text>
</xsl:template>

<xsl:template name="pho-realized_footer">
  <xsl:text>        intervals [</xsl:text><xsl:value-of select="$pho-realized_amount" /><xsl:text>]:
            xmin = </xsl:text><xsl:value-of select="$last_pho-realized_to" /><xsl:text>
            xmax = </xsl:text><xsl:value-of select="$last_timeline_entry" /><xsl:text>
            text = &quot;"
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
                                             '&lt;Pause&gt;'
                                         )
                                     " />

    <xsl:text>        intervals [</xsl:text><xsl:value-of select="$current_interval" /><xsl:text>]:
            xmin = </xsl:text><xsl:value-of select="my:getIntervalById(/TEI,$start)" /><xsl:text>
            xmax = </xsl:text><xsl:value-of select="my:getIntervalById(/TEI,$end)" /><xsl:text>
            text = &quot;</xsl:text><xsl:value-of select="$text" /><xsl:text>&quot;
</xsl:text>
  </xsl:for-each>

  <xsl:call-template name="wordinc_footer" />

  <!-- build syntax tier -->

  <xsl:call-template name="syntax_header" />

  <!--
    place punctuation marks (pc) and false starts and truncations
    (in error-spanGrp) on this tier,
    pc needs @end- or @synch-attribute from first preceding-sibling,
    spans in error-spanGrp have @to-attribute themselves
  -->
  <xsl:variable name="syntax_elements">
    <xsl:for-each select="/TEI/text/body/annotationBlock/((u/pc)|(spanGrp[@type='error']/span))">
      <xsl:variable name="end" select="if (name(.) = 'span')    then
                                          replace(./@to,'#','') else
                                          (if (name(./preceding-sibling::*[1]) = 'vocal' or
                                               name(./preceding-sibling::*[1]) = 'pause')    then
                                              replace(./preceding-sibling::*[1]/@end,'#','') else
                                              (if (name(./preceding-sibling::*[1]) = 'anchor')     then
                                                  replace(./preceding-sibling::*[1]/@synch,'#','') else
                                                  'Error: unknown case'
                                              )
                                          )
                                      " />
      <xsl:variable name="text" select="." />

      <syntax_element end="{my:getIntervalById(/TEI,$end)}">
        <xsl:value-of select="$text" />
      </syntax_element>
    </xsl:for-each>
  </xsl:variable>

  <xsl:for-each select="$syntax_elements/*">
    <xsl:sort select="@end" data-type="number" />
    <xsl:variable name="current_point" select="position()"/>
    <xsl:text>        points [</xsl:text><xsl:value-of select="$current_point" /><xsl:text>]:
            num = </xsl:text><xsl:value-of select="@end" /><xsl:text>
            text = &quot;</xsl:text><xsl:value-of select="." /><xsl:text>&quot;
</xsl:text>
  </xsl:for-each>

  <!-- build tier of canonical phones -->

  <xsl:variable name="canon_phones">
    <xsl:for-each-group select="/TEI/text/body/annotationBlock/spanGrp[@type='pho-canonical']/span" group-by="@from">
      <xsl:variable name="from" select ="my:getIntervalById(/TEI,replace(current-grouping-key(),'#',''))" />
      <xsl:for-each-group select="current-group()" group-by="@to">
        <xsl:variable name="to" select ="my:getIntervalById(/TEI,replace(current-grouping-key(),'#',''))" />
        <xsl:variable name="point" select ="$from + (($to - $from) div 2)" />
        <group point="{$point}">
          <xsl:copy-of select="current-group()" />
        </group>
      </xsl:for-each-group>
    </xsl:for-each-group>
  </xsl:variable>

  <xsl:variable name="canon_phone_labels">
    <xsl:for-each select="$canon_phones/*">
      <xsl:variable name="previous_group_size" select="count(preceding-sibling::group[1]/*)" />
      <entry point="{@point}">
        <xsl:text>        points [</xsl:text><xsl:value-of select="$previous_group_size + position()"/><xsl:text>]:
              num = </xsl:text><xsl:value-of select="@point"/><xsl:text>
              text = &quot;</xsl:text>

        <xsl:for-each select="*">
          <xsl:variable name="text" select="."/>
          <xsl:value-of select="$text"/>
<!--          <xsl:if test="position() != last()">
            <xsl:text>_</xsl:text>
          </xsl:if>
-->
        </xsl:for-each>

        <xsl:text>&quot;
</xsl:text>
      </entry>
    </xsl:for-each>
  </xsl:variable>

  <!-- header for canonical phones tier -->
  <xsl:text>    item [3]:
        class = "TextTier"
        name = "Phonetik (kanonisch)"
        xmin = 0
        xmax = </xsl:text><xsl:value-of select="if ($canon_phone_labels/*[last()]/@point) then
                                                    $canon_phone_labels/*[last()]/@point  else
                                                    xs:integer(0)
                                               " /><xsl:text>
        points: size = </xsl:text><xsl:value-of select="count($canon_phone_labels/*)" /><xsl:text>
</xsl:text>

  <xsl:for-each select="$canon_phone_labels/*">
    <xsl:value-of select="."/>
  </xsl:for-each>

  <!-- build tier of realized phones -->

  <xsl:call-template name="pho-realized_header" />

  <xsl:variable name="real_phones">
    <xsl:for-each select="/TEI/text/body/((vocal|pause)|annotationBlock/(spanGrp[@type='pho-realized']/span|u/(vocal|pause)))">
      <xsl:variable name="from" select="if (name(.) = 'span')       then
                                           replace(./@from,'#', '') else
                                           replace(./@start,'#', '')
                                       " />
      <xsl:variable name="to" select="if (name(.) = 'span')     then
                                         replace(./@to,'#', '') else
                                         replace(./@end,'#', '')
                                     " />
      <xsl:variable name="text" select="if (name(.) = 'span') then
                                           .                  else
                                           (if (name(.) = 'vocal')            then
                                               concat('&lt;', ./desc, '&gt;') else
                                               '&lt;Pause&gt;'
                                           )
                                       " />
      <phone from="{my:getIntervalById(/TEI,$from)}" to="{my:getIntervalById(/TEI,$to)}">
        <xsl:value-of select="$text" />
      </phone>
    </xsl:for-each>
  </xsl:variable>

  <xsl:for-each select="$real_phones/*">
    <xsl:sort select="@from" data-type="number" />
    <xsl:text>        intervals [</xsl:text><xsl:value-of select="position() + 1" /><xsl:text>]:
            xmin = </xsl:text><xsl:value-of select="@from" /><xsl:text>
            xmax = </xsl:text><xsl:value-of select="@to" /><xsl:text>
            text = &quot;</xsl:text><xsl:value-of select="." /><xsl:text>&quot;
</xsl:text>
  </xsl:for-each>

  <xsl:call-template name="pho-realized_footer" />

  <!-- build tier of misc labels -->

  <xsl:variable name="misc">
    <xsl:for-each-group select="/TEI/text/body/annotationBlock/spanGrp[@type='misc']/span" group-by="@from">
      <xsl:variable name="point" select ="my:getIntervalById(/TEI,replace(current-grouping-key(),'#',''))" />
      <group point="{$point}">
        <xsl:copy-of select="current-group()" />
      </group>
    </xsl:for-each-group>
  </xsl:variable>

  <xsl:variable name="misc_labels">
    <xsl:for-each select="$misc/*">
      <xsl:variable name="previous_group_size" select="count(preceding-sibling::group[1]/*)" />
      <entry point="{@point}">
        <xsl:text>        points [</xsl:text><xsl:value-of select="$previous_group_size + position()"/><xsl:text>]:
              num = </xsl:text><xsl:value-of select="@point"/><xsl:text>
              text = &quot;</xsl:text>

        <xsl:for-each select="*">
          <xsl:variable name="text" select="."/>
          <xsl:value-of select="$text"/>
        </xsl:for-each>

        <xsl:text>&quot;
</xsl:text>
      </entry>
    </xsl:for-each>
  </xsl:variable>

  <!-- header for misc labels tier -->
  <xsl:text>    item [5]:
        class = "TextTier"
        name = "Misc"
        xmin = 0
        xmax = </xsl:text><xsl:value-of select="if ($misc_labels/*[last()]/@point) then
                                                    $misc_labels/*[last()]/@point  else
                                                    xs:integer(0)
                                               " /><xsl:text>
        points: size = </xsl:text><xsl:value-of select="count($misc_labels/*)" /><xsl:text>
</xsl:text>

  <xsl:for-each select="$misc_labels/*">
    <xsl:value-of select="."/>
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
          <xsl:if test="position() != last() and contains($text, 'PG')">
            <xsl:text>_</xsl:text>
          </xsl:if>
        </xsl:for-each>

        <xsl:text>&quot;
</xsl:text>
      </entry>
    </xsl:for-each>
  </xsl:variable>

  <!-- header for prosodic tier -->
  <xsl:text>    item [6]:
        class = "TextTier"
        name = "Prosodie (PROLAB)"
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
<xsl:template match="/TEI/text"></xsl:template>

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
