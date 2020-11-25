#

export IPFS_IMAGE=${IPFS_IMAGE:-ipfs/go-ipfs}
export IPFS_CONTAINER=${IPFS_CONTAINER:-ipfs-node}
# dockerized ipfs is _ipfs
_ipfs() {
 docker exec $IPFS_CONTAINER ipfs $@
}



uid=$(id -u)
gid=$(id -g)

# 1. start docker if necessary ...
if ! docker ps -f name=$IPFS_CONTAINER | grep -q -w $IPFS_CONTAINER; then
if ! docker ps -a -f name=$IPFS_CONTAINER | grep -q -w $IPFS_CONTAINER; then
echo "docker: run $IPFS_IMAGE in $IPFS_CONTAINER"
docker run -d --name $IPFS_CONTAINER --user $uid:$gid $IPFS_IMAGE
else
echo "docker: start $IPFS_CONTAINER"
docker start $IPFS_CONTAINER
fi
sleep 7
docker logs $IPFS_CONTAINER | waitfor 'ready$'
fi
docker ps -a -f name=$IPFS_CONTAINER


# get config data
peerid=$(_ipfs config Identity.PeerID) && echo peerid: $peerid
gateway=$(_ipfs config Addresses.Gateway)
api=$(_ipfs config Addresses.API)
echo "gateway: $gateway"
echo "api: $api"
gw_port=$(echo $gateway | cut -d/ -f 5)
api_port=$(echo $api | cut -d/ -f 5)
swarm_port=$(_ipfs config Addresses.Swarm | grep -e /tcp | head -1 | cut -d/ -f5 | sed -e 's/".*//')

if ! grep -q Access-Control-Allow-Origin $IPFS_PATH/config ; then
_ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["http://127.0.0.1:8080", "http://localhost:80", "http://127.0.0.1:5001", "https://webui.ipfs.io"]'
_ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '["PUT", "POST"]'
fi


origin=$(_ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin | json_xs -e '$_ = $_->[0]' | sed -e 's/"//g')
gwport=$gw_port
gwhost=$(_ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin | grep $gw_port | sed -e 's,.*https*://,,' -e "s/:$gw_port.*//")
if [ "x$gwhost" = 'x' ]; then
 gwport=8080
 gwhost=$(_ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin | grep $gwport | sed -e 's,.*https*://,,' -e "s/:$gwport.*//")
fi
apiport=$api_port
apihost=$(_ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin | grep $api_port | sed -e 's,.*https*://,,' -e "s/:$api_port.*//")
if [ "x$apihost" = 'x' ]; then
 apiport=5001
 apihost=$(_ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin | grep $apiport | sed -e 's,.*https*://,,' -e "s/:$apiport.*//")
fi

echo "gw: $gwhost:$gwport -> $gw_port"
echo "api: $apihost:$apiport -> $api_port"

echo -n "docker: stopping "
docker stop $IPFS_CONTAINER
echo -n "docker: removing "
docker rm $IPFS_CONTAINER
set -x
docker run -d --name $IPFS_CONTAINER \
  -v $IPFS_STAGING:/export -v $IPFS_PATH:/data/ipfs -w /export \
  -u $uid:$gig \
  -p 4001:$swarm_port/tcp \
  -p 4001:$swarm_port/udp \
  -p $gwhost:$gwport:$gw_port \
  -p $apihost:$apiport:$api_port \
  $IPFS_IMAGE daemon

docker logs --until 59s $IPFS_CONTAINER | waitfor 'ready$'

docker ps -a -f name=$IPFS_CONTAINER

