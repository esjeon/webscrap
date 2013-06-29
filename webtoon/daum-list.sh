#!/bin/sh

if [ $# -eq 0 ]; then
	echo "Usage: $0 title"
	exit 0
fi

title="$1"

curl -# "http://cartoon.media.daum.net/webtoon/rss/${title}" \
	| sed -n '/title/ { s/\s*<\/\?title>//g; s/.*\///; p }' \
	| sed -n '1!G;h;$p' \
	| sed -n "=;p" | sed 'N;s/\n/\t/'


