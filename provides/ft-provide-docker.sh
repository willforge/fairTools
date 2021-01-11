#

echo "--- # ${0##*/}"
if [ "x$FAIRTOOLS_PATH" = 'x' ]; then . $(which ft-envrc.sh); fi # load run-time env

red=$(echo -n "\e[31m")
green=$(echo -n "\e[1;32m")
nc=$(echo -n "\e[0m")


if cat /proc/self/cgroup | grep -q -e '/docker/'; then
  echo "docker: ${green}already within a container !${nc}"
  exit 0
fi


if ! which docker > /dev/null; then
sh $(which ft-provide-sudo.sh)
  # uninstall old
  sudo apt-get remove docker docker-engine docker.io containerd runc 2>/dev/null
  # install prerequisites
  sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
  # add GPG key
  curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
  sudo apt-key fingerprint 9DC858229FC7DD38854AE2D88D81803C0EBFCD88
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
  sudo apt-get update
  # install docker
  sudo apt-get install docker-ce docker-ce-cli containerd.io

  if sudo docker run --rm hello-world | grep -q "working correctly."; then
    echo "docker: ${green}provided${nc}"
  else
    echo "${red}ERROR: docker failed to install!${nc}"
    exit 251
  fi

fi

if ! id -nG | grep -q -w docker; then
sudo groupadd docker
sudo usermod -aG docker $USER
fi

