#

echo "--- # ${0##*/}"
export IPFS_IMAGE=${IPFS_IMAGE:-ipfs/go-ipfs}
export IPFS_CONTAINER=${IPFS_CONTAINER:-ipfs-node}

if [ "?$IPFS_PATH" != '?' ]; then
echo IPFS_PATH: $IPFS_PATH
fi
IPFS_PATH=${IPFS_PATH:-$HOME/.ipfs}


red=$(echo -n "\e[31m")
green=$(echo -n "\e[1;32m")
nc=$(echo -n "\e[0m")
# ------------------------------------------------------------------------------------
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
  echo "${red}Error: $IPFS_CONTAINER docker didn't run${nc}"
  exit 251
else
  echo "docker: ${green}$IPFS_CONTAINER is running${nc}"
fi

# wait until daemon is ready
while true; do
 if docker logs --tail 3 $IPFS_CONTAINER | grep -q -w 'Daemon is ready'; then
   break
 fi
done
# ------------------------------------------------------------------------------------
