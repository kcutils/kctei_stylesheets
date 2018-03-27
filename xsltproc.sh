#!/usr/bin/env sh

JAVA=$( which java )

if [ $? -ne 0 ]; then
  echo "Java not found in PATH! Exiting ..."
  exit 1
fi

SCRIPT=$( readlink -f "$0" )
SCRIPT_PATH=$( dirname "$SCRIPT" )

SAXON_JAR="${SCRIPT_PATH}/lib/saxon9he.jar"

if [ ! -f "$SAXON_JAR" ]; then
  echo "Saxon JAR file not found! Exiting ..."
  exit 1
fi

$JAVA -jar $SAXON_JAR $@

