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
set PATH=../bin:$PATH

key='clef-secrete'
label='a-big-log.txt'
urn="urn:wwlog:$label"
str="$key,$urn"
sha2=$(echo -n "$str" | openssl sha256 | cut -d' ' -f2)
sh36=$(echo "f$sha2" | base36 -d)
nid=$(echo "f$sha2" | base36 -d | cut -c 2-14)
echo urn: $urn
echo sha2: $sha2
echo sh36: $sh36
echo nid: $nid

ping=$(echo -n $nid | ipfs add -Q -n --pin=true --raw-leaves --hash sha3-224 --cid-base base58btc)
echo ping: $ping

ipfs dht findprovs /ipfs/$ping

