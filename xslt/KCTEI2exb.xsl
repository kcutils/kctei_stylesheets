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
          <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/recordingStmt/media/@url" />
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
          <xsl:value-of select="replace(./../../@start,'#','')" />
        </xsl:attribute>
        <xsl:attribute name="end">
          <xsl:value-of select="replace(./../../@end,'#','')" />
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
    <xsl:for-each select="/TEI/text/body/(vocal|pause)">
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
          <xsl:value-of select="replace(./../../@end,'#','')" />
        </xsl:attribute>
        <xsl:attribute name="end">
          <xsl:value-of select="replace(./../../@end,'#','')" />
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
      <xsl:variable name="to" select="./@to" />
      <xsl:if test="$from != $to">
        <xsl:element name="event">
          <xsl:attribute name="start">
            <xsl:value-of select="replace($from,'#','')" />
          </xsl:attribute>
          <xsl:attribute name="end">
            <xsl:value-of select="replace($to,'#','')" />
          </xsl:attribute>
          <xsl:value-of select="../*[./@from = $from and ./@to = $from and . = ../*[1]]" />
          <xsl:value-of select="." />
          <xsl:value-of select="../*[./@to = $to and ./@from = $to]" />
        </xsl:element>
      </xsl:if>
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
    </xsl:element>
  </xsl:element>
</xsl:template>

</xsl:stylesheet>
