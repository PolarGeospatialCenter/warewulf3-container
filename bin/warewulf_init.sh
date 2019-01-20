#!/bin/sh

source /usr/local/bin/common.sh
make_data_dirs
load_configs

rsync -av /buildtime-statedir/ /data/
wwinit database

if [ -n "${GIT_CONFIG_PATH}" ]; then
  GIT_REPO_URL=$(cat ${GIT_CONFIG_PATH}/repository_url)
  GIT_SSH_KEY=${GIT_CONFIG_PATH}/deploy_key
  GIT_REF=${GIT_REF:-refs/heads/master}

  mkdir -p /root/.ssh
  chmod 0600 /root/.ssh
  cp ${GIT_CONFIG_PATH}/known_hosts /root/.ssh/known_hosts

  ssh-agent bash -c "ssh-add ${GIT_CONFIG_PATH}/deploy_key && git clone $(cat ${GIT_CONFIG_PATH}/repository_url) /tmp/warewulf-repo"
  cd /tmp/warewulf-repo
  git checkout $GIT_REF
fi

warewulf-sync

if [ ! -z ${WWMASTER_IPS+x} ]; then
  wwsh node list -1 | xargs wwsh provision set --master "${WWMASTER_IPS}"
fi
