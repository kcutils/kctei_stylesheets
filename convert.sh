#!/usr/bin/env sh

SCRIPT=$( readlink -f "$0" )
SCRIPT_PATH=$( dirname "$SCRIPT" )

XSLTPROC="${SCRIPT_PATH}/xsltproc.sh"
STYLESHEET_ROOT_PATH="${SCRIPT_PATH}/xslt/"

PRAAT_CMD="$( which praat )"

TEXTGRID_VALIDATE_SCRIPT="${SCRIPT_PATH}/lib/testTextgridOpen.praat"

STYLESHEETS="TextGrid:KCTEI2TextGrid.xsl eaf:KCTEI2eaf.xsl exb:KCTEI2exb.xsl"

OUT_FORMATS=

ERRORS=0


usage () {
cat << END

  $0 [-h|--help] [-t|--praat] [-e|--elan] [-E|--exmaralda] [-o OUT_DIR|--output OUT_DIR] INPUT_FILE

  Script converts INPUT_FILE in KCTEI-format into several output formats using
  a script that does XML transformations.
  (script: ${XSLTPROC})

    [-h|--help]      show this output

    [-t|--praat]     convert into TextGrid (praat) format

    [-e|--elan]      convert into eaf (ELAN) format

    [-E|--exmaralda] convert into exb (EXMARaLDA) format

    [-o OUT_DIR|--output OUT_DIR]    place output files in OUT_DIR

    [-v|--verbose]             some verbose information


  If no output format is given, all defined output formats are used.
  $( echo "$STYLESHEETS" | tr ' ' '\n' | cut -d : -f 2 | tr '\n' ' ' )

  If no output root directory is given, output files will be placed
  in the same directory as the input file resides in.

END
}

IN_FILE=
OUT_ROOT_DIR=

VERBOSE=0

while [ $# -gt 0 ]; do
  case $1 in
    -t|--praat)
      OUT_FORMATS="$OUT_FORMATS TextGrid"
    ;;
    -e|--elan)
      OUT_FORMATS="$OUT_FORMATS eaf"
    ;;
    -E|--exmaralda)
      OUT_FORMATS="$OUT_FORMATS exb"
    ;;
    -o|--output)
      OUT_ROOT_DIR=$2
      shift
    ;;
    -v|--verbose)
      VERBOSE=1
    ;;
    -h|--help)
      usage
      exit
    ;;
    *)
      IN_FILE=$1
    ;;
  esac
  shift
done

if [ "$IN_FILE" = "" ]; then
  echo "ERROR: Input file not specified!"
  echo "Exitting ..."
  exit 1
fi

if [ ! -f "$IN_FILE" ]; then
  echo "ERROR: Input file $IN_FILE not found!"
  echo "Exitting ..."
  exit 1
fi

if [ ! -e "$XSLTPROC" ]; then
  echo "ERROR: xsltproc script $XSLTPROC not found!"
  echo "Exitting ..."
  exit 1
fi

if [ "$OUT_ROOT_DIR" = "" ]; then
  OUT_ROOT_DIR=$( dirname "$IN_FILE" )
fi

if [ "$OUT_FORMATS" = "" ]; then
  OUT_FORMATS="TextGrid eaf exb"
fi

if [ $VERBOSE -eq 1 ]; then
  echo
  echo "Root path of stylesheets: $STYLESHEET_ROOT_PATH"
  echo "xsltproc script: $XSLTPROC"
  echo
  echo "Input file: $IN_FILE"
  echo "Output dir: $OUT_ROOT_DIR"
  echo "Output formats: $OUT_FORMATS"
  echo
fi

BASE_FILENAME=$( basename "$IN_FILE" | rev | cut -d . -f 2- | rev )

for OUT_FORMAT in $OUT_FORMATS; do
  for STYLE in $STYLESHEETS; do
    EXT=$( echo "$STYLE" | cut -d : -f 1 )
    STYLESHEET_NAME=$( echo "$STYLE" | cut -d : -f 2 )
    if [ "$EXT" != "$OUT_FORMAT" ]; then
      continue
    fi
    OUT_FILE="${OUT_ROOT_DIR}/${BASE_FILENAME}.${EXT}"
    STYLESHEET="${STYLESHEET_ROOT_PATH}/${STYLESHEET_NAME}"

    if echo "$OSTYPE" | grep "cygwin" 2>&1 > /dev/null; then
      OUT=$( cygpath -w $STYLESHEET )
      if [ $? -eq 0 ]; then
        STYLESHEET=$OUT
      fi
    fi

    if [ ! -f "$STYLESHEET" ]; then
      echo "ERROR: Unable to find stylesheet ${STYLESHEET}!"
      ERRORS=$(( $ERRORS + 1 ))
      continue
    fi
    if [ $VERBOSE -eq 1 ]; then
      echo "Using stylesheet $STYLESHEET ..."
    fi
    echo "Converting $IN_FILE to $OUT_FILE ..."
    OUT=$( $XSLTPROC $IN_FILE $STYLESHEET 2>&1 )
    if [ $? -ne 0 ]; then
      echo "ERROR while converting!"
      ERRORS=$(( $ERRORS + 1 ))
      echo "$OUT"
    else
      echo "$OUT" > "$OUT_FILE"

      if [ "$EXT" = "TextGrid" ] && [ "$PRAAT_CMD" != "" ]; then
        if [ $VERBOSE -eq 1 ]; then
          echo "Checking if generated TextGrid is valid ..."
        fi

        OUT=$( "$PRAAT_CMD" --run "$TEXTGRID_VALIDATE_SCRIPT" "$( realpath $OUT_FILE )" 2>&1 )
        if [ $? -ne 0 ]; then
          echo "ERROR while opening generated TextGrid $OUT_FILE !"
          ERRORS=$(( $ERRORS + 1 ))
          echo "$OUT"
#          rm "$OUT_FILE"
        fi
      fi

    fi
  done
done

if [ $ERRORS -gt 0 ]; then
  echo "$ERRORS ERROR(s) occurred!"
  echo "Exitting ..."
  exit 1
fi
