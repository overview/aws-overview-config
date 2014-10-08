#!/bin/sh

DIR=`dirname $0`

rm -rf "$DIR/generated"
ruby scripts/process_erb.rb
