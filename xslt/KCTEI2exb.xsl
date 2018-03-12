<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xdt="http://www.w3.org/2005/xpath-datatypes"
                xmlns:my="http://myohmy.example.com"
                xpath-default-namespace="http://www.tei-c.org/ns/1.0"
                version="2.0">

<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />

<xsl:template name="head">
  <xsl:element name="head">
    <xsl:element name="meta-information">
      <xsl:element name="project-name" />
      <xsl:element name="transcription-name" />
      <xsl:element name="referenced-file">
        <xsl:attribute name="url">
          <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/recordingStmt/recording/media/@url" />
        </xsl:attribute>
      </xsl:element>
      <xsl:element name="ud-meta-information" />
      <xsl:element name="comment" />
      <xsl:element name="transcription-convention" />
    </xsl:element>
    <xsl:element name="speakertable" />
  </xsl:element>
</xsl:template>

<xsl:template name="timeline">
  <xsl:element name="common-timeline">
    <xsl:for-each select="/TEI/text/front/timeline/when">
      <xsl:element name="tli">
        <xsl:attribute name="id">
          <xsl:value-of select="./@xml:id" />
        </xsl:attribute>
        <xsl:attribute name="time">
          <xsl:value-of select="if (./@xml:id = 'T0') then '0.0' else ./@interval" />
        </xsl:attribute>
      </xsl:element>
    </xsl:for-each>
  </xsl:element>
</xsl:template>

<xsl:template name="words_tier">
  <xsl:element name="tier">
    <xsl:attribute name="id">
      <xsl:text>TIE0</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="category">
      <xsl:text>words</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="type">
      <xsl:text>t</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="display-name">
      <xsl:text>[words]</xsl:text>
    </xsl:attribute>
    <xsl:for-each select="/TEI/text/body/annotationBlock/u/w">
      <xsl:element name="event">
        <xsl:attribute name="start">
          <xsl:value-of select="replace(./@synch,'#','')" />
        </xsl:attribute>
        <xsl:attribute name="end">
          <xsl:value-of select="replace(following::anchor[1]/@synch,'#','')" />
        </xsl:attribute>
        <xsl:value-of select="." />
      </xsl:element>
    </xsl:for-each>
  </xsl:element>
</xsl:template>

<xsl:template name="incidents_tier">
  <xsl:element name="tier">
    <xsl:attribute name="id">
      <xsl:text>TIE1</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="category">
      <xsl:text>incidents</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="type">
      <xsl:text>d</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="display-name">
      <xsl:text>[incidents]</xsl:text>
    </xsl:attribute>
    <xsl:for-each select="//(vocal|pause)">
      <xsl:element name="event">
        <xsl:attribute name="start">
          <xsl:value-of select="replace(./@start,'#','')" />
        </xsl:attribute>
        <xsl:attribute name="end">
          <xsl:value-of select="replace(./@end,'#','')" />
        </xsl:attribute>
        <xsl:value-of select="if (name(.) = 'vocal') then ./desc else 'pause'" />
      </xsl:element>
    </xsl:for-each>
  </xsl:element>
</xsl:template>

<xsl:template name="punctuations_tier">
  <xsl:element name="tier">
    <xsl:attribute name="id">
      <xsl:text>TIE2</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="category">
      <xsl:text>punctuations</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="type">
      <xsl:text>d</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="display-name">
      <xsl:text>[punctuations]</xsl:text>
    </xsl:attribute>
    <xsl:for-each select="/TEI/text/body/annotationBlock/u/pc">
      <xsl:element name="event">
        <xsl:attribute name="start">
          <!-- we need some extension in time,
               so take the last time mark -->
          <xsl:value-of select="concat('T', xs:integer(replace(preceding::anchor[1]/@synch,'#T','')) - 1)" />
        </xsl:attribute>
        <xsl:attribute name="end">
          <xsl:value-of select="replace(preceding::anchor[1]/@synch,'#','')" />
        </xsl:attribute>
        <xsl:value-of select="." />
      </xsl:element>
    </xsl:for-each>
  </xsl:element>
</xsl:template>

<xsl:template name="pho-realized_tier">
  <xsl:element name="tier">
    <xsl:attribute name="id">
      <xsl:text>TIE3</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="category">
      <xsl:text>pho-realized</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="type">
      <xsl:text>a</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="display-name">
      <xsl:text>[pho-realized]</xsl:text>
    </xsl:attribute>
    <xsl:for-each select="/TEI/text/body/annotationBlock/spanGrp[@type='pho-realized']/span">
      <xsl:element name="event">
        <xsl:attribute name="start">
          <xsl:value-of select="replace(./@from,'#','')" />
        </xsl:attribute>
        <xsl:attribute name="end">
          <xsl:value-of select="replace(./@to,'#','')" />
        </xsl:attribute>
        <xsl:value-of select="." />
      </xsl:element>
    </xsl:for-each>
  </xsl:element>
</xsl:template>

<xsl:template name="pho-canonical_tier">
  <xsl:element name="tier">
    <xsl:attribute name="id">
      <xsl:text>TIE4</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="category">
      <xsl:text>pho-canonical</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="type">
      <xsl:text>a</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="display-name">
      <xsl:text>[pho-canonical]</xsl:text>
    </xsl:attribute>
    <xsl:for-each select="/TEI/text/body/annotationBlock/spanGrp[@type='pho-canonical']/span">
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
        <xsl:element name="event">
          <xsl:attribute name="start">
            <xsl:value-of select="replace($from,'#','')" />
          </xsl:attribute>
          <xsl:attribute name="end">
            <xsl:value-of select="replace($to,'#','')" />
          </xsl:attribute>
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
      </xsl:if>
    </xsl:for-each>
  </xsl:element>
</xsl:template>

<xsl:template name="prosody_tier">
  <xsl:element name="tier">
    <xsl:attribute name="id">
      <xsl:text>TIE5</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="category">
      <xsl:text>prolab</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="type">
      <xsl:text>a</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="display-name">
      <xsl:text>[prolab]</xsl:text>
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
      <xsl:element name="event">

        <!-- we need some extension in time,
             so take the previous time mark if there is no following one -->

        <xsl:variable name="to_mark_name" select="concat('T', xs:integer(replace(@from, 'T', '')) + 1)" />

        <xsl:attribute name="start">
          <xsl:choose>
            <xsl:when test="/TEI/text/front/timeline/when[@id=$to_mark_name]">
              <xsl:value-of select="@from" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat('T', xs:integer(replace(@from, 'T', '')) - 1)" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>

        <!-- we need some extension in time,
             so take the next time mark if it exists -->

        <xsl:attribute name="end">
          <xsl:choose>
            <xsl:when test="/TEI/text/front/timeline/when[@id=$to_mark_name]">
              <xsl:value-of select="concat('T', xs:integer(replace(@from, 'T', '')) + 1)" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@from" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
   
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
      </xsl:element>
    </xsl:for-each>
  </xsl:element>
</xsl:template>

<xsl:template match="/">
  <xsl:comment> (c) http://www.rrz.uni-hamburg.de/exmaralda </xsl:comment>
  <xsl:element name="basic-transcription">
    <xsl:call-template name="head" />
    <xsl:element name="basic-body">
      <xsl:call-template name="timeline" />
      <xsl:call-template name="words_tier" />
      <xsl:call-template name="incidents_tier" />
      <xsl:call-template name="punctuations_tier" />
      <xsl:call-template name="pho-realized_tier" />
      <xsl:call-template name="pho-canonical_tier" />
      <xsl:call-template name="prosody_tier" />
    </xsl:element>
  </xsl:element>
</xsl:template>

</xsl:stylesheet>
