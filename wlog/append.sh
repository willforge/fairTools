#

line="$@"
core=fair
cachedir=$HOME/.cache/${core}Tools
if [ ! -d $cachedir ]; then
  mkdir $cachedir
fi


if ! which ipfs 2>/dev/null; then 
 ipfs() {
  echo docker exec ipfs-node ipfs $@ 1>&2
  docker exec -i $IPFS_CONTAINER ipfs "$@"
 }
fi


peerid=$(ipfs config Identity.PeerID)
key='clef-secrete'
label='a-big-log.txt'
urn="urn:wwlog:$label"
sha2=$(echo -n "$key,$label" | openssl sha256 | cut -d' ' -f2)
nid=$(echo $sha2 | cut -c -13)

ping=$(echo -n $nid | ipfs add -Q -n --pin=true --raw-leaves --hash sha3-224 --cid-base base58btc)

peerkey=$(ipfs --timeout 1s dht findprovs -n 1 /ipfs/$ping)
ipfs ping -n 1 $peerkey
maddr=$(ipfs dht findpeer $peerkey | tail -1)
echo maddr: $maddr
echo ipfs swarm connect $maddr/p2p/$peerkey
ipfs swarm connect $maddr/p2p/$peerkey

ipath=$(ipfs resolve /ipns/$peerkey/public/share/$nid)
# get log...
if [ ! -d $cachedir/$nid ]; then
  mkdir -p $cachedir/$nid
fi

if ! ipfs files stat /public/share/$nid --hash 1>/dev/null 2>&1; then
  ipfs files mkdir -p /public/share/$nid
fi
if ipfs files stat /public/share/$nid/$label --hash 1>/dev/null 2>&1; then
  ipfs files read /public/share/$nid/$label > "$cachedir/$nid/$label"
  ipfs files rm -r /public/share/$nid/$label
else
  echo "# log $urn (nid:$nid) $(date +%D)" > "$cachedir/$nid/$label"
fi

ipfs cat "$ipath/$label" >> "$cachedir/$nid/$label"
echo "$line" >> "$cachedir/$nid/$label"
echo "file: $cachedir/$nid/$label |-"
tail -3 "$cachedir/$nid/$label" | sed -e 's/^/  /';

qm=$(cat "$cachedir/$nid/$label" | ipfs add -Q --raw-leaves --hash sha1 --cid-base base36)
echo qm: $qm;
ipfs files cp /ipfs/$qm "/public/share/$nid/$label"
new=$(ipfs files stat --hash "/public/share/$nid")
echo url: http://127.0.0.1:8080/ipfs/$new


