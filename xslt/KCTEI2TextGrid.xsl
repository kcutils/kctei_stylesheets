<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xdt="http://www.w3.org/2005/xpath-datatypes"
                xmlns:my="http://myohmy.example.com"
                xpath-default-namespace="http://www.tei-c.org/ns/1.0"
                version="2.0">

<!--
  If there are gaps between intervals the end of a preceeding interval will not
  be shown correctly in praat. Praat needs an uninteruppted timesequence of
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

<xsl:output method="text"/>
  <xsl:variable name="first_timeline_entry" select="0" />
  <xsl:variable name="last_timeline_entry" select="max(/TEI/text/front/timeline/when/@interval)" />

  <xsl:variable name="word_amount" select="count(/TEI/text/body/annotationBlock/u/w)" />
  <xsl:variable name="first_word_start" select="my:getIntervalById(/TEI,replace(/TEI/text/body/annotationBlock[1]/u/w[1]/@synch,'#', ''))" />
  <xsl:variable name="last_word_end" select="my:getIntervalById(/TEI,replace((/TEI/text/body/annotationBlock[last()]/u/anchor)[last()]/@synch,'#', ''))" />

  <xsl:variable name="punctuations_amount" select="count(/TEI/text/body/annotationBlock/u/pc)" />

  <xsl:variable name="incidents_amount" select="count(/TEI/text/body/((vocal|pause)|annotationBlock/u/(pause|vocal))) + 2" />
  <xsl:variable name="first_body_inci_start" select="my:getIntervalById(/TEI,replace((/TEI/text/body/(pause|vocal))[1]/@start,'#', ''))" />
  <xsl:variable name="first_u_inci_start" select="my:getIntervalById(/TEI,replace((/TEI/text/body/annotationBlock/u/(pause|vocal))[1]/@start,'#', ''))" />
  <xsl:variable name="first_inci_start" select="min(($first_body_inci_start, $first_u_inci_start))" />

  <xsl:variable name="last_body_inci_end" select="my:getIntervalById(/TEI,replace((/TEI/text/body/(pause|vocal))[last()]/@end,'#', ''))" />
  <xsl:variable name="last_u_inci_end" select="my:getIntervalById(/TEI,replace((/TEI/text/body/annotationBlock/u/(pause|vocal))[last()]/@end,'#', ''))" />
  <xsl:variable name="last_inci_end" select="max(($last_body_inci_end, $last_u_inci_end))" />

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
size = 4
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
<xsl:variable name="start" select="if (name(.) = 'w') then replace(./@synch,'#', '') else replace(./@start,'#', '')" />
<xsl:variable name="end" select="if (name(.) = 'w') then replace(following::anchor[1]/@synch,'#', '') else replace(./@end,'#', '')" />
<xsl:variable name="text" select="if (name(.) = 'w') then . else (if (name(.) = 'vocal') then concat('&lt;', ./desc, '&gt;') else '&lt;pause&gt;')" />

<xsl:text>        intervals [</xsl:text><xsl:value-of select="$current_interval" /><xsl:text>]:
            xmin = </xsl:text><xsl:value-of select="my:getIntervalById(/TEI,$start)" /><xsl:text>
            xmax = </xsl:text><xsl:value-of select="my:getIntervalById(/TEI,$end)" /><xsl:text>
            text = &quot;</xsl:text><xsl:value-of select="$text" /><xsl:text>&quot;
</xsl:text>
</xsl:for-each>
<xsl:call-template name="wordinc_footer" />
<!-- build tier for incidents
<xsl:call-template name="incident_header" />
<xsl:for-each select="/TEI/text/body/annotationBlock/u/(vocal|pause)">
<xsl:variable name="current_interval" select="position() + 1"/>
<xsl:variable name="start" select="replace(./@start,'#', '')" />
<xsl:variable name="end" select="replace(./@end,'#', '')" />
<xsl:variable name="text" select="if (name(.) = 'vocal') then ./desc else 'pause'" />

<xsl:text>        intervals [</xsl:text><xsl:value-of select="$current_interval" /><xsl:text>]:
            xmin = </xsl:text><xsl:value-of select="my:getIntervalById(/TEI,$start)" /><xsl:text>
            xmax = </xsl:text><xsl:value-of select="my:getIntervalById(/TEI,$end)" /><xsl:text>
            text = &quot;</xsl:text><xsl:value-of select="$text" /><xsl:text>&quot;
</xsl:text>
</xsl:for-each>
<xsl:call-template name="incident_footer" />
-->
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
<xsl:variable name="from" select="if (name(.) = 'span') then replace(./@from,'#', '') else replace(./@start,'#', '')" />
<xsl:variable name="to" select="if (name(.) = 'span') then replace(./@to,'#', '') else replace(./@end,'#', '')" />
<xsl:variable name="text" select="if (name(.) = 'span') then . else ''" />
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
