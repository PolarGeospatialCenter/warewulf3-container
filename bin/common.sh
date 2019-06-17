#!/bin/sh

function make_data_dirs() {
  mkdir -p /data/{db,binstore,config,tftp,warewulf}
}

function load_configs() {
  consul-template -config /etc/consul-template/conf.d/ -once
}
