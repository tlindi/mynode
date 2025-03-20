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

export JAVAHOME=$JAVA_HOME
export JAVA_HOME=/usr/lib/jvm/temurin-21-jdk-arm64/
export PATH_backup=$PATH 
export PATH=/usr/lib/jvm/temurin-21-jdk-arm64/bin:$PATH

java --version

# Make app
./gradlew jvmDistZip

export PATH=$PATH_backup
export JAVA_HOME=$JAVAHOME

# Expose default data directory as VOLUME when docker
#VOLUME [ "/phoenix" ]

# datadir
mkdir -p $MYNODE_DIR/phoenixd || true

echo "================== DONE INSTALLING APP ================="