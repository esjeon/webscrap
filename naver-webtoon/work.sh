#!/bin/sh

if [ $# -eq 0 ]; then
	echo "Usage: $0 title-id episode..." >&2
	exit 0
fi

titleId="$1"
shift 1

while [ $# -gt 0 ]; do
	seq="$1"
	idx=1

	curl -# "http://comic.naver.com/webtoon/detail.nhn?titleId=${titleId}&seq=${seq}" \
		| egrep -o 'http:\/\/imgcomic[^"]+' \
		| while read url; do
			ext="$( echo "${url}" | egrep -o '[^.]+$' )"
			filename="$(printf '%03d-%02d.%s' "${seq}" "${idx}" "${ext}")"
			curl "${url}" > "${filename}"
			idx=$((idx+1))
		done

	shift 1
done
