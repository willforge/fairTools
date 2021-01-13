# 

if ! which screen >/dev/null; then
echo "--- # ${0##*/}"
CALLINGDIR=$(dirname $0); export PATH=$PATH:$CALLINGDIR;

. $(which ft-provide-colors.sh)
. $(which ft-provide-envrc.sh)


  sh $(which ft-provide-sudo.sh)
  sudo apt-get install -y screen

which screen > /dev/null
. $(which ft-provide-status.sh)
exit $?
fi

true;
