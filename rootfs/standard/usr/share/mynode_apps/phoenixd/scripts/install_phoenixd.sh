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

#We use java for all archs which needs OpenJDK21
# https://adoptium.net/temurin/releases/?package=jdk&version=21
# JAVA INSTALL
#in setup_device.sh

git clone https://github.com/acinq/phoenixd.git .
git checkout ${VERSION}

export JAVAHOME=$JAVA_HOME
export JAVA_HOME=/usr/lib/jvm/temurin-21-jdk-arm64/
export PATH_backup=$PATH 
export PATH=/usr/lib/jvm/temurin-21-jdk-arm64/bin:$PATH
java --version

/usr/bin/update-alternatives --set java /usr/lib/jvm/temurin-21-jdk-arm64/bin/java
./gradlew jvmDistZip

/usr/bin/update-alternatives --remove java /usr/lib/jvm/temurin-21-jdk-arm64/bin/java

export PATH=$PATH_backup
export JAVA_HOME=$JAVAHOME

unzip -o build/distributions/phoenixd-0.5.1-jvm.zip -d .
mv phoenixd-0.5.1-jvm/bin .
mv phoenixd-0.5.1-jvm/lib .
rm -rf phoenixd-0.5.1-jvm

# Let's make wrapper files to run phoenix with correct java 21
echo JAVACMD=/usr/lib/jvm/java-21-openjdk-amd64/bin/java /opt/mynode/phoenixd/bin/phoenix-cli \$\@ > /usr/local/bin/phoenix-cli
chmod +x /usr/local/bin/phoenix-cli
echo JAVACMD=/usr/lib/jvm/java-21-openjdk-amd64/bin/java /opt/mynode/phoenixd/bin/phoenixd \$\@ > /usr/local/bin/phoenixd
chmod +x /usr/local/bin/phoenixd

# install phoemix-cli bash style completition 
cp /usr/share/mynode_apps/phoenixd/app_data/phoenix-cli /etc/bash_completion.d/
source /etc/bash_completion.d/phoenix-cli

mkdir -p /mnt/hdd/mynode/phoenixd || true

ln -s /mnt/hdd/mynode/phoenixd ~/.phoenix 

# Lets initial run to accept terms and create wallet
#Implement recovery if backup exist, after backup is implemented
#
bash -c 'echo y | (./phoenixd & )'

echo "================== DONE INSTALLING APP ================="