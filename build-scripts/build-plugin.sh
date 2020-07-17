#!/bin/bash
name="$(echo $1 | jq -j '.name')"
repo="$(echo $1 | jq -j '.repo')"
tag="$(echo $1 | jq -j '.tag')"
build="$(echo $1 | jq -j '.build')"
jarpath="$(echo $1 | jq -j '.jarpath')"

git clone "$repo" "$name" || exit 1
cd "$name"

if [ "" != "$tag" ] ; then
  git checkout "$tag"
fi

$build || exit 1
mv "$jarpath" "../$name.jar"

cd ..
rm -rf "$name"
