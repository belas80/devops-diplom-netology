#!/usr/bin/env bash

grep -P 'backend[\s]+"s3"' **/*.tf |
  rev | cut -d'/' -f2- | rev |
  sort |
  uniq |
  while read d; do \
    echo '[ {"name": "'"$d"'","dir": "'"$d"'", "autoplan": {"when_modified": ["**/*.tf.*"] }} ]' | yq -PM; \
  done