#!/bin/bash

set -e
#set -x

AGENT=${AGENT:-"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.57 Safari/537.36"}
MY="/tmp/nico-$$-"

log() {
	printf "$@\n" >&2
}

webgetV() {
	wget \
		--no-check-certificate \
		--load-cookies "${MY}cookies.txt" \
		--save-cookies "${MY}cookies.txt" \
		--keep-session-cookies \
		-U "${user_agent}" \
		"$@"
}

webget() {
	webgetV -q "$@"
}

urldecode() {
	php -r 'print(urldecode(file_get_contents("php://stdin")));'
}

firefox_getcookies() {
	log " [FF] Cookies"

	local db query filter
	db="$(ls ~/.mozilla/firefox/**/cookies.sqlite | head -n 1)"

	if [[ ! -f "${db}" ]]; then
		return 1
	fi

	query=""
	query="${query} SELECT host, path, expiry, name, value"
	query="${query} FROM moz_cookies"
	query="${query} WHERE host like '%.nicovideo.jp' ;"

	filter=""
	filter="${filter}"'BEGIN { FS="|" ; OFS="\t" };'
	filter="${filter}"'{ print $1, "TRUE", $2, "FALSE", $3, $4, $5 }'

	sqlite3 "${db}" "${query}" | awk "${filter}"
}

nico_watch() {
	log " [NICO] watch ${1}"
	webget -O - "http://www.nicovideo.jp/watch/${1}"
}

nico_getflv() {
	log " [NICO] getflv ${1}"
	webget -O - "http://flapi.nicovideo.jp/api/getflv/${1}" \
		| urldecode \
		| sed 's/&/\n/g' \
		| sed -n "/^url=/ { s/^url=//; p }" 
}

nico_getthumbinfo() {
	log " [NICO] getthumbinfo ${1}"
	webget -O - "http://ext.nicovideo.jp/api/getthumbinfo/${1}"
}

nicosh_getvideo() {
	log " [NCSH] video ${1}"

	local vid filename qual
	vid="$1"

	if [[ ! "${vid}" =~ sm[0-9]* ]]; then
		echo "Invalid video id '${vid}'"
		return 1
	fi

	nico_getflv "${vid}" > "${MY}${vid}.url"

	url="$(cat "${MY}${vid}.url")"
	if [[ -z "${url}" ]]; then
		echo "Failed to retrieve video url"
		return 2
	fi
	printf "\t --> %s\n" "${url}"

	if [[ "${url}" =~ 'low' ]]; then
		printf "\t --> %s\n" "economy mode"
		qual='.low'
	fi

	#TODO: file extension
	filename="${vid}${qual}.mp4"

	# NOTE: must visit the video page before downloading the video itself
	# TODO: video meta data
	nico_watch "${vid}" > /dev/null

	webgetV -O "${filename}" "${url}"
}


cleanup() {
	log " Cleaning..."
	rm -rf "${MY}"*
}
declare -fx cleanup
trap 'cleanup' EXIT

firefox_getcookies > "${MY}cookies.txt"

nicosh_getvideo "$@"
