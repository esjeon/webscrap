#!/bin/bash

thread=1400730326

(
echo -en '<thread thread="'"${thread}"'" res_from="-50" version="20061206" scores="1"/>\0';
sleep 0.3;
echo -ne '<ping>EOT</ping>\0';
) | netcat 202.248.110.186 2813 
