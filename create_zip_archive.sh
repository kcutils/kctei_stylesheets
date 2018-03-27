#!/bin/sh

cd ..
zip -r kctei_stylesheets/kctei_stylesheets.zip kctei_stylesheets/LICENSE kctei_stylesheets/README* kctei_stylesheets/xslt/* kctei_stylesheets/xsltproc* kctei_stylesheets/data kctei_stylesheets/lib kctei_stylesheets/convert.sh -x \*.git* -x\*saxon9he.jar
cd -
