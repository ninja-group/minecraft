#!/bin/bash
TEMPDIR="$(mktemp -d)"
FILE="$(realpath $1)"
cd $TEMPDIR
unzip -qq "$FILE"
grep '^name:' plugin.yml | sed 's/^name:\s*\([a-zA-Z0-9_]\+\).*/\1/'
cd /
rm -rf $TEMPDIR
