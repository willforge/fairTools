#

url="$1"

if ! which ipfs >/dev/null; then
export IPFS_CONTAINER=${IPFS_CONTAINER:-ipfs-node}
ipfs() {
 docker exec $IPFS_CONTAINER ipfs $@
}

fi

while true; do
read url
qmdot="${url##*/}"
ipfs get -o jtree.dot $qmdot
dot -Tpng jtree.dot -o jtree.png;
done

#eog jtree.png

