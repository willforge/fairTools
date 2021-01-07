#

wrapper="$(readlink -f "$0")"
bindir=$(dirname "$wrapper")
rootdir=$(readlink -f "${bindir}/..")

export PATH="$PATH:$bindir"

sh  $(which ft-provide) sudo

if ! which perl > /dev/null; then
  sudo apt-get update
  sudo apt-get -y install perl
fi

if ! which perl > /dev/null; then
red=$(echo -n "\e[31m");
nc=$(echo -n "\e[0m");
echo "${red}Error: perl failed to install!${nc}"
exit 251
fi

exit $?;

true;
