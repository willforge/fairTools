#

echo "--- # ${0##*/}"
bindir=$(dirname $0); export PATH=$PATH:$bindir;

if ! which git >/dev/null; then
  sh $(which ft-provide-sudo.sh)
  sudo apt-get install -y git
fi

. $(which ft-provide-status.sh)

exit $?

true;

