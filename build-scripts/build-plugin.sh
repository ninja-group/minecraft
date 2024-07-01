#!/bin/bash
set -e
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

/bin/bash -c "$build" || exit 1
path=`/bin/bash -c "ls $jarpath"`
name=`/build/plugin-name.sh $path`
mv $path ../$name.jar

cd ..
rm -rf "$name"
