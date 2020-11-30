# 

# dockerized ipfs:
export IPFS_CONTAINER=${IPFS_CONTAINER:-ipfs-node}
export IPFS_PATH=${IPFS_PATH:-$HOME/.ipfs}
export IPFS_STAGING=${IPFS_STAGING:-$IPFS_PATH/staging}
echo IPFS_PATH: $IPFS_PATH
if ! which ipfs 2>/dev/null; then
ipfs() {
  docker exec -i $IPFS_CONTAINER ipfs "$@"
}
fi


qm=$(echo -n 'fairTeam' | ipfs add -Q --raw-leaves --pin=true --hash sha3-224 --cid-base base58btc)
echo "ping: $qm"
echo "provs: |-"
ipfs dht findprovs "/ipfs/$qm" | sed -e 's/^/  /'

true;
