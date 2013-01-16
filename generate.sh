#!/bin/sh

DIR=`dirname $0`

rm -rf "$DIR/generated"

for TEMPLATE in $(cd "$DIR/templates" && find . -type f -name '*.erb'); do
  INPUT="$DIR/templates/$TEMPLATE"
  OUTPUT="$DIR/generated/${TEMPLATE%.erb}"

  mkdir -p $(dirname $OUTPUT)
  ruby $DIR/scripts/process_erb.rb $INPUT $OUTPUT
done
