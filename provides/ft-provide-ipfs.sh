# 

echo "--- ${0##*/}"
IPFS_NODE_NAME=NODE

ver=v0.7.0
arch=linux-amd64
if [ ! -e downloads/go-ipfs_${ver}_${arch}.tar.gz ]; then
  curl -L -o downloads/go-ipfs_${ver}_${arch}.tar.gz https://dist.ipfs.io/go-ipfs/${ver}/go-ipfs_${ver}_${arch}.tar.gz
fi
tar xfv downloads/go-ipfs_v0.7.0_linux-amd64.tar.gz
go-ipfs/ipfs init

screen -mS $IPFS_NODE_NAME  go-ipfs/ipfs daemon &

sh $(which ft-provide-vaniport.sh)
perl -S vaniport.pl 8080

true;

ipfs get -o $HOME/.ipfsignore QmUAf7KZ7NMYwajPrBG6g2VLxBmAjrnXXETMwjVbUsBmP5
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["http://127.0.0.1:8080":"http://localhost:8080","http://127.0.0.1:3000","http://localhost"]'


