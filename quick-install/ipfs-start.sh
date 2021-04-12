#

IPFS_CONTAINER=${IPFS_CONTAINER:-ipfs-node}
docker start $IPFS_CONTAINER
sleep 7
docker logs --tail 3 $IPFS_CONTAINER
peerid=$(docker exec $IPFS_CONTAINER ipfs config Identity.PeerID)
echo peerid: $peerid
docker exec $IPFS_CONTAINER ipfs swarm addrs local
