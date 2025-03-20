#!/bin/bash

source /usr/share/mynode/mynode_device_info.sh
source /usr/share/mynode/mynode_app_versions.sh

set -x
set -e

echo "==================== INSTALLING APP ===================="

# The current directory is the app install folder and the app tarball from GitHub
# has already been downloaded and extracted. Any additional env variables specified
# in the JSON file are also present.

# TODO: Perform installation steps here

# use ACINQ docker after 0.5.1+
git clone http://www.github.com/acinq/phoenixd.git
cd phoenixd
git checkout $VERSION
#
# get 0.5.1+ acinq patched commit (will do "manually" at * below)
#git checkout 75ae285dd41833f58f409990635e84f2607c1a6e
#
git pull

# (*) patch docker 0.5.1+ which ACINQ forgot from release 
#
sed -i 's/v0.5.0/v0.5.1/g' .docker/Dockerfile
sed -i 's/dc7f12417c70cc9af1e1f7d7f077910f8b198a98/ab9a026432a61d986d83c72df5619014414557be/g' .docker/Dockerfile
sed -i 's/distTar/jvmDistTar/g' .docker/Dockerfile
sed -i 's/distributions\/phoenix-/distributions\/phoenixd-/g' .docker/Dockerfile
sed -i 's/xvf phoenix-/xvf phoenixd-/g' .docker/Dockerfile

# patch docker internal user to match MyNode bitcoin user
# so access rights on /mnt/hdd/mynode/phoenixd look similar to other apps ie "bitcoin:bitcoin"
sed -i 's/gid 1000/gid 1001/g' .docker/Dockerfile
sed -i 's/uid 1000/uid 1001/g' .docker/Dockerfile

# sudo docker ps -a
# sudo docker remove <CONTAINER_ID>
# docker image list
# docker rmi phoenixd:latest
#sudo -u bitcoin docker build -t phoenixd:latest .docker
# 
docker build -t phoenixd:latest -f .docker/Dockerfile .

mkdir -p /mnt/hdd/mynode/phoenixd || true
# docker internal user is phoenix id=1001
chown 1001:1001 /mnt/hdd/mynode/phoenixd

echo "================== DONE INSTALLING APP ================="