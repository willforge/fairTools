#

uid=$(id -u); gid=$(id -g)
IPFS_PATH=${IPFS_PATH:-$HOME/.ipfs}
IPFS_IMAGE=${IPFS_IMAGE:-ipfs/go-ipfs}
IPFS_CONTAINER=${IPFS_CONTAINER:-ipfs-node}

docker run -d --rm --name ipfs-test -u $uid:$gid $IPFS_IMAGE
docker logs ipfs-test
docker exec ipfs-test ipfs shutdown

docker ps -a


docker stop $IPFS_CONTAINER
docker rm $IPFS_CONTAINER
docker run -id --name $IPFS_CONTAINER -u $uid:$gid -v $IPFS_PATH:/data/ipfs $IPFS_IMAGE daemon



