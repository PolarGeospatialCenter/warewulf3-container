#!/bin/sh

source /usr/local/bin/common.sh
make_data_dirs
load_configs

wwsh dhcp update -v

exec consul-template -config /etc/consul-template/conf.d/dhcpd.toml -exec "/usr/sbin/dhcpd -f"
