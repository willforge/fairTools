#!/bin/sh

container=ipfs/go-ipfs
export IPFS_PATH=$HOME/.../ipfs/repo/docker
export IPFS_STAGING=$IPFS_PATH/staging

if [ ! -d $IPFS_STAGING ]; then
 mkdir -p $IPFS_STAGING;
fi
docker stop ipfs-node

peerid=$(ipfs config Identity.PeerID) && echo peerid: $peerid
gateway=$(ipfs config Addresses.Gateway)
gw_port=$(echo $gateway | cut -d/ -f 5)
api=$(ipfs config Addresses.API)
api_port=$(echo $api | cut -d/ -f 5)
swarm_port=$(ipfs config Addresses.Swarm | grep -e /tcp | head -1 | cut -d/ -f5 | sed -e 's/".*//')
webui_host="127.0.0.$(expr "$gw_port" % 251)"
echo webui_url: http://$webui_host:8080

ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["http://'$webui_host':8080", "http://localhost:8088", "http://127.0.0.1:5001", "https://webui.ipfs.io"]'

#        --init --restart unless-stopped \
docker rm ipfs-node
docker run -d --name ipfs-node \
        -v $IPFS_STAGING:/export \
        -v $IPFS_PATH:/data/ipfs \
        -w /export \
        -p 4001:$swarm_port/udp \
        -p 4001:$swarm_port \
        -p $webui_host:8080:$gw_port \
        -p 127.0.0.1:5001:$api_port \
        $container daemon

if ! grep -q Access-Control-Allow-Origin $IPFS_PATH/config ; then
docker exec ipfs-node ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["http://$webui_host:8080", "http://localhost:8088", "http://127.0.0.1:5001", "https://webui.ipfs.io"]'
docker exec ipfs-node ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '["PUT", "POST"]'
fi

docker logs --until 59s ipfs-node

