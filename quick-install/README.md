---
title: "fairTools: Electronic Median Voting System (Proof-of-concept)"
author: Michel C.
key: 12D3KooWJEgKKeZuawJLDu7TP5qCwmq8RSA5fkdHxREVLoavaPmt
key36: k51qzi5uqu5djatwwz74xtx5zkwupmte2a2hvj0n3we7isqxhc7oaywnymc5ln
---
# FairTools Set

<code>fairList's key: [$key$][5]<code>

 git repository:

```sh
git clone https://gateway.ipfs.io/ipns/list.fairnet.ml/quick-install.git/
```

## WELCOME to the [fairTeam][3]

### PRE_REQUISITES :

1. sudo apt-get git
2. sudo apt-get curl


### ONE-LINER INSTALL 

 1. ``curl https://gateway.ipfs.io/ipns/list.fairnet.ml/quick-install/one-liner-install.sh | sh -``

this will executre the following script:

```sh
#

set -e
git clone https://$key36$.ipns.dweb.link/quick-install.git/
cd quick-install
sh docker-install.sh
sh ipfs-install.sh
sh ipfs-init.sh
sh ipfs-reboot.sh
xdg-open http://127.0.0.1:8080/ipns/list.fairnet.ml/welcome.html
exit $$?
true
```

### INSTALL :

0. README : xdg-open [https://gateway.ipfs.io/ipns/list.fairnet.ml/welcome.html][0]
1. git clone https://$key36$.ipns.dweb.link/quick-install.git/
2. cd quick-install
3. sh docker-install.sh
4. sh ipfs-install.sh
5. sh ipfs-init.sh
6. sh ipfs-reboot.sh

7. [xdg-open http://127.0.0.1:8080/ipns/list.fairnet.ml/welcome.html][1]


### RUNTIME

1. docker start ipfs-node
2. [xdg-open http://127.0.0.1:8080/ipns/list.fairnet.ml/list/node_list_create_n_rank.html][2]
3. ipfs API documentation : [http://127.0.0.01:8080/ipns/docs.ipfs.io/reference/http/api/][4]
4. Welcome : [http://127.0.0.01:8080/ipns/list.fairnet.ml/welcome.html][1]
4. FairTeam : [http://127.0.0.01:8080/ipns/list.fairnet.ml/fairTeam.html][1]

### CLEANUP

1. docker exec ipfs-node ipfs shutdown
2. docker ps | grep ipfs-node
3. docker rm ipfs-node
4. docker image rm ipfs/go-ipfs


[0]: https://gateway.ipfs.io/ipns/list.fairNet.ml/quick-install/README.html
[1]: http://list.fairNet.ml.ipns.localhost:8080/welcome.html
[2]: http://127.0.0.1:8080/ipns/list.fairNet.ml/list/node_list_create_n_rank.html
[3]: http://127.0.0.1:8080/ipns/list.fairNet.ml/fairTeam.html
[4]: http://127.0.0.1:8080/ipns/docs.ipfs.io/reference/http/api/
[5]: http://gateway.ipfs.io/ipns/$key$/

