#!/usr/bin/env sh

JAVA=$( which java )

if [ $? -ne 0 ]; then
  echo "Java not found in PATH! Exiting ..."
  exit 1
fi

SCRIPT=$( readlink -f "$0" )
SCRIPT_PATH=$( dirname "$SCRIPT" )

SAXON_JAR="${SCRIPT_PATH}/lib/saxonhe.jar"

if echo "$OSTYPE" | grep "cygwin" 2>&1 > /dev/null; then
  OUT=$( cygpath -w $SAXON_JAR )
  if [ $? -eq 0 ]; then
    SAXON_JAR=$OUT
  fi
fi

if [ ! -f "$SAXON_JAR" ]; then
  echo "Saxon JAR file not found! Exiting ..."
  exit 1
fi

"$JAVA" -Dfile.encoding=UTF-8 -jar "$SAXON_JAR" $@

