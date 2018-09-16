#!/bin/sh

source /usr/local/bin/common.sh
make_data_dirs
load_configs

wwinit database

exec httpd -DFOREGROUND
