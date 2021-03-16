
This is a collection of XSLT-Stylesheets to transform Kiel Corpus
ISO/TEI files (KCTEI) into file formats for specific linguistic
software.

stylesheets are XSLT 2.0  

Transformation can be done using Saxon-HE
(http://saxon.sourceforge.net/).

This directory contains wrapper scripts to call Saxon-HE using
Java. For now you only need saxon.jar in ./lib/ to use these
scripts which can be a link to saxon-he-10.3.jar for example.

Examples

Produce some praat TextGrid output:
```
$ ./xsltproc.sh data/g111a00l.xml xslt/KCTEI2TextGrid.xsl
```

