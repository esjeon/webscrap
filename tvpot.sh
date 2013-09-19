#!/bin/bash

#vf4f0bXZXbtctppggDxpbxc
vid="${1}"

metaurl="http://videofarm.daum.net/controller/api/open/v1_2/MovieLocation.apixml?vid=${vid}&profile=MAIN&play_loc=tvpot"

vidurl="$(wget "${metaurl}" -O- | grep -o 'http:[a-zA-Z0-9.\/]*')"

wget "${vidurl}" -O "${vid}.mp4"


