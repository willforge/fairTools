#


peerid=$(ipfs config Identity.PeerID)
key='clef-secrete'
label='a-big-log.txt'
urn="urn:wwlog:$label"
sha2=$(echo -n "$key,$label" | openssl sha256 | cut -d' ' -f2)
nid=$(echo $sha2 | cut -c -13)

ping=$(echo -n $nid | ipfs add -Q --pin=true --raw-leaves --hash sha3-224 --cid-base base58btc)
echo ping: $ping

# ---------------------------------------------------------
echo nid:$nid 
emptyd=$(ipfs object new -- unixfs-dir);
emptyf=$(echo -n '' | ipfs add -Q --raw-leaves --hash sha1 --cid-base base36); # kb1yd76m7oxxg93t9yknau8srmzsj9oj1wz61
qm=$(ipfs object patch add-link $emptyd "$label" $emptyf)
echo qm: $qm
# ---------------------------------------------------------
# stage qm ...
if ! ipfs files stat /public/share --hash 1>/dev/null 2>&1; then
  ipfs files mkdir -p /public/share
fi
if ipfs files stat /public/share/$nid --hash 1>/dev/null 2>&1; then
  ipfs files rm -r /public/share/$nid
fi
ipfs files cp /ipfs/$qm "/public/share/$nid"
# ---------------------------------------------------------
#sh ../fairNet/publishroot.sh

# ---------------------------------------------------------
peerkey=$(ipfs --timeout 2s dht findprovs -n 1 /ipfs/$ping)
echo peerkey: $peerkey

ipfs ls /ipns/$peerkey/public/share/$nid
