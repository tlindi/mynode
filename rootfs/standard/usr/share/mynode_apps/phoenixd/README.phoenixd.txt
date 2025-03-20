#OpenSDK21
#You can use the Adoptium Debian / Ubuntu repository

#Add the Eclipse Adoptium GPG key
wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo tee /etc/apt/trusted.gpg.d/myrepo.asc

#Add the Eclipse Adoptium apt repository
echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | sudo tee /etc/apt/sources.list.d/adoptium.list

#Install the Temurin version you require
sudo apt update # update if you haven't already
sudo apt install temurin-21-jdk
sudo apt autoremove

#Configure the default version
sudo update-alternatives --config java

/usr/lib/jvm/temurin-21-jdk-arm64/bin/java --version

---

# Expose default data directory as VOLUME
#VOLUME [ "/phoenix" ]
mkdir -p $MYNODE_DIR/phoenixd || true

wget https://github.com/ACINQ/phoenixd/archive/refs/tags/v0.5.0.tar.gz

# docker after 0.5.1
docker build -t phoenixd -f .docker/Dockerfile .

mkdir /mnt/hdd/mynode/phoenix/
chown bitcoin:bitcoin /mnt/hdd/mynode/phoenix/
#sudo /snap/bin/docker run --rm --name phoenixd --publish 9740:9740 --volume /mnt/hdd/mynode/phoenixd/.phoenix:/.phoenix --env 
PHOENIX_DATADIR='/.phoenix' --env WORK_DIR='/phoenix' phoenixd &

# docker after 0.5.1
docker run --rm --name phoenixd --publish 9740:9740 --volume /mnt/hdd/mynode/phoenixd/.phoenix:/.phoenix --env PHOENIX_DATADIR='/.phoenix' --env WORK_DIR='/phoenix' phoenixd &

./phoenixd --http-bind-ip 0.0.0.0