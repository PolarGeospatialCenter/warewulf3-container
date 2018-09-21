#!/bin/sh

: ${GIT_CONFIG_PATH?}
GIT_REPO_URL=$(cat ${GIT_CONFIG_PATH}/repository_url)
GIT_SSH_KEY=${GIT_CONFIG_PATH}/deploy_key
GIT_REF=${GIT_REF:-refs/heads/master}

source /usr/local/bin/common.sh
make_data_dirs
load_configs

wwinit database

mkdir -p /root/.ssh
chmod 0600 /root/.ssh
cp ${GIT_CONFIG_PATH}/known_hosts /root/.ssh/known_hosts

ssh-agent bash -c "ssh-add ${GIT_CONFIG_PATH}/deploy_key && git clone $(cat ${GIT_CONFIG_PATH}/repository_url) /tmp/warewulf-repo"
cd /tmp/warewulf-repo
git checkout $GIT_REF

warewulf-sync

wwsh dhcp update -v
wwsh pxe update -v
