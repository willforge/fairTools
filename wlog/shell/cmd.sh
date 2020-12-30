# 

if ! which ipfs 2>/dev/null; then
ipfs() {
  docker exec -i ipfs-node ipfs "$@"
}
fi
set PATH=../bin:$PATH

key='clef-secrete'
label='a-big-log.txt'
urn="urn:wwlog:$label"
sha2=$(echo -n "$key,$label" | openssl sha256 | cut -d' ' -f2)
nid=$(echo $sha2 | cut -c -13)

ping=$(echo -n $nid | ipfs add -Q --pin=true --raw-leaves --hash sha3-224 --cid-base base58btc)
echo ping: $ping

peerid=$(ipfs config Identity.PeerID)
peerkey=$(ipfs dht findprovs -n 1 /ipfs/$ping)
ipfs=../bin/ipfs-docker
cat <<EOT
\`\`\`
# command to be run in a shell
echo -n $nid | ipfs add -Q --pin=true --raw-leaves --hash sha3-224 --cid-base base58btc
peerid=\$($ipfs config Identity.PeerID)
peerkey=$peerkey

$ipfs swarm addrs local
$ipfs dht findpeer $peerid
$ipfs name resolve $peerid

$ipfs --timeout 2s dht findprovs -n 2 /ipfs/$ping
$ipfs dht findprovs -n 3 /ipfs/$ping

$ipfs ping -n 2 \$peerkey
$ipfs name resolve \$peerkey

$ipfs ls /ipns/\$peerkey/public
$ipfs ls /ipns/\$peerkey/public/share/$nid
$ipfs cat /ipns/\$peerkey/public/share/$nid/$label
\`\`\`
EOT



