#

# dockerized ipfs is _ipfs
_ipfs() {
 docker exec $IPFS_CONTAINER ipfs $@
}

dockerip=$(docker exec $IPFS_CONTAINER ifconfig eth0 | grep inet | sed -n -e 's/inet addr:/inet /' -e 's/^ *inet \([^ ]*\).*/\1/p;')
echo dockerip: $dockerip
api=$(_ipfs config Addresses.API)
gateway=$(_ipfs config Addresses.Gateway)
gw_port=$(echo $gateway | cut -d/ -f 5)
echo gw_port: $gw_port
api_port=$(echo $api | cut -d/ -f 5)
webui_url="http://$dockerip:$api_port/webui"
echo "webui_url: http://$dockerip:$api_port/ipns/webui.ipfs.io"

_ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin | grep blockring
_ipfs $*
