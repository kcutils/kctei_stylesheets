<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xdt="http://www.w3.org/2005/xpath-datatypes"
		xpath-default-namespace="http://www.tei-c.org/ns/1.0"
                version="2.0">


<xsl:output method="text"/>
  <xsl:variable name="first_timeline_entry" select="0" />
  <xsl:variable name="last_timeline_entry" select="max(/TEI/text/front/timeline/when/@interval)" />

  <xsl:variable name="word_amount" select="count(/TEI/text/body/annotationBlock/u/w) + 2" />
  <xsl:variable name="first_word_start" select="replace(/TEI/text/body/annotationBlock[1]/@start,'#', '')" />
  <xsl:variable name="last_word_end" select="replace(/TEI/text/body/annotationBlock[last()]/@end,'#', '')" />


  <xsl:variable name="pho-realized_amount" select="count(/TEI/text/body/annotationBlock/spanGrp[@type='pho-realized']/span) + 2" />
  <xsl:variable name="first_pho-realized_from" select="replace(/TEI/text/body/annotationBlock[1]/spanGrp[@type='pho-realized'][1]/span[1]/@from,'#', '')" />
  <xsl:variable name="last_pho-realized_to" select="replace(/TEI/text/body/annotationBlock[last()]/spanGrp[@type='pho-realized'][last()]/span[last()]/@to,'#', '')" />

  <xsl:variable name="pho-canonical_amount" select="count(/TEI/text/body/annotationBlock/spanGrp[@type='pho-canonical']/span) + 2" />
  <xsl:variable name="first_pho-canonical_from" select="replace(/TEI/text/body/annotationBlock[1]/spanGrp[@type='pho-canonical'][1]/span[1]/@from,'#', '')" />
  <xsl:variable name="last_pho-canonical_to" select="replace(/TEI/text/body/annotationBlock[last()]/spanGrp[@type='pho-canonical'][last()]/span[last()]/@to,'#', '')" />

<xsl:template name="header">
<xsl:text>File type = "ooTextFile"
Object class = "TextGrid"

xmin = 0
xmax = </xsl:text><xsl:value-of select="$last_timeline_entry" /><xsl:text>
tiers? &lt;exists&gt;
size = 3
item []:
</xsl:text>
</xsl:template>

<xsl:template name="word_header">
<xsl:text>    item [1]:
        class = "IntervalTier" 
        name = "words" 
        xmin = 0 
        xmax = </xsl:text><xsl:value-of select="$last_timeline_entry" /><xsl:text>
        intervals: size = </xsl:text><xsl:value-of select="$word_amount" /><xsl:text>
        intervals [1]:
            xmin = </xsl:text><xsl:value-of select="$first_timeline_entry" /><xsl:text>
            xmax = </xsl:text><xsl:value-of select="/TEI/text/front/timeline/when[@xml:id=$first_word_start]/@interval" /><xsl:text>
            text = &quot;&quot;
</xsl:text>
</xsl:template>

<xsl:template name="word_footer">
<xsl:text>        intervals [</xsl:text><xsl:value-of select="$word_amount" /><xsl:text>]:
            xmin = </xsl:text><xsl:value-of select="/TEI/text/front/timeline/when[@xml:id=$last_word_end]/@interval" /><xsl:text>
            xmin = </xsl:text><xsl:value-of select="$last_timeline_entry" /><xsl:text>
            text = &quot;&quot;
</xsl:text>
</xsl:template>

<xsl:template name="pho-realized_header">
<xsl:text>    item [2]:
        class = "IntervalTier" 
        name = "pho-realized" 
        xmin = 0 
        xmax = </xsl:text><xsl:value-of select="$last_timeline_entry" /><xsl:text>
        intervals: size = </xsl:text><xsl:value-of select="$pho-realized_amount" /><xsl:text>
        intervals [1]:
            xmin = </xsl:text><xsl:value-of select="$first_timeline_entry" /><xsl:text>
            xmax = </xsl:text><xsl:value-of select="/TEI/text/front/timeline/when[@xml:id=$first_pho-realized_from]/@interval" /><xsl:text>
            text = &quot;&quot;
</xsl:text>
</xsl:template>

<xsl:template name="pho-realized_footer">
<xsl:text>        intervals [</xsl:text><xsl:value-of select="$pho-realized_amount" /><xsl:text>]:
            xmin = </xsl:text><xsl:value-of select="/TEI/text/front/timeline/when[@xml:id=$last_pho-realized_to]/@interval" /><xsl:text>
            xmin = </xsl:text><xsl:value-of select="$last_timeline_entry" /><xsl:text>
            text = &quot;&quot;
</xsl:text>
</xsl:template>

<xsl:template name="pho-canonical_header">
<xsl:text>    item [3]:
        class = "IntervalTier"
        name = "pho-canonical"
        xmin = 0
        xmax = </xsl:text><xsl:value-of select="$last_timeline_entry" /><xsl:text>
        intervals: size = </xsl:text><xsl:value-of select="$pho-canonical_amount" /><xsl:text>
        intervals [1]:
            xmin = </xsl:text><xsl:value-of select="$first_timeline_entry" /><xsl:text>
            xmax = </xsl:text><xsl:value-of select="/TEI/text/front/timeline/when[@xml:id=$first_pho-canonical_from]/@interval" /><xsl:text>
            text = &quot;&quot;
</xsl:text>
</xsl:template>

<xsl:template name="pho-canonical_footer">
<xsl:text>        intervals [</xsl:text><xsl:value-of select="$pho-canonical_amount" /><xsl:text>]:
            xmin = </xsl:text><xsl:value-of select="/TEI/text/front/timeline/when[@xml:id=$last_pho-canonical_to]/@interval" /><xsl:text>
            xmin = </xsl:text><xsl:value-of select="$last_timeline_entry" /><xsl:text>
            text = &quot;&quot;
</xsl:text>
</xsl:template>

<xsl:template match="/">
<xsl:call-template name="header" />
<!-- build word tier -->
<xsl:call-template name="word_header" />
<xsl:for-each select="/TEI/text/body/annotationBlock/u/w">
<xsl:variable name="current_interval" select="position() + 1"/>
<xsl:variable name="start" select="replace(./../../@start,'#', '')" />
<xsl:variable name="end" select="replace(./../../@end,'#', '')" />
<xsl:text>        intervals [</xsl:text><xsl:value-of select="$current_interval" /><xsl:text>]:
            xmin = </xsl:text><xsl:value-of select="/TEI/text/front/timeline/when[@xml:id=$start]/@interval" /><xsl:text>
            xmax = </xsl:text><xsl:value-of select="/TEI/text/front/timeline/when[@xml:id=$end]/@interval" /><xsl:text>
            text = &quot;</xsl:text><xsl:value-of select="." /><xsl:text>&quot;
</xsl:text>
</xsl:for-each>
<xsl:call-template name="word_footer" />
<!-- build tier of realized phones -->
<xsl:call-template name="pho-realized_header" />
<xsl:for-each select="/TEI/text/body/annotationBlock/spanGrp[@type='pho-realized']/span">
<xsl:variable name="current_interval" select="position() + 1"/>
<xsl:variable name="from" select="replace(./@from,'#', '')" />
<xsl:variable name="to" select="replace(./@to,'#', '')" />
<xsl:text>        intervals [</xsl:text><xsl:value-of select="$current_interval" /><xsl:text>]:
            xmin = </xsl:text><xsl:value-of select="/TEI/text/front/timeline/when[@xml:id=$from]/@interval" /><xsl:text>
            xmax = </xsl:text><xsl:value-of select="/TEI/text/front/timeline/when[@xml:id=$to]/@interval" /><xsl:text>
            text = &quot;</xsl:text><xsl:value-of select="." /><xsl:text>&quot;
</xsl:text>
</xsl:for-each>
<xsl:call-template name="pho-realized_footer" />
<!-- build tier of canonical phones -->
<xsl:call-template name="pho-canonical_header" />
<xsl:for-each select="/TEI/text/body/annotationBlock/spanGrp[@type='pho-canonical']/span">
<xsl:variable name="current_interval" select="position() + 1"/>
<xsl:variable name="from" select="replace(./@from,'#', '')" />
<xsl:variable name="to" select="replace(./@to,'#', '')" />
<xsl:text>        intervals [</xsl:text><xsl:value-of select="$current_interval" /><xsl:text>]:
            xmin = </xsl:text><xsl:value-of select="/TEI/text/front/timeline/when[@xml:id=$from]/@interval" /><xsl:text>
            xmax = </xsl:text><xsl:value-of select="/TEI/text/front/timeline/when[@xml:id=$to]/@interval" /><xsl:text>
            text = &quot;</xsl:text><xsl:value-of select="." /><xsl:text>&quot;
</xsl:text>
</xsl:for-each>
<xsl:call-template name="pho-realized_footer" />
<!--
<xsl:apply-templates />
-->
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
