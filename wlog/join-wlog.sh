# 

# dockerized ipfs:
export IPFS_PATH=${IPFS_PATH:-$HOME/.ipfs}
export IPFS_STAGING=${IPFS_STAGING:-$IPFS_PATH/staging}
export IPFS_IMAGE=${IPFS_IMAGE:-ipfs/go-ipfs}
export IPFS_CONTAINER=${IPFS_CONTAINER:-ipfs-node}
echo IPFS_PATH: $IPFS_PATH

if ! which ipfs 2>/dev/null; then
ipfs() {
  docker exec -i ipfs-node ipfs "$@"
}
fi
export PATH=../bin:$PATH

key='clef-secrete'
label='a-big-log.txt'
uri="$key,urn:wwlog:$label";
#sha2=$(echo -n "$uri" | openssl sha256 | cut -d' ' -f2)
nid=$(perl -S getnid.pl "$uri")


ping=$(echo -n $nid | ipfs add -Q --pin=true --raw-leaves --hash sha3-224 --cid-base base58btc)
echo ping: $ping

