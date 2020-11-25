#

image=ipfs/go-ipfs
container=${container:-ipfs-test}
ipfs() {
 docker exec $container ipfs $@
}

# 1. start docker if necessary ...
if ! docker ps -f name=$container | grep -q -w $container; then
if ! docker ps -a -f name=$container | grep -q -w $container; then
echo "docker: run $image in $container"
docker run -d --name $container $image
else
echo "docker: start $container"
docker start $container
fi
sleep 7
docker logs $container | waitfor 'ready$'
fi
docker ps -a -f name=$container


# get config data
peerid=$(ipfs config Identity.PeerID) && echo peerid: $peerid
gateway=$(ipfs config Addresses.Gateway)
api=$(ipfs config Addresses.API)
echo "gateway: $gateway"
echo "api: $api"
gw_port=$(echo $gateway | cut -d/ -f 5)
api_port=$(echo $api | cut -d/ -f 5)
swarm_port=$(ipfs config Addresses.Swarm | grep -e /tcp | head -1 | cut -d/ -f5 | sed -e 's/".*//')

if ! grep -q Access-Control-Allow-Origin $IPFS_PATH/config ; then
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["http://127.0.0.1:8080", "http://localhost:80", "http://127.0.0.1:5001", "https://webui.ipfs.io"]'
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '["PUT", "POST"]'
fi


origin=$(ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin | json_xs -e '$_ = $_->[0]' | sed -e 's/"//g')
gwport=$gw_port
gwhost=$(ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin | grep $gw_port | sed -e 's,.*https*://,,' -e "s/:$gw_port.*//")
if [ "x$gwhost" = 'x' ]; then
 gwport=8080
 gwhost=$(ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin | grep $gwport | sed -e 's,.*https*://,,' -e "s/:$gwport.*//")
fi
apiport=$api_port
apihost=$(ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin | grep $api_port | sed -e 's,.*https*://,,' -e "s/:$api_port.*//")
if [ "x$apihost" = 'x' ]; then
 apiport=5001
 apihost=$(ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin | grep $apiport | sed -e 's,.*https*://,,' -e "s/:$apiport.*//")
fi

echo "gw: $gwhost:$gwport -> $gw_port"
echo "api: $apihost:$apiport -> $api_port"

echo -n "docker: stopping "
docker stop $container
echo -n "docker: removing "
docker rm $container
set -x
docker run -d --name $container \
  -v $IPFS_STAGING:/export -v $IPFS_PATH:/data/ipfs -w /export \
  -p 4001:$swarm_port/tcp \
  -p 4001:$swarm_port/udp \
  -p $gwhost:$gwport:$gw_port \
  -p $apihost:$apiport:$api_port \
  $image daemon

docker logs --until 59s $container | waitfor 'ready$'

docker ps -a -f name=$container

