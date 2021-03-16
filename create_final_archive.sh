#!/usr/bin/env sh

SCRIPT=$( readlink -f "$0" )
SCRIPT_PATH=$( dirname "$SCRIPT" )

cd ${SCRIPT_PATH}/..

echo "Creating archive ..."

rm -f kctei_stylesheets/kctei_stylesheets.zip

OUT=$( zip -r kctei_stylesheets/kctei_stylesheets.zip kctei_stylesheets/LICENSE kctei_stylesheets/README* kctei_stylesheets/xslt/* kctei_stylesheets/xsltproc* kctei_stylesheets/data kctei_stylesheets/lib kctei_stylesheets/convert.sh -x \*.git* -x\*saxon*.jar 2>&1 )

if [ $? -ne 0 ]; then
  echo "Error while creating final archive!"
  echo "$OUT"
  echo "Exitting ..."
  exit 1
fi

