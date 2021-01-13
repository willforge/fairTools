#

if ! which ifconfig >/dev/null; then
echo "--- # ${0##*/}"
CALLINGDIR=$(dirname $0); export PATH=$PATH:$CALLINGDIR;

sh $CALLINGDIR/ft-provide-sudo.sh
sudo apt-get install net-tools

which ifconfig >/dev/null
. $CALLINGDIR/ft-provide-status.sh
fi

true;



