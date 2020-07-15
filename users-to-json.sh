#!/bin/bash
users_left=$#
user_lines=""

format_uuid() {
  u="[a-fA-F0-9]"
  regex="\($u\{8\}\)\($u\{4\}\)\($u\{4\}\)\($u\{4\}\)\($u\{12\}\)"
  echo $1 | sed -e "s/$regex/\1-\2-\3-\4-\5/g"
}

for user in $@ ; do
  let users_left=$users_left-1
  profile=`curl -Ls https://api.mojang.com/users/profiles/minecraft/$user`
  raw_uuid=`echo $profile | jq '.id'`

  if [ "$raw_uuid" != "" ] ; then
    uuid=`format_uuid $raw_uuid`
    user_lines="{\"uuid\": $uuid, \"name\": \"$user\"}\n$user_lines"
  fi
done

echo -e $user_lines | jq -s ''
