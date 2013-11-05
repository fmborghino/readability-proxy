#!/bin/bash
# experiments with readability.com API

# config
token=$READABILITY_PARSER_TOKEN

# nothing to touch below
me=$(basename $0)
usage="usage: READABILITY_PARSER_TOKEN=token $me url"
[ -z "$token" ] && echo -e "missing token\n$usage" && exit 1

tmp_html=$(mktemp -t $me)

# dependencies
for dep in jq curl
do
  [ -z "$(which $dep)" ] && echo  "$me: '$dep' missing. Try 'brew install $dep'" && exit 1
done

# main
url=$1
[ -z "$url" ] && echo $usage && exit 0

resp=$(curl -s "https://readability.com/api/content/v1/parser?url=${url}&token=${token}")

error=$(echo $resp|jq -r .error)
[ "$error" != "null" ] && echo "$me: $(echo $resp|jq -r .messages)" && exit 1

echo $resp | jq -r '.title,.date_published'
echo $resp | jq -r .content >$tmp_html
mv $tmp_html ${tmp_html}.html

open ${tmp_html}.html
