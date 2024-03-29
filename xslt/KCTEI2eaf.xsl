<?xml version="1.0" encoding="UTF-8" ?>
<!--

  This stylesheet transforms Kiel Corpus ISO/TEI to eaf (ELAN).

  It produces six tiers:

    - words and non-verbal sounds
    - punctuations
    - canonical phones and non-verbal sounds
    - realized phones and non-verbal sounds
    - misc labels (MA mark)
    - prosodic labels

  All of these tiers are interval tiers, meaning that there cannot
  be an event with no duration (like a point in praat). Since the
  Kiel Corpus contains annotations without duration (like
  unrealized phones or sentence punctuations), we need several
  "hacks" to make them appear in ELAN:

    - Punctuations only appear after a word, so we take the words
      end as the puntuations end and take the previous timeline
      entry as the "begin" of that puncutation.
    - Canonical phones that are not realized will be concatenated
      with phones that belong to the same word.
    - Prosodic labels are assigned to a single point in time.
      This point is taken as the end of a label and the previous
      timeline entry is taken as the begin of a label. Furthermore
      all prosodic labels that are assigned to the same point in
      time will be concatenated using a certain symbol. If phrase
      end and phrase begin coincide another symbol will used to
      seperate labels that belong to different phrases.


-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xpath-default-namespace="http://www.tei-c.org/ns/1.0"
                version="2.0">

<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />

<xsl:variable name="now" select="current-dateTime()"/>

<xsl:template name="header">
  <xsl:element name="HEADER">
    <xsl:attribute name="MEDIA_FILE">
    </xsl:attribute>
    <xsl:attribute name="TIME_UNITS">
      <xsl:text>milliseconds</xsl:text>
    </xsl:attribute>
    <xsl:element name="MEDIA_DESCRIPTOR">
      <xsl:attribute name="MEDIA_URL">
        <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/recordingStmt/recording/media/@url" />
      </xsl:attribute>
      <xsl:attribute name="MIME_TYPE">
        <xsl:text>audio/x-wav</xsl:text>
      </xsl:attribute>
    </xsl:element>
  </xsl:element>
</xsl:template>

<xsl:template name="timeline">
  <xsl:element name="TIME_ORDER">
    <xsl:for-each select="/TEI/text/timeline/when">
      <xsl:element name="TIME_SLOT">
        <xsl:attribute name="TIME_SLOT_ID">
          <xsl:value-of select="./@xml:id" />
        </xsl:attribute>
        <xsl:attribute name="TIME_VALUE">
          <xsl:value-of select="if (./@xml:id = 'T0') then '0' else ( ceiling(./@interval * 1000 ))" />
        </xsl:attribute>
      </xsl:element>
    </xsl:for-each>
  </xsl:element>
</xsl:template>

<xsl:template name="words_inci_tier">
  <xsl:element name="TIER">
    <xsl:attribute name="LINGUISTIC_TYPE_REF">
      <xsl:text>default-lt</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="TIER_ID">
      <xsl:text>Wörter und Geräusche</xsl:text>
    </xsl:attribute>
    <xsl:for-each select="(/TEI/text/body/annotationBlock/u/w)|//(vocal|pause)">
      <xsl:element name="ANNOTATION">
        <xsl:element name="ALIGNABLE_ANNOTATION">
          <xsl:attribute name="ANNOTATION_ID">
            <xsl:value-of select="./@xml:id" />
          </xsl:attribute>
          <xsl:choose>
            <xsl:when test="name(.) = 'w'">
              <xsl:attribute name="TIME_SLOT_REF1">
                <xsl:value-of select="replace(./@synch,'#','')" />
              </xsl:attribute>
              <xsl:attribute name="TIME_SLOT_REF2">
                <xsl:value-of select="replace(following::anchor[1]/@synch,'#','')" />
              </xsl:attribute>
              <xsl:element name="ANNOTATION_VALUE">
                <xsl:value-of select="." />
              </xsl:element>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="TIME_SLOT_REF1">
                <xsl:value-of select="replace(./@start, '#', '')" />
              </xsl:attribute>
              <xsl:attribute name="TIME_SLOT_REF2">
                <xsl:value-of select="replace(./@end, '#', '')" />
              </xsl:attribute>
              <xsl:element name="ANNOTATION_VALUE">
                <xsl:value-of select="if (name(.) = 'vocal')             then
                                          concat('&lt;', ./desc, '&gt;') else
                                          '&lt;Pause&gt;'
                                     " />
              </xsl:element>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:element>
      </xsl:element>
    </xsl:for-each>
  </xsl:element>
</xsl:template>

<xsl:template name="punctuations_tier">
  <xsl:element name="TIER">
    <xsl:attribute name="LINGUISTIC_TYPE_REF">
      <xsl:text>default-lt</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="TIER_ID">
      <xsl:text>Satzzeichen</xsl:text>
    </xsl:attribute>
    <xsl:for-each select="TEI/text/body/annotationBlock/u/pc">
      <xsl:element name="ANNOTATION">
        <xsl:element name="ALIGNABLE_ANNOTATION">
          <xsl:attribute name="ANNOTATION_ID">
            <xsl:value-of select="./@xml:id" />
          </xsl:attribute>
          <!-- we need some extension in time,
               so take the last time mark
            -->
          <xsl:attribute name="TIME_SLOT_REF1">
            <xsl:value-of select="concat('T', xs:integer(replace(preceding::anchor[1]/@synch,'#T','')) - 1)" />
          </xsl:attribute>
          <xsl:attribute name="TIME_SLOT_REF2">
            <xsl:value-of select="replace(preceding::anchor[1]/@synch,'#','')" />
          </xsl:attribute>
          <xsl:element name="ANNOTATION_VALUE">
            <xsl:value-of select="." />
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:for-each>
  </xsl:element>
</xsl:template>

<xsl:template name="pho-canonical_inci_tier">
  <xsl:element name="TIER">
    <xsl:attribute name="LINGUISTIC_TYPE_REF">
      <xsl:text>default-lt</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="TIER_ID">
      <xsl:text>Phonetik (kanonisch)</xsl:text>
    </xsl:attribute>
    <xsl:for-each select="(/TEI/text/body/annotationBlock/spanGrp[@type='pho-canonical']/span)|//(vocal|pause)">

      <xsl:choose>
        <xsl:when test="name(.) = 'span'">
          <xsl:variable name="from" select="./@from" />
          <xsl:variable name="from_val" select="xs:integer(replace($from, '#T', ''))" />
          <xsl:variable name="to" select="./@to" />
          <xsl:variable name="to_val" select="xs:integer(replace($to, '#T', ''))" />
          <xsl:variable name="word">
            <xsl:for-each select="../../u/w">
              <xsl:variable name="w_begin" select="@synch" />
              <xsl:variable name="w_begin_val" select="xs:integer(replace($w_begin, '#T', ''))" />
              <xsl:variable name="w_end" select="following::anchor[1]/@synch" />
              <xsl:variable name="w_end_val" select="xs:integer(replace($w_end, '#T', ''))" />
              <xsl:if test="$from_val ge $w_begin_val and
                            $to_val   ge $w_begin_val and
                            $from_val le $w_end_val   and
                            $to_val   le $w_end_val">
                <w begin="{$w_begin_val}" end="{$w_end_val}">
                  <xsl:value-of select="." />
                </w>
              </xsl:if>
            </xsl:for-each>
          </xsl:variable>
          <xsl:variable name="word_from" select="$word/*[1]/@begin" as="xs:integer" />
          <xsl:variable name="word_to" select="$word/*[1]/@end" as="xs:integer" />
          <xsl:if test="$from != $to">
            <xsl:element name="ANNOTATION">
              <xsl:element name="ALIGNABLE_ANNOTATION">
                <xsl:attribute name="ANNOTATION_ID">
                  <xsl:value-of select="./@xml:id" />
                </xsl:attribute>
                <xsl:attribute name="TIME_SLOT_REF1">
                  <xsl:value-of select="replace($from,'#','')" />
                </xsl:attribute>
                <xsl:attribute name="TIME_SLOT_REF2">
                  <xsl:value-of select="replace($to,'#','')" />
                </xsl:attribute>
                <xsl:element name="ANNOTATION_VALUE">

                  <!-- put all unrealized phones (from=to)
                       in front of the current phone if they begin at the same time
                       and if they belong to the same word as the current phone -->
                  <xsl:for-each select="../*[./@from = $from and
                                             ./@to   = $from and
                                             xs:integer(replace(./@from, '#T', '')) eq $word_from and
                                             xs:integer(replace(./@from, '#T', '')) le $word_to]">
                    <xsl:value-of select="." />
                    <xsl:text>_</xsl:text>
                  </xsl:for-each>

                  <xsl:value-of select="." />

                  <!-- put all unrealized phones (from=to)
                       after the current phone if they end at the same time
                       and if they belong to the same word as the current phone -->
                  <xsl:for-each select="../*[./@to   = $to and
                                             ./@from = $to and
                                             xs:integer(replace(./@to, '#T', '')) gt $word_from and
                                             xs:integer(replace(./@to, '#T', '')) lt $word_to]">
                    <xsl:text>_</xsl:text>
                    <xsl:value-of select="." />
                  </xsl:for-each>
                </xsl:element>
              </xsl:element>
            </xsl:element>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:element name="ANNOTATION">
            <xsl:element name="ALIGNABLE_ANNOTATION">
              <xsl:attribute name="ANNOTATION_ID">
                <xsl:value-of select="generate-id(.)" />
              </xsl:attribute>
              <xsl:attribute name="TIME_SLOT_REF1">
                <xsl:value-of select="replace(./@start,'#','')" />
              </xsl:attribute>
              <xsl:attribute name="TIME_SLOT_REF2">
                <xsl:value-of select="replace(./@end,'#','')" />
              </xsl:attribute>
              <xsl:element name="ANNOTATION_VALUE">
                <xsl:value-of select="if (name(.) = 'vocal') then
                                         concat('&lt;', ./desc, '&gt;') else
                                         '&lt;Pause&gt;'
                                     " />
              </xsl:element>
            </xsl:element>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:element>
</xsl:template>

<xsl:template name="pho-realized_inci_tier">
  <xsl:element name="TIER">
    <xsl:attribute name="LINGUISTIC_TYPE_REF">
      <xsl:text>default-lt</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="TIER_ID">
      <xsl:text>Phonetik (realisiert)</xsl:text>
    </xsl:attribute>
    <xsl:for-each select="(/TEI/text/body/annotationBlock/spanGrp[@type='pho-realized']/span)|//(vocal|pause)">
      <xsl:element name="ANNOTATION">
        <xsl:element name="ALIGNABLE_ANNOTATION">
          <xsl:attribute name="ANNOTATION_ID">
            <xsl:value-of select="if (name(.) = 'span') then
                                     ./@xml:id          else
                                     generate-id(.)" />
          </xsl:attribute>
          <xsl:attribute name="TIME_SLOT_REF1">
            <xsl:value-of select="if (name(.) = 'span')         then
                                     replace(./@from,  '#', '') else
                                     replace(./@start, '#', '')
                                 " />
          </xsl:attribute>
          <xsl:attribute name="TIME_SLOT_REF2">
            <xsl:value-of select="if (name(.) = 'span')         then
                                     replace(./@to,  '#', '') else
                                     replace(./@end, '#', '')
                                 " />
          </xsl:attribute>
          <xsl:element name="ANNOTATION_VALUE">
            <xsl:value-of select="if (name(.) = 'span') then
                                     .                  else
                                     (if (name(.) = 'vocal') then
                                         concat('&lt;', ./desc, '&gt;') else
                                         '&lt;Pause&gt;'
                                     )
                                 " />
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:for-each>
  </xsl:element>
</xsl:template>

<xsl:template name="misc_tier">
  <xsl:element name="TIER">
    <xsl:attribute name="LINGUISTIC_TYPE_REF">
      <xsl:text>default-lt</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="TIER_ID">
      <xsl:text>Misc</xsl:text>
    </xsl:attribute>
    <xsl:for-each select="/TEI/text/body/annotationBlock/spanGrp[@type='misc']/span">
      <xsl:element name="ANNOTATION">
        <xsl:element name="ALIGNABLE_ANNOTATION">
          <xsl:attribute name="ANNOTATION_ID">
            <xsl:value-of select="./@xml:id" />
          </xsl:attribute>

          <xsl:variable name="from" select="replace(./@from,'#','')" />
          <xsl:variable name="end" select="replace(./@to,'#','')" />

          <xsl:attribute name="TIME_SLOT_REF1">
            <xsl:value-of select="$from" />
          </xsl:attribute>
          <xsl:choose>
            <xsl:when test="$from != $end">
              <xsl:attribute name="TIME_SLOT_REF2">
                <xsl:value-of select="$end" />
              </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <!-- we need some extension in time,
                   so take the last time mark
                -->
              <xsl:attribute name="TIME_SLOT_REF2">
                <xsl:value-of select="concat('T', xs:integer(replace($end,'T','')) + 1)" />
              </xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:element name="ANNOTATION_VALUE">
            <xsl:value-of select="." />
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:for-each>
  </xsl:element>
</xsl:template>

<xsl:template name="prosody_tier">
  <xsl:element name="TIER">
    <xsl:attribute name="LINGUISTIC_TYPE_REF">
      <xsl:text>default-lt</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="TIER_ID">
      <xsl:text>Prosodie (PROLAB)</xsl:text>
    </xsl:attribute>

    <xsl:variable name="groups">
      <xsl:for-each-group select="/TEI/text/body/annotationBlock/spanGrp[@type='prolab']/span" group-by="@from">
        <xsl:variable name="from" select ="replace(./@from,'#','')" />
        <group from="{$from}">
          <xsl:copy-of select="current-group()" />
        </group>
      </xsl:for-each-group>
    </xsl:variable>

    <xsl:for-each select="$groups/*">
      <xsl:element name="ANNOTATION">
        <xsl:element name="ALIGNABLE_ANNOTATION">
          <xsl:attribute name="ANNOTATION_ID">
            <xsl:value-of select="generate-id(.)" />
          </xsl:attribute>

          <!-- we need some extension in time,
               so take the previous time mark if there is no following one -->

          <xsl:variable name="to_mark_name" select="concat('T', xs:integer(replace(@from, 'T', '')) + 1)" />

          <xsl:attribute name="TIME_SLOT_REF1">
            <xsl:choose>
              <xsl:when test="/TEI/text/timeline/when[@id=$to_mark_name]">
                <xsl:value-of select="@from" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat('T', xs:integer(replace(@from, 'T', '')) - 1)" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>

          <!-- we need some extension in time,
               so take the next time mark if it exists -->

          <xsl:attribute name="TIME_SLOT_REF2">
            <xsl:choose>
              <xsl:when test="/TEI/text/timeline/when[@id=$to_mark_name]">
                <xsl:value-of select="concat('T', xs:integer(replace(@from, 'T', '')) + 1)" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@from" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>

          <xsl:element name="ANNOTATION_VALUE">
            <xsl:for-each select="*">
              <xsl:variable name="text" select="."/>
              <xsl:value-of select="$text"/>
              <xsl:if test="position() != last() and contains($text, 'PG')">
                <xsl:text>_</xsl:text>
              </xsl:if>
            </xsl:for-each>
          </xsl:element>

        </xsl:element>
      </xsl:element>
    </xsl:for-each>
  </xsl:element>
</xsl:template>

<xsl:template name="footer">
  <xsl:element name="LINGUISTIC_TYPE">
    <xsl:attribute name="GRAPHIC_REFERENCES">
      <xsl:text>false</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="LINGUISTIC_TYPE_ID">
      <xsl:text>default-lt</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="TIME_ALIGNABLE">
      <xsl:text>true</xsl:text>
    </xsl:attribute>
  </xsl:element>
</xsl:template>

<xsl:template match="/">
  <xsl:comment> File transformed from Kiel Corpus ISO/TEI (KCTEI)-Format to eaf using KCTEI2eaf-stylesheet on <xsl:value-of select="$now" />. </xsl:comment>
  <xsl:element name="ANNOTATION_DOCUMENT">
    <xsl:attribute name="AUTHOR">
    </xsl:attribute>
    <xsl:attribute name="DATE">
      <xsl:value-of  select="current-dateTime()"/>
    </xsl:attribute>
    <xsl:attribute name="FORMAT">
      <xsl:text>3.0</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="VERSION">
      <xsl:text>3.0</xsl:text>
    </xsl:attribute>
<!--
    <xsl:attribute name="xmlns:xsi">
      <xsl:text>http://www.w3.org/2001/XMLSchema-instance</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="xsi:noNamespaceSchemaLocation">
      <xsl:text>http://www.mpi.nl/tools/elan/EAFv3.0.xsd</xsl:text>
    </xsl:attribute>
-->
    <xsl:call-template name="header" />
    <xsl:call-template name="timeline" />

    <xsl:call-template name="words_inci_tier" />
    <xsl:call-template name="punctuations_tier" />
    <xsl:call-template name="pho-canonical_inci_tier" />
    <xsl:call-template name="pho-realized_inci_tier" />
    <xsl:call-template name="misc_tier" />
    <xsl:call-template name="prosody_tier" />

    <xsl:call-template name="footer" />
  </xsl:element>
</xsl:template>

</xsl:stylesheet>
