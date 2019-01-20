#!/bin/sh

source /usr/local/bin/common.sh
make_data_dirs
load_configs

wwsh pxe update -v --nodhcp

if [ ! -z ${WWMASTER_IPS+x} ]; then
  wwsh node list -1 | xargs wwsh provision set --master "${WWMASTER_IPS}"
fi

exec httpd -DFOREGROUND
