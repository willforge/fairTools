#

intent="add a status command to ipfs !"

red=$(echo -n "\e[31m")
green=$(echo -n "\e[1;32m")
yellow=$(echo -n "\e[1;33m")
cyan=$(echo -n "\e[2;36m")
grey=$(echo -n "\e[0;90m")
nc=$(echo -n "\e[0m")

if which ipfs >/dev/null; then
ipfs swarm addrs local 2>/dev/null | grep -v 127\.
if [ $? -ne 0 ]; then
  echo ${yellow}Warn: ipfs-native is ${red}not${yellow} running${nc}
else
  echo ${green}ipfs is running${nc}

  echo "IPFS_PATH=$IPFS_PATH"
  peerid=$(ipfs config Identity.PeerID) && echo peerid: $peerid

  gwaddr=$(ipfs config Addresses.Gateway)
  apiaddr=$(ipfs config Addresses.API)
  echo "gwaddr: $gwaddr"
  echo "apiaddr: $apiaddr"

 if grep -qa /docker /proc/1/cgroup; then
  gw_port=$(echo $gwaddr | cut -d/ -f 5)
  gw_host=$(echo $gwaddr | cut -d/ -f 3)
  echo url: http://$gw_host:$gw_port/ipfs/QmejvEPop4D7YUadeGqYWmZxHhLc4JBUCzJJHWMzdcMe2y
 fi


fi
fi

if which docker >/dev/null; then
  IPFS_CONTAINER=${IPFS_CONTAINER:-ipfs-node}
  # dockerized ipfs is _ipfs
  ipfs() {
    docker exec -i $IPFS_CONTAINER ipfs $@
  }

  if ! docker ps -f name=$IPFS_CONTAINER | grep -q -w $IPFS_CONTAINER; then
    echo ${red}Error: docker-ipfs is not running${nc}
  else
  docker exec -i $IPFS_CONTAINER ipfs swarm addrs local 2>/dev/null | grep -v 127\.
  if [ $? -ne 0 ]; then
    echo ${red}Error: ipfs-docker is not running${nc}
  else
    echo ${green}ipfs-docker is running${nc}

    echo "IPFS_CONTAINER=$IPFS_CONTAINER"
    peerid=$(ipfs config Identity.PeerID) && echo peerid: $peerid
    dockerip=$(docker exec $IPFS_CONTAINER ifconfig eth0 | grep addr | sed -n -e 's/^ *inet addr:\([^ ]*\).*/\1/p;')
    echo dockerip: $dockerip
    gwaddr=$(ipfs config Addresses.Gateway)
    apiaddr=$(ipfs config Addresses.API)
    echo "gwaddr: $gwaddr"
    echo "apiaddr: $apiaddr"
    gw_port=$(echo $gwaddr | cut -d/ -f 5)
    gw_host=$(echo $gwaddr | cut -d/ -f 3)
    echo url: http://$dockerip:$gw_port/ipfs/QmejvEPop4D7YUadeGqYWmZxHhLc4JBUCzJJHWMzdcMe2y

  fi
  fi

fi

