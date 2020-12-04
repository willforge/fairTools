#

# intend: append a global log !!!

core=fair
cachedir=$HOME/.cache/${core}Tools
if [ ! -d $cachedir ]; then
  mkdir $cachedir
fi

export IPFS_CONTAINER=${IPFS_CONTAINER:-ipfs-node}

if ! which ipfs 2>/dev/null; then 
 ipfs() {
  echo docker exec ipfs-node ipfs $@ 1>&2
  docker exec -i $IPFS_CONTAINER ipfs "$@"
 }
fi
moddir=$(dirname "$(readlink -f "$0")")
rootdir=$(readlink -f "${moddir}/..")
export PATH=$rootdir/bin:$PATH


peerid=$(ipfs config Identity.PeerID)
key='clef-secrete'
label='a-big-log.txt'
uri="$key,urn:wwlog:$label";
#sha2=$(echo -n "$uri" | openssl sha256 | cut -d' ' -f2)
nid=$(perl -S getnid.pl "$uri")

ping=$(echo -n $nid | ipfs add -Q -n --pin=true --raw-leaves --hash sha3-224 --cid-base base58btc)

# ------------------------------------------
# create new log if doesn't exist
if [ ! -d $cachedir/$nid ]; then
  mkdir -p $cachedir/$nid
fi

if ! ipfs files stat /public/share/$nid --hash 1>/dev/null 2>&1; then
  ipfs files mkdir -p /public/share/$nid
fi
if ipfs files stat /public/share/$nid/$label --hash 1>/dev/null 2>&1; then
  ipfs files read /public/share/$nid/$label > "$cachedir/$nid/$label.all"
else
  echo "# log $urn for $peerid $(date +%D) (nid:$nid)" > "$cachedir/$nid/$label.all"
fi

# ------------------------------------------
# pull log from peerkeys...
peerkeys="$(ipfs --timeout 30s dht findprovs /ipfs/$ping 2>/dev/null)"

for peerkey in $peerkeys; do
 echo peerkey: $peerkey

if [ "x$peerkey" = "x$peerid" ]; then
  continue
else 
  ipfs ping -n 1 $peerkey
  maddr=$(ipfs --timeout 15s dht findpeer $peerkey | tail -1)
  if [ "x$maddr" != 'x' ]; then
    echo maddr: $maddr
    echo ipfs swarm connect $maddr/p2p/$peerkey
    ipfs swarm connect $maddr/p2p/$peerkey
  fi
fi

ipath=$(ipfs --timeout 61s resolve /ipns/$peerkey/public/share/$nid)
echo "ipath: $ipath"
if [ ! "x$ipath" = 'x' ]; then
# get log...
ipfs cat "$ipath/$label" >> "$cachedir/$nid/$label.all"
fi

done
if ipfs files stat /public/share/$nid/$label --hash 1>/dev/null 2>&1; then
  ipfs files rm -r /public/share/$nid/$label
fi
# ------------------------------------------
perl -S uniq.pl "$cachedir/$nid/$label.all" > "$cachedir/$nid/$label"
echo "file: $cachedir/$nid/$label |-"
tail -3 "$cachedir/$nid/$label" | sed -e 's/^/  /';

qm=$(cat "$cachedir/$nid/$label" | ipfs add -Q --raw-leaves --hash sha1 --cid-base base36)
echo qm: $qm;
ipfs files cp /ipfs/$qm "/public/share/$nid/$label"
new=$(ipfs files stat --hash "/public/share/$nid")
echo url: http://127.0.0.1:8080/ipfs/$new


