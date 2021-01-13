#

echo "--- # ${0##*/}"
CALLINGDIR=$(dirname $0); export PATH=$PATH:$CALLINGDIR;
. $(which ft-provide-envrc.sh)

what=vaniport.pl

if true || ! which $what >/dev/null; then
sh $(which ft-provide-module.sh) Crypt::Digest
sh $(which ft-provide-module.sh) JSON
sh $(which ft-provide-module.sh) LWP::UserAgent

if [ ! -d $ROOTDIR/bin ]; then mkdir -p $ROOTDIR/bin; fi
# ipfs add -w $(locate -n 1 -b vaniport.pl)
qm=QmTwMwZBqnhmH8GMw1K8b4USKJ4uqJdbyj7mRx41s8AxKp
ping=$(curl -sL http://127.0.0.1:8080/ipfs/QmejvEPop4D7YUadeGqYWmZxHhLc4JBUCzJJHWMzdcMe2y)
if [ "?$ping" = '?ipfs' ]; then
  ipfs get -o $ROOTDIR/bin/$what $qm/vaniport.pl
else 
  curl -o $ROOTDIR/bin/$what $qm/vaniport.pl
fi
chmod a+x $ROOTDIR/bin/$what

fi


which $what >/dev/null
. $(which ft-provide-status.sh)

true
