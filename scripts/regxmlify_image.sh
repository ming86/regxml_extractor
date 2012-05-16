#!/bin/bash

if [ $# -lt 1 ]; then
  echo "Usage: $0 <disk image>" >&2
  exit 1
fi

# Invoke extraction script
extract_hives.py --hivexml "$1" >manifest.txt
# For each regxml file generated, run xmllint to pretty-print
rm -f linted.txt
for x in $(ls *hive); do xmllint --format "$x" >"${x}.pretty.regxml" && echo $x >>linted.txt ; done
# When all regxml is pretty-printed, generate a database
make_database.py linted.txt manifest.txt out.sqlite
