#


# ------------------------------------------------------------------------------------
echo "--- # ${0##*/}"
export IPFS_IMAGE=${IPFS_IMAGE:-ipfs/go-ipfs}
export IPFS_CONTAINER=${IPFS_CONTAINER:-ipfs-node}

if [ "?$IPFS_PATH" != '?' ]; then
echo IPFS_PATH: $IPFS_PATH
fi
IPFS_PATH=${IPFS_PATH:-$HOME/.ipfs}

if echo -n "\e" | grep -q -e 'e'; then
 e="-e" # bash needs a -e !
fi
red=$(echo -n $e "\e[31m")
green=$(echo -n $e "\e[1;32m")
yellow=$(echo -n $e "\e[1;33m")
nc=$(echo -n $e "\e[0m")
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
else
  echo "docker: ${green}$IPFS_CONTAINER is running${nc}"
  echo "        ${yellow}you might want to stop this $IPFS_CONTAINER w/ sh ipfs-stop.sh${nc}"
  was_running=1
fi


# 2. check is container is indeed running
if ! docker ps -f name=$IPFS_CONTAINER | grep -q -w $IPFS_CONTAINER; then
  echo "${red}Error: $IPFS_CONTAINER docker didn't run${nc}"
  echo "      ${yellow}you might have an other ipfs daemon locking the repository, you might want to do a 'ipfs shutdown'${nc}"
  exit 251
else
  if [ "x$was_running" = 'x' ]; then
    echo "docker: ${green}$IPFS_CONTAINER is running${nc}"
  fi
fi

# wait until daemon is ready
while true; do
 if docker logs --tail 3 $IPFS_CONTAINER | grep -q -w 'Daemon is ready'; then
   break
 fi
done
# ------------------------------------------------------------------------------------
