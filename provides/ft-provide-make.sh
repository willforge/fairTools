#

echo "--- # ${0##*/}"
self=$(readlink -f "$0")
export PROVIDEDIR=$(dirname "$self"); export PATH=$PATH:$PROVIDEDIR;

if ! which make > /dev/null; then
  sh $(which ft-provide-sudo.sh)
  sudo apt-get -y install build-essential
fi

. $(which ft-provide-status.sh)

true;


