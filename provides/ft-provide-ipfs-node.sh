#

fname=${0##*/}
echo "--- # ${fname}"
prefix=${fname%%-*}; cli=$(which $prefix); wrapper=$(readlink -f $cli);
CLIDIR=$(dirname $wrapper); export PATH=$PATH:$CLIDIR;
if [ "x$FAIRTOOLS_PATH" = 'x' ]; then . $CLIDIR/ft-envrc.sh; fi # load run-time env

red=$(echo -n "\e[31m")
green=$(echo -n "\e[1;32m")
yellow=$(echo -n "\e[1;33m")
grey=$(echo -n "\e[0;90m")
nc=$(echo -n "\e[0m")

core=${core:-fair}
rname=${fname%%.*}
what=${rname#*provide-}
cachedir=${XDG_CACHE_HOME:-$HOME/.cache}/${core}Tools
echo cachedir: $cachedir

#export IPFS_PATH=${IPFS_PATH:-$ROOTDIR/ipfs/repo/docker}
export IPFS_PATH=${IPFS_PATH:-$HOME/.ipfs}
export IPFS_STAGING=${IPFS_STAGING:-$IPFS_PATH/staging}
if test ! -d $IPFS_STAGING; then mkdir -p $IPFS_STAGING; fi


# on a native system install docker and container ipfs/go-ipfs
# otherwise run natively ipfs 

# 1. get IPFS node running
if grep -qa /docker /proc/1/cgroup; then

# ------------------------------------------------------------------------------------
# within docker ...
sh $(which ft-provide-ipfs.sh)
sh $(which ft-ipfs-native-run.sh)
# ------------------------------------------------------------------------------------

else 
export IPFS_IMAGE=${IPFS_IMAGE:-ipfs/go-ipfs}
export IPFS_CONTAINER=${IPFS_CONTAINER:-ipfs-node}

echo "export IPFS_CONTAINER=$IPFS_CONTAINER" >> $CLIDIR/ft-envrc.sh

# ------------------------------------------------------------------------------------
# outside docker ...
sh $(which ft-provide-docker.sh)
sh $(which ft-ipfs-docker-run.sh)

# dockerized ipfs is _ipfs
ipfs() {
 docker exec -i $IPFS_CONTAINER ipfs $@
}
sh $(which ft-provide-ifconfig.sh)
# ipfs-node: inet addr:172.17.0.3
# ubuntu/debian inet 192.168.1.119
dockerip=$(docker exec $IPFS_CONTAINER ifconfig eth0 | grep inet | sed -n -e 's/inet addr:/inet /' -e 's/^ *inet \([^ ]*\).*/\1/p;')
echo dockerip: $dockerip
# ------------------------------------------------------------------------------------
fi

# 2. get config data
echo "IPFS_PATH=$IPFS_PATH"
peerid=$(ipfs config Identity.PeerID) && echo peerid: $peerid
gwaddr=$(ipfs config Addresses.Gateway)
apiaddr=$(ipfs config Addresses.API)
echo "gwaddr: $gwaddr"
echo "apiaddr: $apiaddr"

gw_port=$(echo $gwaddr | cut -d/ -f 5)
api_port=$(echo $apiaddr | cut -d/ -f 5)
node_ip=$(ipfs swarm addrs listen | grep /ip4 | tail -1 | cut -d/ -f 3)
echo "node_ip: $node_ip"

# pick the first for the swarm address
swarm_port=$(ipfs config Addresses.Swarm | grep -e /tcp | head -1 | cut -d/ -f5 | sed -e 's/".*//')
#h=$( expr $gw_port \% 251 )

# assumptions:
#  - origin is the first of the Access-Control-Allow-Origin list
#  - gateway is the first w/ port = 8080 or gw_port (from Addresses.Gateway)
#  - api is the first w/ port = 5001 or api_port (from Addresses.API)

if ! grep -qa /docker /proc/1/cgroup; then
if ! grep -q Access-Control-Allow-Origin $IPFS_PATH/config ; then
# localgw
gwport=8080
h=$( expr $gwport \% 251 )
localgw="127.0.0.$h"
echo "localgw: http://$localgw:$gwport/ipfs/Qmb3cY3zFJ5isjJ5H9cP47Vfqa6pqNwypbuo2TiBGjUmLd"
if [ "0$dockerip" != '0' ]; then
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["http://${dokerip}:${gw_port}", "http://${dokerip}:${api_port}", http://${localgw}:8080", "http://${localgw}:5001", "https://127.0.0.1:8080", "https://127.0.0.1:3000", "http://localhost:1124", "https://localhost", "https://webui.ipfs.io", "https://ipfs.blockringtm.ml"]'
else
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["http://0.0.0.0:${gw_port}", "http://0.0.0.0:${api_port}", http://${localgw}:8080", "http://${localgw}:5001", "https://127.0.0.1:8080", "https://127.0.0.1:3000", "http://localhost:1124", "https://localhost", "https://webui.ipfs.io", "https://ipfs.blockringtm.ml"]'
fi

ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '["PUT", "POST"]'
fi

sh $(which ft-provide-json_xs.sh)

origin=$(ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin | json_xs -t string -e '$_ = $_->[0]')
gwport=8080
gwhost=$(ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin | grep $gwport | head -1 | sed -e 's,.*https*://,,' -e "s/:$gwport.*//")
if [ "h$gwhost" = 'h127.0.0.1' ]; then
  ping=$(curl -sL $gwhost:$gwport/ipfs/QmejvEPop4D7YUadeGqYWmZxHhLc4JBUCzJJHWMzdcMe2y)
  if [ "x$ping" = 'xipfs' ]; then gwhost=$localgw; fi
fi
if [ "x$gwhost" = 'x' ]; then
  gwport=$gw_port
  gwhost=$(ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin | grep $gw_port | head -1 | sed -e 's,.*https*://,,' -e "s/:$gw_port.*//")
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

gw_host=$dockerip
api_host=$dockerip

else # native ipfs
gwhost=$(echo $gwaddr | cut -d'/' -f3)
apihost=$(echo $apiaddr | cut -d'/' -f3)
gwport=$gw_port
apiport=$api_port
host=$gwhost
origin=$gwhost

gw_host=$node_ip
api_host=$node_ip
fi

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
 'gw_url': "http://${gw_host}:${gw_port}",
 'api_url': "http://${api_host}:${api_port}/api/v0/"
 'swarm_port': "${swarm_port}",
 'swarm_ip': "${node_ip}",
 'webkey': "$webkey",
 'webui': "$webui",
 'tic': "${tic}"
};
EOF

qmcfg=$(cat $cachedir/config.js | ipfs add -Q -)
echo qmcfg: $qmcfg


# -------------------------------------------------------------
# 3. recreate container w/ port forwarding and mounted volumes
if ! grep -qa /docker /proc/1/cgroup; then

echo -n "docker: ${yellow}stopping${nc} "
docker stop $IPFS_CONTAINER
echo -n "docker: ${yellow}removing${nc} "
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
  sleep 7
set +x
docker logs --until 59s $IPFS_CONTAINER

docker ps -a -f name=$IPFS_CONTAINER

echo api: http://${dockerip}:${api_port}/webui/
echo gw: http://${dockerip}:${gw_port}/ipns/$peerid/
else
echo api: http://${apihost}:${api_port}/webui/
echo gw: http://${node_ip}:${gw_port}/ipns/$peerid/
fi
echo webui: http://$gwhost:${gwport}$webui/

# -------------------------------------------------------------
echo "---"
if ipfs cat QmYM9DjwHp7nFHw4kezZSc3kev7LL1X6LuLFJGJCpxx9bX >/dev/null; then
  echo "$what: ${green}provided${nc}"
  echo "... # $fname"
  return $?
else
  echo "${red}Error: $what failed to install!${nc}"
  echo "... # $fname 💣"
  return $(expr $$ % 252)
fi

true;

