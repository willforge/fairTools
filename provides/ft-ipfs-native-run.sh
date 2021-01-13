#A

CALLINGDIR=$(dirname $0); export PATH=$PATH:$CALLINGDIR;
. $CALLINGDIR/ft-provide-envrc.sh

if [ "?$IPFS_PATH" != '?' ]; then
echo IPFS_PATH: $IPFS_PATH
fi
IPFS_PATH=${IPFS_PATH:-$HOME/.ipfs}

if [ ! -e $IPFS_PATH/config ]; then
ipfs init
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin \
 '["http://127.0.0.1:8080","http://localhost:8080","http://127.0.0.1:3000","http://localhost"]'
ipfs config --json Addresses.Gateway '"/ip4/0.0.0.0/tcp/8080"'
fi

if [ ! -e $IPFS_PATH/name ]; then

ipfs daemon &
sh $CALLINGDIR/ft-provide-vaniport.sh
sh $CALLINGDIR/ft-provide-module.sh JSON::XS
sh $CALLINGDIR/ft-provide-module.sh YAML::XS

out=$(perl -S vaniport.pl 8080 NODE- 10_000 | json_xs -f yaml -t string -e '$_ = "$_->{name}: $_->{urn}"')
echo $out
name=$(echo $out | cut -d':' -f1) 
qm=$(echo $out | cut -d' ' -f2 | ipfs add -q --pin=true --progress=false)
echo "$name" > $IPFS_PATH/name
echo qm: $qm

fi

if [ -e $IPFS_PATH/name ]; then
  IPFS_NODE_NAME=$(cat $IPFS_PATH/name)
  echo IPFS_NODE_NAME: $IPFS_NODE_NAME
else
  IPFS_NODE_NAME=$(echo $USER| tr [:lower:] [:upper:])
fi
sh $CALLINGDIR/ft-provide-screen.sh
ipfs shutdown 2>/dev/null
screen -dmS $IPFS_NODE_NAME  ipfs daemon
sleep 7

ping=$(curl -sL http://127.0.0.1:8080/ipfs/QmejvEPop4D7YUadeGqYWmZxHhLc4JBUCzJJHWMzdcMe2y)
test "?$ping" = '?ipfs'
. $CALLINGDIR/ft-provide-status.sh

true;


