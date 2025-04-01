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

### Sample how to handle ARC differentl, if needed#
# Build docker container
#if [ "$DEVICE_ARCH" = "x86_64" ]; then
#    docker build -t lndboss .
#elif [ "$DEVICE_ARCH" = "aarch64" ]; then
#    docker build . -t lndboss -f arm64.Dockerfile
#else
#    echo "THIS ARCHITECTURE IS NOT SUPPORTED FOR LndBoss"
#    exit 1
#fi

#We use java for all archs which needs OpenJDK21
# https://adoptium.net/temurin/releases/?package=jdk&version=21
#

# JAVA INSTALL
#in setup_device.sh

git clone https://github.com/acinq/phoenixd.git .
git checkout ${VERSION}

export JAVAHOME=$JAVA_HOME
export JAVA_HOME=/usr/lib/jvm/temurin-21-jdk-arm64/
export PATH_backup=$PATH 
export PATH=/usr/lib/jvm/temurin-21-jdk-arm64/bin:$PATH

java --version

# jvmDistZip compile 0.5.1 crashes due source is missing .git folder - no use
# 0.5.0 has gradle 8.9 bug on compile - update gradle to 8.10
#
# @gradle/wrapper/gradle-wrapper.properties
# gradle-8.9-bin -> gradle-8.10-bin
# distributionSha256Sum=d725d707bfabd4dfdc958c624003b3c80accc03f7037b5122c4b1d0ef15cecab
# -> distributionSha256Sum=5b9c5eb3f9fc2c94abaea57d90bd78747ca117ddbbf96c859d3741181a12bf2a
#sed -i 's/gradle-8.9-bin/gradle-8.10-bin/g' gradle/wrapper/gradle-wrapper.properties
#sed -i 's/d725d707bfabd4dfdc958c624003b3c80accc03f7037b5122c4b1d0ef15cecab/5b9c5eb3f9fc2c94abaea57d90bd78747ca117ddbbf96c859d3741181a12bf2a/g' gradle/wrapper/gradle-wrapper.properties

# Make app
/usr/bin/update-alternatives --set java /usr/lib/jvm/temurin-21-jdk-arm64/bin/java
./gradlew jvmDistZip --info
#/usr/bin/update-alternatives --remove java temurin-21-jdk-arm64

killall java

export PATH=$PATH_backup
export JAVA_HOME=$JAVAHOME

unzip -o build/distributions/phoenixd-0.5.1-jvm.zip -d .
mv phoenixd-0.5.1-jvm/bin .
mv phoenixd-0.5.1-jvm/lib .
rm -rf phoenixd-0.5.1-jvm

# Expose default data directory as VOLUME when docker
#VOLUME [ "/phoenix" ]

# datadir
mkdir -p /mnt/hdd/mynode/phoenixd || true
ln -s /mnt/hdd/mynode/phoenixd ~/.phoenixd 


bash -c 'echo y | (./bin/phoenixd & )'


echo "================== DONE INSTALLING APP ================="