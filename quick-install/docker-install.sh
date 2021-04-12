#

echo "--- # ${0##*/}"

if echo -n "\e" | grep -q -e 'e'; then
 e="-e" # bash needs a -e !
fi

red=$(echo -n $e "\e[31m")
green=$(echo -n $e "\e[1;32m")
nc=$(echo -n $e "\e[0m")


if ! which sudo > /dev/null; then
  apt-get update
  apt-get -y install sudo 
fi

if ! which lsb-releace > /dev/null; then
  sudo apt-get install lsb-release
fi

linux=$(lsb_release -i | cut -d: -f 2)
echo linux: $linux


if ! which docker > /dev/null; then
  # uninstall old
  sudo apt-get remove docker docker-engine docker.io containerd runc 2>/dev/null
  sudo apt-get update
  if [ "x$linux" == 'xDebian' ]; then
  # install prerequisites
  sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
  # add GPG key
  curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
  sudo apt-key fingerprint 9DC858229FC7DD38854AE2D88D81803C0EBFCD88
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
  fi
  if [ "x$linux" != 'xUbuntu' ]; then
    sudo apt-get install apt-transport-https ca-certificates curl gnupg
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

  echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  fi
  # install docker
  sudo apt-get update
  sudo apt-get install docker-ce docker-ce-cli containerd.io

  service docker start
  

  if sudo docker run --rm hello-world | grep -q "working correctly."; then
    echo "docker: ${green}provided${nc}"
  else
    echo "${red}ERROR: docker failed to install!${nc}"
    exit 251
  fi

  if ! id -nG | grep -q -w docker; then
    sudo groupadd docker
    sudo usermod -aG docker $USER
  fi

fi
