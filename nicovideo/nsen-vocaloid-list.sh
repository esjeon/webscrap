#!/bin/sh

url='http://live.nicovideo.jp/nsendata?v=lv150413966'

( echo "console.log(require('util').inspect("; curl "${url}"; echo ", { colors: true }))" ) | node
