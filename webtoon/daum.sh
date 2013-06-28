#!/bin/sh

title="$1"
shift 1

selector=""
while [ $# -gt 0 ]; do
	selector="${selector}; ${1}{=;p}"
	shift 1
done

curl -# "http://cartoon.media.daum.net/webtoon/rss/${title}" \
	| sed -n '/guid/ { s/\s*<\/\?guid>//g; s/.*\///; p }' \
	| sed -n '1!G;h;$p' \
	| sed -n "${selector}" | sed 'N;s/\n/\t/' \
	| while read episode episode_id; do
		idx=1

		echo
		echo "Episode ${episode} ${episode_id}"
		curl -# "http://cartoon.media.daum.net/webtoon/viewer_images.js?webtoon_episode_id=${episode_id}" \
			-A 'Mozilla/5.0 (X11; Linux x86_64; rv:21.0) Gecko/20100101 Firefox/21.0' \
			-b "WEBTOON_VIEW=MTAuMTA%3D" \
			| sed -n '/url/ p' \
			| egrep -o 'http:\/\/[^"]+' \
			| while read url; do
				filename="$(printf '%03d-%02d.jpg' "${episode}" "${idx}")"
				echo "${filename} <-- ${url}"
				curl -# "${url}" > "${filename}"
				idx=$((idx + 1))
			done
	done


