#!/bin/sh

source /usr/local/bin/common.sh
make_data_dirs

wwinit database

exec httpd -DFOREGROUND
