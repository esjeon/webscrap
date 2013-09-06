#!/bin/bash

set -e
#set -x

AGENT=${AGENT:-"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.57 Safari/537.36"}
MY="/tmp/pixsh-$$-"

log() {
	printf "$@\n" >&2
}

info() {
	fmt="$1"
	shift 1
	printf "\t --> ${fmt}\n" "$@" >&2
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
urlencode() {
	php -r 'print(urlencode(file_get_contents("php://stdin")));'
}

firefox_getcookies() {
	log " [FF  ] Cookies"

	local db query filter
	db="$(ls ~/.mozilla/firefox/**/cookies.sqlite | head -n 1)"

	if [[ ! -f "${db}" ]]; then
		return 1
	fi

	query=""
	query="${query} SELECT host, path, expiry, name, value"
	query="${query} FROM moz_cookies"
	query="${query} WHERE host like '%.pixiv.net' ;"

	filter=""
	filter="${filter}"'BEGIN { FS="|" ; OFS="\t" };'
	filter="${filter}"'{ print $1, "TRUE", $2, "FALSE", $3, $4, $5 }'

	sqlite3 "${db}" "${query}" | awk "${filter}"
}

pixsh_getimgurl() {
	illust_id="$1"

	webget \
		-O - \
		--referer="http://www.pixiv.net/member_illust.php?mode=medium&illust_id=${illust_id}" \
		"http://www.pixiv.net/member_illust.php?mode=big&illust_id=${illust_id}" \
	| egrep -o 'img src="[^"]+"' \
	| egrep -o 'http:\/\/[^"]*'
}

pixsh_getimg() {
	illust_id="$1"

	pixsh_getimgurl "${illust_id}" | \
	(
		read img_url;
		webgetV \
			--referer="http://www.pixiv.net/member_illust.php?mode=big&illust_id=${illust_id}" \
			"${img_url}"
	)
}




cleanup() {
	log " [    ] Cleaning up... "
	rm -rf "${MY}"*
}
declare -fx cleanup
trap 'cleanup' EXIT

firefox_getcookies > "${MY}cookies.txt"

pixsh_getimg "$1"
