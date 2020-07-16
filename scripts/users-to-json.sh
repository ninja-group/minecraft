#!/bin/bash
users_left=$#
user_lines=""

format_uuid() {
  echo ${1:0:8}-${1:8:4}-${1:12:4}-${1:16:4}-${1:20}
}

for user in $@ ; do
  let users_left=$users_left-1
  profile=`curl -Ls https://api.mojang.com/users/profiles/minecraft/$user`
  raw_uuid=`echo $profile | jq -j '.id'`

  if [ "$raw_uuid" != "" ] ; then
    uuid=`format_uuid $raw_uuid`
    user_lines="{\"uuid\": \"$uuid\", \"name\": \"$user\"}\n$user_lines"
  fi
done

echo -e $user_lines | jq -s ''
