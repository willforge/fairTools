#
echo "--- # ${0##*/}"

self="$(readlink -f "$0")"
PROVIDEDIR=$(dirname "$self"); export PATH="$PATH:$PROVIDEDIR"

if ! which perl > /dev/null; then
  sh $(which ft-provide-sudo.sh)
  sudo apt-get update
  sudo apt-get -y install perl
fi

. $(which ft-provide-status.sh)

true;
