#

intent="install sudo"
help_url="https://duckduckgo.com/?q=ft-provide+fairTools"

echo "--- # ${0##*/}"
bindir=$(dirname $0); export PATH=$PATH:$bindir;

# colors : [see also](https://en.wikipedia.org/wiki/ANSI_escape_code)
. $(which ft-provide-colors.sh)

ruid="$(id -ru)"
if ! which sudo > /dev/null; then
  uid="$(id -u)"
  if [ "e$uid" != 'e0' ]; then
     echo "${yellow}you need to run this ${0##*/} script with root priviledges${nc}"
     su root -c "apt-get -y update"
     su root -c "apt-get -y install sudo"
  else
     apt-get -y update
     apt-get -y install sudo
  fi
fi
if which sudo > /dev/null; then
  if expr $(stat -c %X $0) + 86400 '*' 3 '<' $(date +%s)  >/dev/null ; then
    if ! echo | sudo -Sv 2>/dev/null; then
      cat <<EOM
      ATTENTION: ${0##*/} requires administrative privileges to
      continue this setup;
      * on Linux and macOS
        please enter your current user password,
      * within Ubuntu App for Windows 10
        use Linux user password for this step.
      For more information, see $help_url
EOM
      sleep 1
    fi
    sudo apt-get update
    touch -a $0
  fi
  echo "sudo: ${green}provided${nc}"
else
  echo "${red}Error: sudo failed to install!${nc}"
fi

exit $?

true;
