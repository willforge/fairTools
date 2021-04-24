#

export IPFS_CONTAINER=${IPFS_CONTAINER:-ipfs-node}

# dockerized ipfs is _ipfs
_ipfs() {
 docker exec $IPFS_CONTAINER ipfs $@
}


dockerip=$(docker exec $IPFS_CONTAINER ifconfig eth0 | grep inet | sed -n -e 's/inet addr:/inet /' -e 's/^ *inet \([^ ]*\).*/\1/p;')
echo dockerip: $dockerip
gateway=$(_ipfs config Addresses.Gateway)
gw_port=$(echo $gateway | cut -d/ -f 5)
echo gw_port: $gw_port
api=$(_ipfs config Addresses.API)
api_port=$(echo $api | cut -d/ -f 5)
echo api_port: $api_port

docker exec -i -t $IPFS_CONTAINER sh
#_ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin
