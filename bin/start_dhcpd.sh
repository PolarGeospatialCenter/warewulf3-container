#!/bin/sh

source /usr/local/bin/common.sh
make_data_dirs

consul-template -once -config /etc/consul-template/conf.d/provision.toml
wwsh dhcp update

exec consul-template -config /etc/consul-template/conf.d/ -exec "/usr/sbin/dhcpd -f"
