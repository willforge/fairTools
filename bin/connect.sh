#

blockring=Qmd2iHMauVknbzZ7HFer7yNfStR4gLY1DSiih8kjquPzWV
michelc=QmcfHufAK9ErQ9ZKJF7YX68KntYYBJngkGDoVKcZEJyRve
emilea=12D3KooWHpj1ercuLscv78Ezz4TADdwSgNkmNmd4qH8dfCCcwZHX
alainbr=12D3KooWJDBrt6re8zveUPZKwC3QPBid4iCguyMVuWbKMXb5HeTa
marys=QmTeqJutKAtVyX39qvhAGfjQFesbubamN8dvVPMg5jYRwS
# /dnsaddr/fra1-2.hostnodes.pinata.cloud/p2p/QmNfpLrQQZr5Ns9FAJKpyzgnDL2GgC6xBug1yUZozKFgu4
pinata=QmNfpLrQQZr5Ns9FAJKpyzgnDL2GgC6xBug1yUZozKFgu4


case "$1" in 
 mic*) peerkey=$michelc;;
 fran*) peerkey=$emilea;;
 emil*) peerkey=$emilea;;
 al*) peerkey=$alainbr;;
 mar*) peerkey=$marys;;
 pina*) peerkey=$pinata;;
 *) peerkey=$blockring;;
esac

if echo -n "\e" | grep -q -e 'e'; then
 e="-e" # bash needs a -e !
fi
# colors : [see also](https://en.wikipedia.org/wiki/ANSI_escape_code)
default=$(echo -n $e "\e[39m")
red=$(echo -n $e "\e[31m")
green=$(echo -n $e "\e[1;32m")
yellow=$(echo -n $e "\e[1;33m")
cyan=$(echo -n $e "\e[2;36m")
grey=$(echo -n $e "\e[0;90m")
nc=$(echo -n $e "\e[0m")

fn=$(perl -S fullname.pl $peerkey)
echo "$peerkey: $fn"

ping -c 1 gateway.ipfs.io 1>/dev/null &
echo "${yellow}dial home for relaying ...${nc}"
ping -c 1 ipfs.blockringtm.ml

# dockerized ipfs:
export IPFS_CONTAINER=${IPFS_CONTAINER:-ipfs-node}
export IPFS_PATH=${IPFS_PATH:-$HOME/.ipfs}
export IPFS_STAGING=${IPFS_STAGING:-$IPFS_PATH/staging}
echo "IPFS_PATH: ${cyan}$IPFS_PATH${nc}"
if ! which ipfs 2>/dev/null; then
ipfs() {
  docker exec -i $IPFS_CONTAINER ipfs "$@"
}
fi

peerid=$(ipfs config Identity.PeerID)

echo "${yellow}connect to blockring™${nc}"
ipfs swarm connect /ip4/212.129.2.151/tcp/24001/ws/p2p/$blockring

echo "${yellow}local addresses:${nc}"
ipfs swarm addrs local | grep -v -e '127\.' -e '192\.168\.' -e '::1' | sed -e "s,^,${green}," -e "s,$,${nc}/p2p/$peerid,"

echo "${yellow}$peerkey addresses:${nc}"
echo -n ${green}
ipfs dht findpeer $peerkey | grep -v -e '127\.' -e '::1'
echo "${yellow}pinging $peerkey${nc}"
ipfs ping -n 2 $peerkey
echo "${yellow}swarm connect $peerkey${nc}"
ipfs swarm connect /ip4/212.129.2.151/tcp/24001/ws/p2p/$peerkey
