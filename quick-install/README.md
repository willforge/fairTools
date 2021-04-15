# FairTools &amp; Electronic Median Voting System (Proof-of-concept)


``fairList's key: 12D3KooWJEgKKeZuawJLDu7TP5qCwmq8RSA5fkdHxREVLoavaPmt``

### WELCOME to the [fairTeam][3]

### INSTALL :

1. sh docker-install.sh

2. sh ipfs-install.sh

3. sh ipfs-init.sh

4. sh ipfs-reboot.sh

5. [xdg-open http://127.0.0.1:8080/ipns/list.fairnet.ml/welcome.html][1]


### RUNTIME

1. docker start ipfs-node
2. [xdg-open http://127.0.0.1:8080/ipns/list.fairnet.ml/list/node_list_create_n_rank.html][2]
3. ipfs API documentation : [http://127.0.0.01:8080/ipns/docs.ipfs.io/reference/http/api/][4]

### CLEANUP

1. docker exec ipfs-node ipfs shutdown
2. docker ps | grep ipfs-node
3. docker rm ipfs-node
4. docker image rm ipfs/go-ipfs


[1]: http://127.0.0.1:8080/ipns/list.fairNet.ml/welcome.html
[2]: http://127.0.0.1:8080/ipns/list.fairNet.ml/list/node_list_create_n_rank.html
[3]: http://127.0.0.1:8080/ipns/list.fairNet.ml/fairTeam.html
[4]: http://127.0.0.1:8080/ipns/docs.ipfs.io/reference/http/api/

