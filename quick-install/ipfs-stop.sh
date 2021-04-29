#

IPFS_CONTAINER=${IPFS_CONTAINER:-ipfs-node}
docker exec $IPFS_CONTAINER ipfs shutdown
sleep 4
docker logs --tail 3 $IPFS_CONTAINER
