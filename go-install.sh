#!/bin/bash

GO_LATEST='go1.20.2'
AMD64_CHECK='4eaea32f59cde4dc635fbc42161031d13e1c780b87097f4b4234cfce671f1768'
ARM_CHECK='78d632915bb75e9a6356a47a42625fd1a785c83a64a643fedd8f61e31b1b3bef'
ARCH=`uname -m`
cd /tmp

if [ "$ARCH" == "aarch64" ]; then
GO_DOWNLOAD="$GO_LATEST.linux-arm64.tar.gz"
SHA256=$ARM_CHECK
elif [ "$ARCH" == "x86_64" ]; then
GO_DOWNLOAD="$GO_LATEST.linux-amd64.tar.gz"
SHA256=$AMD64_CHECK
else
echo "$ARCH is not supported at this time"
exit -1;
fi;

#Check if it has already been downloaded
FILE=/tmp/$GO_DOWNLOAD
if test -f "$FILE"; then
    echo "$FILE exists."
else
echo "Downloading latest"
wget https://go.dev/dl/$GO_DOWNLOAD
fi;

SUM_CHECKED=`sha256sum $FILE`

if [ "$(echo $SUM_CHECKED | grep -c "^$SHA256")" -ge 1 ]; then
echo "Checksum matches $SHA256"
else
echo "$SUM_CHECKED does not match $SHA256"
exit -1;
fi;

GO_BIN_DIR='export PATH=$PATH:/usr/local/go/bin'

rm -rf /usr/local/go && tar -C /usr/local -xzf $GO_DOWNLOAD

if [ "$(grep -c "^$GO_BIN_DIR" /etc/profile)" -ge 1 ]; then
echo "Go directory already set in /etc/profile\n"
else
echo $GO_BIN_DIR >> /etc/profile
fi;

source /etc/profile

# Install dlv debugger
sudo -i --login go install github.com/go-delve/delve/cmd/dlv@latest

