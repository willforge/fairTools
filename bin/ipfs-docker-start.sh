#

bindir=$(dirname "$(readlink -f "$0")")
rootdir=$(readlink -f "${bindir}/..")
export PERL5LIB=${PERL5LIB:-$rootdir/lib/perl5}
export IPFS_PATH=${IPFS_PATH:-$HOME/.ipfs}

export IPFS_IMAGE=${IPFS_IMAGE:-ipfs/go-ipfs}
export IPFS_CONTAINER=${IPFS_CONTAINER:-ipfs-node}

uid=$(id -u); gid=$(id -g)


# start docker if necessary ...
if ! docker ps -f name=$IPFS_CONTAINER | grep -q -w $IPFS_CONTAINER; then
  if ! docker ps -a -f name=$IPFS_CONTAINER | grep -q -w $IPFS_CONTAINER; then
    echo "docker: run $IPFS_IMAGE in $IPFS_CONTAINER"
    docker run -d --name $IPFS_CONTAINER --user $uid:$gid $IPFS_IMAGE
  else
    echo "docker: start $IPFS_CONTAINER"
    docker start $IPFS_CONTAINER
  fi
  sleep 7
else
  echo "docker: $IPFS_CONTAINER already running"
fi
docker ps -a -f name=$IPFS_CONTAINER

docker logs --since 59s $IPFS_CONTAINER 

