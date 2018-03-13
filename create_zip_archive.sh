#!/bin/sh

cd ..
zip -r kctei_stylesheets/kctei_stylesheets.zip kctei_stylesheets/LICENSE kctei_stylesheets/README* kctei_stylesheets/xslt* kctei_stylesheets/data kctei_stylesheets/lib -x \*.git* -x\*saxon9he.jar
cd -
