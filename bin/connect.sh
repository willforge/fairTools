#

blockring=Qmd2iHMauVknbzZ7HFer7yNfStR4gLY1DSiih8kjquPzWV
michelc=QmcfHufAK9ErQ9ZKJF7YX68KntYYBJngkGDoVKcZEJyRve
emilea=12D3KooWHpj1ercuLscv78Ezz4TADdwSgNkmNmd4qH8dfCCcwZHX
alainbr=12D3KooWJDBrt6re8zveUPZKwC3QPBid4iCguyMVuWbKMXb5HeTa
marys=QmTeqJutKAtVyX39qvhAGfjQFesbubamN8dvVPMg5jYRwS

case "$1" in 
 michel*) peerkey=$michelc;;
 franc*) peerkey=$emilea;;
 emile*) peerkey=$emilea;;
 alain*) peerkey=$alainbr;;
 mary*) peerkey=$marys;;
 *) peerkey=$blockring;;
esac

# dockerized ipfs:
fn=$(perl -S fullname.pl $peerkey)
echo "$peerkey: $fn"

ping -c 1 gateway.ipfs.io 1>/dev/null &
ping -c 1 ipfs.blockringtm.ml
ipfs swarm connect /ip4/212.129.2.151/tcp/24001/ws/ipfs/$blockring

export IPFS_CONTAINER=${IPFS_CONTAINER:-ipfs-node}
export IPFS_PATH=${IPFS_PATH:-$HOME/.ipfs}
export IPFS_STAGING=${IPFS_STAGING:-$IPFS_PATH/staging}
echo IPFS_PATH: $IPFS_PATH
if ! which ipfs 2>/dev/null; then
ipfs() {
  docker exec -i $IPFS_CONTAINER ipfs "$@"
}
fi

ipfs dht findpeer $peerkey
ipfs ping -n 2 $peerkey
ipfs swarm connect /ip4/212.129.2.151/tcp/24001/ws/ipfs/$peerkey
