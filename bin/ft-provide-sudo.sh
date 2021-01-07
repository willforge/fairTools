
# colors : [see also](https://en.wikipedia.org/wiki/ANSI_escape_code)
default=$(echo -n "\e[39m")
red=$(echo -n "\e[31m")
green=$(echo -n "\e[1;32m")
yellow=$(echo -n "\e[1;33m")
cyan=$(echo -n "\e[2;36m")
grey=$(echo -n "\e[0;90m")
nc=$(echo -n "\e[0m")


ruid="$(id -ru)"
if ! which sudo > /dev/null; then
  uid="$(id -u)"
  if [ "e$uid" != 'e0' ]; then
     yellow=$(echo -n "\e[1;33m")
     nc=$(echo -n "\e[0m")
     echo "${yellow}you need to run this ${0##*/} script with root priviledge${nc}"
     echo "su root -c 'sh $0'"
     exit 251
  fi  
  apt-get update
  apt-get -y install sudo
  if which sudo > /dev/null; then
   echo "sudo: ${green}provided${nc}"
  else
   echo "${red}Error: sudo failed to install!${nc}"
  fi
  
fi


