# fairTools


## INSTALLATION

```sh
if ! grep -q $HOME/.local/bin $HOME/.bashrc; then
cat >> $HOME/.bashrc <<EOT
if [ -d \$HOME/.local/bin ]; then
export PATH=\$PATH:\$HOME/.local/bin
fi 
EOT
fi

curl -sL https://raw.githubusercontent.com/willforge/fairTools/master/bin/ft-init.sh | /bin/sh - 

. $HOME/.bashrc
which ft

```

In this repository you will find :

1. the [biff] line (a one bit anonymous communication line)
2. an experiment w/ [Chameleon][Cham] Hashes
3. a [Diffie & H.][Diffie] in Javascript for secret exchange
4. [IRQ] line : an essential component for a Pull Request protocol in a "pull only ecosystem"
5. [js]: the Javascript code !
6. misc.
7. [PubSub]
8. [fairNet]


repo: 
 - https://github.com/willforge/fairTools
 - [keybase://team/distributedbrain/fairTools][1]
 - http://localhost:8080/ipns/QmVgyPNWW6jK7NKgzpH1GWxF3FKm4rXw8nd4xJnwRkrbuE/fairTools.git
 - [git@localhost:distributedbrain/fairTools.git][2]




[1]: https://keybase.io/team/distributedbrain/git/fairTools
[2]: http://gitea.localhost:3000/distributedbrain/fairTools


```sh
xdg-open http://localhost:3000/distributedbrain/fairTools.git
git clone http://localhost:8080/ipns/QmVgyPNWW6jK7NKgzpH1GWxF3FKm4rXw8nd4xJnwRkrbuE/fairTools.git
git remote add gitea git@localhost:distributedbrain/fairTools.git
```
