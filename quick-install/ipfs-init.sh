#


echo "--- # ${0##*/}"

export IPFS_CONTAINER=${IPFS_CONTAINER:-ipfs-node}
# dockerized ipfs is _ipfs
_ipfs() {
 docker exec $IPFS_CONTAINER ipfs $@
}
#export IPFS_PATH=${IPFS_PATH:-$HOME/.ipfs}
echo " export IPFS_PATH=$IPFS_PATH"


peerid=$(_ipfs config Identity.PeerID) && echo peerid: $peerid
echo peerid: $peerid
dockerip=$(docker exec $IPFS_CONTAINER ifconfig eth0 | grep inet | sed -n -e 's/inet addr:/inet /' -e 's/^ *inet \([^ ]*\).*/\1/p;')
echo dockerip: $dockerip
echo repo:
_ipfs repo stat
gateway=$(_ipfs config Addresses.Gateway)
api=$(_ipfs config Addresses.API)
echo "gateway: $gateway"
echo "api: $api"
gw_port=$(echo $gateway | cut -d/ -f 5)
api_port=$(echo $api | cut -d/ -f 5)
swarm_port=$(_ipfs config Addresses.Swarm | grep -e /tcp | head -1 | cut -d/ -f5 | sed -e 's/".*//')
echo gw_port: $gw_port
echo api_port: $api_port
echo swarm: $swarm_port

allowed_origins="['http://$dockerip:$gw_port', 'http://localhost', 'http://127.0.0.1:5001', 'https://ipfs.blockringtm.ml', 'https://webui.ipfs.io']"
echo allowed_origins: $allowed_origins
allowed_origins=$(echo $allowed_origins | sed -e 's/\'/\"/g')

_ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin "$allowed_origins"
if ! _ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin; then
_ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '["PUT", "POST"]'
fi

#curl -s -D - -X POST "http://$dockerip:$api_port/api/v0/id"
echo 'curl -s -D - -X POST "http://'$dockerip:$api_port'/api/v0/add?file=test&pin=true&raw-leaves=true&hash=sha3-224&cid-base=base58btc" -F "file=fairTeam"'
curl -si -X POST "http://$dockerip:$api_port/api/v0/add?file=test&pin=true&raw-leaves=true&hash=sha3-224&cid-base=base58btc" -F "file=fairTeam"

