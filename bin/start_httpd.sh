#!/bin/sh

source /usr/local/bin/common.sh
make_data_dirs

wwinit database

exec consul-template -config /etc/consul-template/conf.d/ -exec "httpd -DFOREGROUND"
