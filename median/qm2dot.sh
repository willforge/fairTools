#

url="$1"

while true; do
read url
qmdot="${url##*/}"
ipfs get -o jtree.dot $qmdot
dot -Tpng jtree.dot -o jtree.png;
done

#eog jtree.png

