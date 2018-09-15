#!/bin/sh

source /usr/local/bin/common.sh
make_data_dirs

exec /usr/sbin/in.tftpd -L -R 4097:32767 -s -vvv /data/tftp
