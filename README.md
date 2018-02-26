
This is a collection of XSLT-Stylesheets to transform Kiel Corpus TEI
files (KCTEI) into file formats for specific linguistic software.

stylesheets are XSLT 2.0  
Transformation can be done using Saxon-HE (http://saxon.sourceforge.net/).

This directory contains a wrapper shell script to call Saxon-HE.

Examples

Produce some praat TextGrid output:
```
$ ./xsltproc.sh k01be003.xml xslt/KCTEI2TextGrid.xsl
```

