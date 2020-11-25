#

IPFS_IMAGE=${IPFS_IMAGE:-ipfs/go-ipfs}
IPFS_CONTAINER=${IPFS_CONTAINER:-ipfs-node}

docker stop $IPFS_CONTAINER
docker rm $IPFS_CONTAINER
docker run -it --rm -u $(id -u):$(id -g) $IPFS_IMAGE


