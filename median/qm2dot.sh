#

url="$1"

if ! which ipfs >/dev/null; then
export IPFS_CONTAINER=${IPFS_CONTAINER:-ipfs-node}
ipfs() {
 docker exec $IPFS_CONTAINER ipfs $@
}

fi

echo please enter a qm ...

while true; do
read url
qmdot="${url##*/}"
#ipfs get -o jtree.dot $qmdot
echo fetching jtree.dot
curl -s -o jtree.dot http://127.0.0.1:8080/ipfs/$qmdot
ls -l jtree.dot
dot -Tpng jtree.dot -o jtree.png;
echo eog jtree.png
done

#eog jtree.png

