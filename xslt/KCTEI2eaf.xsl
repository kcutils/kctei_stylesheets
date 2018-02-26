<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xdt="http://www.w3.org/2005/xpath-datatypes"
                xmlns:my="http://myohmy.example.com"
                xpath-default-namespace="http://www.tei-c.org/ns/1.0"
                version="2.0">

<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />

<xsl:template name="header">
  <xsl:element name="HEADER">
    <xsl:attribute name="MEDIA_FILE">
    </xsl:attribute>
    <xsl:attribute name="TIME_UNITS">
      <xsl:text>milliseconds</xsl:text>
    </xsl:attribute>
    <xsl:element name="MEDIA_DESCRIPTOR">
      <xsl:attribute name="MEDIA_URL">
        <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/recordingStmt/media/@url" />
      </xsl:attribute>
      <xsl:attribute name="MIME_TYPE">
        <xsl:text>audio/x-wav</xsl:text>
      </xsl:attribute>
    </xsl:element>
  </xsl:element>
</xsl:template>

<xsl:template name="timeline">
  <xsl:element name="TIME_ORDER">
    <xsl:for-each select="/TEI/text/front/timeline/when">
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

<xsl:template name="words_tier">
  <xsl:element name="TIER">
    <xsl:attribute name="LINGUISTIC_TYPE_REF">
      <xsl:text>default-lt</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="TIER_ID">
      <xsl:text>words</xsl:text>
    </xsl:attribute>
    <xsl:for-each select="/TEI/text/body/annotationBlock/u/w">
      <xsl:element name="ANNOTATION">
        <xsl:element name="ALIGNABLE_ANNOTATION">
          <xsl:attribute name="ANNOTATION_ID">
            <xsl:value-of select="./@xml:id" />
          </xsl:attribute>
          <xsl:attribute name="TIME_SLOT_REF1">
            <xsl:value-of select="replace(./../../@start,'#','')" />
          </xsl:attribute>
          <xsl:attribute name="TIME_SLOT_REF2">
            <xsl:value-of select="replace(./../../@end,'#','')" />
          </xsl:attribute>
          <xsl:element name="ANNOTATION_VALUE">
            <xsl:value-of select="." />
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:for-each>
  </xsl:element>
</xsl:template>

<xsl:template name="incidents_tier">
  <xsl:element name="TIER">
    <xsl:attribute name="LINGUISTIC_TYPE_REF">
      <xsl:text>default-lt</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="TIER_ID">
      <xsl:text>incidents</xsl:text>
    </xsl:attribute>
    <xsl:for-each select="/TEI/text/body/(vocal|pause)">
      <xsl:element name="ANNOTATION">
        <xsl:element name="ALIGNABLE_ANNOTATION">
          <xsl:attribute name="ANNOTATION_ID">
<!--
            <xsl:value-of select="./@xml:id" />
-->
            <xsl:value-of select="generate-id()" />
          </xsl:attribute>
          <xsl:attribute name="TIME_SLOT_REF1">
            <xsl:value-of select="replace(./@start,'#','')" />
          </xsl:attribute>
          <xsl:attribute name="TIME_SLOT_REF2">
            <xsl:value-of select="replace(./@end,'#','')" />
          </xsl:attribute>
          <xsl:element name="ANNOTATION_VALUE">
            <xsl:value-of select="if (name(.) = 'vocal') then ./desc else 'pause'" />
          </xsl:element>
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
      <xsl:text>punctuations</xsl:text>
    </xsl:attribute>
    <xsl:for-each select="TEI/text/body/annotationBlock/u/pc">
      <xsl:element name="ANNOTATION">
        <xsl:element name="ALIGNABLE_ANNOTATION">
          <xsl:attribute name="ANNOTATION_ID">
            <xsl:value-of select="./@xml:id" />
          </xsl:attribute>
          <xsl:attribute name="TIME_SLOT_REF1">
            <xsl:value-of select="replace(./../../@end,'#','')" />
          </xsl:attribute>
          <xsl:attribute name="TIME_SLOT_REF2">
            <xsl:value-of select="replace(./../../@end,'#','')" />
          </xsl:attribute>
          <xsl:element name="ANNOTATION_VALUE">
            <xsl:value-of select="." />
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:for-each>
  </xsl:element>
</xsl:template>

<xsl:template name="pho-realized_tier">
  <xsl:element name="TIER">
    <xsl:attribute name="LINGUISTIC_TYPE_REF">
      <xsl:text>default-lt</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="TIER_ID">
      <xsl:text>pho-realized</xsl:text>
    </xsl:attribute>
    <xsl:for-each select="/TEI/text/body/annotationBlock/spanGrp[@type='pho-realized']/span">
      <xsl:element name="ANNOTATION">
        <xsl:element name="ALIGNABLE_ANNOTATION">
          <xsl:attribute name="ANNOTATION_ID">
            <xsl:value-of select="./@xml:id" />
          </xsl:attribute>
          <xsl:attribute name="TIME_SLOT_REF1">
            <xsl:value-of select="replace(./@from,'#','')" />
          </xsl:attribute>
          <xsl:attribute name="TIME_SLOT_REF2">
            <xsl:value-of select="replace(./@to,'#','')" />
          </xsl:attribute>
          <xsl:element name="ANNOTATION_VALUE">
            <xsl:value-of select="." />
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:for-each>
  </xsl:element>
</xsl:template>

<xsl:template name="pho-canonical_tier">
  <xsl:element name="TIER">
    <xsl:attribute name="LINGUISTIC_TYPE_REF">
      <xsl:text>default-lt</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="TIER_ID">
      <xsl:text>pho-canonical</xsl:text>
    </xsl:attribute>
    <xsl:for-each select="/TEI/text/body/annotationBlock/spanGrp[@type='pho-canonical']/span">
      <xsl:element name="ANNOTATION">
        <xsl:element name="ALIGNABLE_ANNOTATION">
          <xsl:attribute name="ANNOTATION_ID">
            <xsl:value-of select="./@xml:id" />
          </xsl:attribute>
          <xsl:attribute name="TIME_SLOT_REF1">
            <xsl:value-of select="replace(./@from,'#','')" />
          </xsl:attribute>
          <xsl:attribute name="TIME_SLOT_REF2">
            <xsl:value-of select="replace(./@to,'#','')" />
          </xsl:attribute>
          <xsl:element name="ANNOTATION_VALUE">
            <xsl:value-of select="." />
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:for-each>
  </xsl:element>
</xsl:template>

<!--
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
-->

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

    <xsl:call-template name="words_tier" />
    <xsl:call-template name="incidents_tier" />
    <xsl:call-template name="punctuations_tier" />
    <xsl:call-template name="pho-realized_tier" />
    <xsl:call-template name="pho-canonical_tier" />

    <xsl:call-template name="footer" />
  </xsl:element>
</xsl:template>

</xsl:stylesheet>
