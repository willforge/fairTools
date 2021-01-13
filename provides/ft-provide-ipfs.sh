# 
echo "--- # ${0##*/}"
CALLINGDIR=$(dirname $0); export PATH=$PATH:$CALLINGDIR;

if ! which ipfs >/dev/null; then
ver=v0.7.0
arch=linux-amd64
IPFS_NODE_NAME=IPFS

pwd=$(pwd);
. $CALLINGDIR/ft-provide-envrc.sh

#fname=${0##*/}
#echo "--- # ${fname}"
#prefix=${fname%%-*}; cli=$(which $prefix); wrapper=$(readlink -f $cli);
#CLIDIR=$(dirname $wrapper); export PATH=$PATH:$CLIDIR;
#if [ "x$FAIRTOOLS_PATH" = 'x' ]; then . $CLIDIR/ft-envrc.sh; fi # load run-time env

cd $ROOTDIR/
if [ ! -e downloads ]; then mkdir -p downloads; fi
if [ ! -e downloads/go-ipfs_${ver}_${arch}.tar.gz ]; then
  curl -L -o downloads/go-ipfs_${ver}_${arch}.tar.gz https://dist.ipfs.io/go-ipfs/${ver}/go-ipfs_${ver}_${arch}.tar.gz
fi
tar xfv downloads/go-ipfs_v0.7.0_linux-amd64.tar.gz
cd $pwd

curl -L -o $HOME/.ipfsignore https://gateway.ipfs.io/ipfs/QmUAf7KZ7NMYwajPrBG6g2VLxBmAjrnXXETMwjVbUsBmP5
rm -f $INSTALLDIR/bin/ipfs
ln -s $ROOTDIR/go-ipfs/ipfs $INSTALLDIR/bin/ipfs

fi

which ipfs >/dev/null
. $CALLINGDIR/ft-provide-status.sh

true;

