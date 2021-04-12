#

IPFS_CONTAINER=${IPFS_CONTAINER:-ipfs-node}
docker exec $IPFS_CONTAINER ipfs shutdown
sleep 3
docker logs --tail 3 $IPFS_CONTAINER
sleep 4
docker start $IPFS_CONTAINER
sleep 5
docker logs --tail 3 $IPFS_CONTAINER
#

