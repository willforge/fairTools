#

red=$(echo -n "\e[31m")
green=$(echo -n "\e[1;32m")
yellow=$(echo -n "\e[1;33m")
grey=$(echo -n "\e[0;90m")
nc=$(echo -n "\e[0m")

echo "--- # ${0##*/}"
sh $(which ft-provide-json_xs.sh)
. $(which ft-envrc.sh)

core=${code:-fair}
cachedir=${XDG_CACHE_HOME:-$HOME/.cache}/${core}Tools

export IPFS_PATH=${IPFS_PATH:-$HOME/.ipfs}
export IPFS_STAGING=${IPFS_STAGING:-$IPFS_PATH/staging}
if test ! -d $IPFS_STAGING; then mkdir -p $IPFS_STAGING; fi
export IPFS_IMAGE=${IPFS_IMAGE:-ipfs/go-ipfs}
export IPFS_CONTAINER=${IPFS_CONTAINER:-ipfs-node}

echo "export IPFS_CONTAINER=$IPFS_CONTAINER" >> $(which ft-envrc.sh)

sh $(which ft-provide-docker.sh)

# dockerized ipfs is _ipfs
ipfs() {
 docker exec -i $IPFS_CONTAINER ipfs $@
}


uid=$(id -u)
gid=$(id -g)

# 1. start docker 
if ! docker ps -f name=$IPFS_CONTAINER | grep -q -w $IPFS_CONTAINER; then
  # remove pre-existing container
  if docker ps -a -f name=$IPFS_CONTAINER | grep -q -w $IPFS_CONTAINER; then
     echo "docker: rm $IPFS_CONTAINER"
     docker rm $IPFS_CONTAINER
  fi
  # run a new one
  docker run -d --name $IPFS_CONTAINER --user $uid:$gid \
             -v $IPFS_PATH:/data/ipfs -w /export $IPFS_IMAGE daemon
  sleep 7
  docker logs $IPFS_CONTAINER
fi


if ! docker ps -f name=$IPFS_CONTAINER | grep -q -w $IPFS_CONTAINER; then
  echo "${red}Error: $IPFS_CONTAINER docker didn't start${nc}"
  exit 251
fi

# wait until daemon is ready
while true; do
 if docker logs --tail 3 $IPFS_CONTAINER | grep -q -w 'Daemon is ready'; then
   break
 fi
done

# 2. get config data
echo "IPFS_PATH=$IPFS_PATH"
peerid=$(ipfs config Identity.PeerID) && echo peerid: $peerid
dockerip=$(docker exec $IPFS_CONTAINER ifconfig eth0 | grep addr | sed -n -e 's/^ *inet addr:\([^ ]*\).*/\1/p;')
gwaddr=$(ipfs config Addresses.Gateway)
apiaddr=$(ipfs config Addresses.API)
echo dockerip: $dockerip
echo "gwaddr: $gwaddr"
echo "apiaddr: $apiaddr"

gw_port=$(echo $gwaddr | cut -d/ -f 5)
api_port=$(echo $apiaddr | cut -d/ -f 5)
# pick the first for the swarm address
swarm_port=$(ipfs config Addresses.Swarm | grep -e /tcp | head -1 | cut -d/ -f5 | sed -e 's/".*//')
h=$( expr $gw_port \% 251 )
echo "gateway: http://127.0.0.$h/ipfs/"

# assumptions:
#  - origin is the first of the Access-Control-Allow-Origin list
#  - gateway is the first w/ port = 8080 or gw_port (from Addresses.Gateway)
#  - api is the first w/ port = 5001 or api_port (from Addresses.API)

if ! grep -q Access-Control-Allow-Origin $IPFS_PATH/config ; then
# localgw
gwport=8080
h=$( expr $gwport \% 251 )
localgw="127.0.0.$h"
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["http://${dokerip}:${gw_port}", "http://${dokerip}:${api_port}", http://${localgw}:8080", "http://${localgw}:5001", "https://127.0.0.1:8080", "https://127.0.0.1:3000", "http://localhost:1124", "https://localhost", "https://webui.ipfs.io", "https://ipfs.blockringtm.ml"]'
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '["PUT", "POST"]'
fi

origin=$(ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin | json_xs -e '$_ = $_->[0]' | sed -e 's/"//g')
gwport=8080
gwhost=$(ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin | grep $gwport | head -1 | sed -e 's,.*https*://,,' -e "s/:$gwport.*//")
if [ "x$gwhost" = 'x' ]; then
  gwport=$gw_port
  gwhost=$(_ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin | grep $gw_port | head -1 | sed -e 's,.*https*://,,' -e "s/:$gw_port.*//")
fi
apiport=5001
apihost=$(ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin | grep $apiport | head -1 | sed -e 's,.*https*://,,' -e "s/:$apiport.*//")
if [ "x$apihost" = 'x' ]; then
  apiport=$api_port
  apihost=$(ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin | grep $api_port | head -1 | sed -e 's,.*https*://,,' -e "s/:$api_port.*//")
fi

h=$( expr $gwport \% 251 )
host="127.0.0.$h"
echo host: $host

echo origin: $origin
echo gwhost: $gwhost
echo apihost: $apihost

webkey=QmY5irRjuwhhFvkY88ScnM7ow3DxvbhEi13mDAsUUVHRN4
webui=$(ipfs name resolve /ipns/$webkey)
if [ "z$webui" = 'z' ]; then
webui=/ipfs/Qmb3cY3zFJ5isjJ5H9cP47Vfqa6pqNwypbuo2TiBGjUmLd
fi


tic=$(date +%s)
cat > $cachedir/config.js <<EOF
window.config = {
 'origin': "$origin",
 'host': "$host",
 'gw_url': "http://${dockerip}:${gw_port}",
 'api_url': "http://${dockerip}:${api_port}/api/v0/"
 'swarm_port': "${swarm_port}",
 'swarm_ip': "${dockerip}",
 'webkey': "$webkey",
 'webui': "$webui",
 'tic': "${tic}"
};
EOF

qmcfg=$(cat $cachedir/config.js | ipfs add -Q -)
echo qmcfg: $qmcfg


# 3. recreate container w/ port forwarding and mounted volumes
echo -n "docker: stopping "
docker stop $IPFS_CONTAINER
echo -n "docker: removing "
docker rm $IPFS_CONTAINER
set -x
# allow docker to access fairTools folder
docker run -d --name $IPFS_CONTAINER \
  -v $IPFS_STAGING:/export -v $IPFS_PATH:/data/ipfs -w /export \
  -u $uid:$gid \
  -p 4001:$swarm_port/tcp \
  -p 4001:$swarm_port/udp \
  -p $gwhost:$gwport:$gw_port \
  -p $apihost:$apiport:$api_port \
  $IPFS_IMAGE daemon
set +x
docker logs --until 59s $IPFS_CONTAINER

docker ps -a -f name=$IPFS_CONTAINER

echo api: http://${dockerip}:${api_port}/webui/
echo gw: http://${dockerip}:${gw_port}/ipns/$peerid/
echo webui: http://$host:${gwport}$webui/

