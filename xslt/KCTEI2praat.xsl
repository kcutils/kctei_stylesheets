<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xdt="http://www.w3.org/2005/xpath-datatypes"
		xpath-default-namespace="http://www.tei-c.org/ns/1.0"
                version="2.0">

<xsl:output method="text"/>

<!-- two approaches possible:

     1. get sound file name from XML file and
        expect TextGrid file name to be like input XML file name, but
        with .TextGrid ending
     2. expect sound file name and TextGrid file name to be like input
        XML file name

     sound file name from XML should be in
       /TEI/teiHeader/fileDesc/sourceDesc/recordingStmt/media/@url

     We take the second approach until someone sometimes somewhere
     will realize that the first one might be better ...

-->

<xsl:variable name="basename" select="tokenize(tokenize(base-uri(), 'file:')[last()], '\.xml')[1]" />

<xsl:template match="/">
<xsl:text>Read from file: &quot;</xsl:text><xsl:value-of select="$basename" /><xsl:text>.wav&quot;
Read from file: &quot;</xsl:text><xsl:value-of select="$basename" /><xsl:text>.TextGrid&quot;
</xsl:text>
</xsl:template>

<!--
<xsl:template match="*/text()[normalize-space()]">
    <xsl:value-of select="normalize-space()"/>
</xsl:template>

<xsl:template match="*/text()[not(normalize-space())]" />
-->

</xsl:stylesheet>
