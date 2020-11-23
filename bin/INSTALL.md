# INSTALLATION


1. docker (debian install)

```sh
# uninstall old
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo apt-key fingerprint 9DC858229FC7DD38854AE2D88D81803C0EBFCD88
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
sudo groupadd docker
sudo usermod -aG docker $USER
docker run --rm hello-world
```


2. dockerized ipfs


```sh
docker pull ipfs/go-ipfs

```

3.


