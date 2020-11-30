#


# intent: publish /... and /public

# deps: 
#   - keybase
#   - perl5lib (json_xw)
#   - ipfs
#   - curl
#provide_keybase
#provide_perl5lib
#...
#provide_ipfs
#provide_curl
#

core=fair
cachedir=$HOME/.cache/${core}Tools
if [ ! -d $cachedir ]; then
  mkdir $cachedir
fi

bindir=$(dirname "$(readlink -f "$0")")
rootdir=$(readlink -f "${bindir}/..")
export PERL5LIB=${PERL5LIB:-$rootdir/lib/perl5}
export PATH=${PERL5LIB%/lib/perl5}/bin:$PATH

export IPFS_PATH=${IPFS_PATH:-$HOME/.ipfs}
export IPFS_IMAGE=${IPFS_IMAGE:-ipfs/go-ipfs}
export IPFS_CONTAINER=${IPFS_CONTAINER:-ipfs-node}


# dockerized ipfs:
export IPFS_PATH=${IPFS_PATH:-$HOME/.ipfs}
export IPFS_STAGING=${IPFS_STAGING:-$IPFS_PATH/staging}
echo IPFS_PATH: $IPFS_PATH
if ! which ipfs 2>/dev/null; then
ipfs() {
  docker exec -i $IPFS_CONTAINER ipfs "$@"
}
fi

set -e
# api_port ?
api=$(ipfs config Addresses.API)
api_port=$(echo $api | cut -d/ -f 5)
echo api: $api
gw=$(ipfs config Addresses.Gateway)
gw_port=$(echo $gw | cut -d/ -f 5)
echo gw: $gw
origin=$(ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin | json_xs -e '$_ = $_->[0]' | sed -e 's/"//g')
echo origin: $origin

# webui ?
if ipfs key list | grep -q -w 'webui'; then
 webui=$(ipfs key list -l --ipns-base=b58mh | grep -w 'webui' | cut -d' ' -f1)
else
 webui=QmY5irRjuwhhFvkY88ScnM7ow3DxvbhEi13mDAsUUVHRN4
fi
echo webui_url: $origin/ipns/$webui/#

# creation of minimal root :
if ! ipfs files stat --hash /... >/dev/null 2>&1; then
 ipfs files mkdir /...
fi

# identity ...
kbuser=$(keybase status | head -1 | sed -e 's/  */ /' | cut -d' ' -f 2)
if which ipfs 1>/dev/null 2>&1; then
peerid=$(env IPFS_PATH=$HOME/.ipfs ipfs config Identity.PeerID)
else
peerid=$(ipfs config Identity.PeerID)
fi
echo kbuser: $kbuser
echo peerid: $peerid

nodeid=$(ipfs config Identity.PeerID)
echo nodeid: $nodeid


# pub ...
emptyd=$(ipfs object new -- unixfs-dir)
if ipfs files stat /.../staged --hash 2>/dev/null ; then
   prev=$(ipfs files stat /.../published --hash)
   prev=${prev:-$emptyd}
   ipfs files rm /.../staged/_prev
   ipfs files cp /ipfs/$prev /.../staged/_prev
   ipfs files rm /.../published
   ipfs files mv /.../staged /.../published
   pub=$(ipfs files stat /.../publihed --hash);
else
   if ipfs files stat /public --hash 2>/dev/null; then
     pub=$(ipfs files stat /public --hash)
   else 
    pub=$emptyd
   fi
fi
echo pub: $pub

# etc ... (spot computation)
if [ "x$kbuser" != 'x' ]; then
  # 50,000 API requests per month
  if [ -e /keybase/private/$kbuser/secrets/ipinfo-token.txt ]; then
    token=$(cat /keybase/private/$kbuser/secrets/ipinfo-token.txt)
    curl -sL https://ipinfo.io/json?token=$token | json_xs -e " \$_->{tics} = \$^T;; " > $cachedir/location.json
  else
    curl -sL https://ipinfo.io/json | json_xs -e "delete \$_->{readme}; \$_->{tics}=\$^T;\$_->{kbuser}='$kbuser';" > $cachedir/location.json
  fi
else
token=$(perl -e 'printf "%x\n",rand(72057594037927936);')
ip=$(curl -sL http://iph.heliohost.org/cgi-bin/remote_addr.pl | tail -1)
curl -sL http://ipinfo.io/$ip/json | json_xs -e "delete \$_->{readme}; \$_->{tics}=\$^T;\$_->{token}='$token';\$_->{peerid}='$peerid';\$_->{user}='$USER'" > $cachedir/location.json
fi
spot=$(cat $cachedir/location.json | ipfs add -Q -)
echo spot: $spot
etc=$(ipfs object patch add-link $emptyd 'spot.json' $spot);
echo etc: $etc


# my ...
if ipfs files stat /my/identity/ids.yml --hash 1>/dev/null 2>&1; then
 qm=$(ipfs files stat /my/identity/ids.yml --hash)
else
 if ! ipfs files stat /my/identity --hash 1>/dev/null 2>&1; then
    ipfs files mkdir -p /my/identity
 fi
 tic=$(date +%s)
 #keybase status -j > $cachedir/kb.json
 tofu=$(echo "urn:tofu:$spot" | ipfs add -Q --hash sha3-224 --cid-base base58btc)
 nid=$(echo "urn:/ipns/$peerid" | ipfs add -Q --hash sha3-224 --cid-base base58btc)
 kbid=$(echo "uri:keybase:$kbuser" | ipfs add -Q --hash sha3-224 --cid-base base58btc)
 id=$(echo "uri:nickname:$USER" | ipfs add -Q --hash sha3-224 --cid-base base58btc)
 echo "# identity logs $(date +%Y.%m.%d.%H.%M.%S)" > $cachedir/ids.yml
 echo $tic: $nodeid >> $cachedir/ids.yml # peerid of docker's node
 echo $tic: $tofu >> $cachedir/ids.yml
 echo $tic: $kbid >> $cachedir/ids.yml
 echo $tic: $nid >> $cachedir/ids.yml
 echo $tic: $id >> $cachedir/ids.yml
 qm=$(cat $cachedir/ids.yml | ipfs add -Q - )
 ipfs files cp /ipfs/$qm /my/identity/ids.yml
fi
echo ids: $qm
qm=$(ipfs object patch add-link $emptyd 'ids.yml' $qm);
my=$(ipfs object patch add-link $emptyd 'identity' $qm);
root=$(ipfs object patch add-link $emptyd 'my' $qm);
echo my: $my



if ipfs files stat /etc/spot.json --hash 1>/dev/null 2>&1; then
ipfs files rm /etc/spot.json
else
if ipfs files mkdir -p /etc; then true; fi
fi
ipfs files cp /ipfs/$spot /etc/spot.json


dot3=$(ipfs files stat /... --hash);
echo dot3: $dot3
echo "publish : /...,/my,/public,/etc"
qm=$(ipfs object patch add-link $emptyd '...' $dot3);
qm=$(ipfs object patch add-link $qm 'my' $my);
qm=$(ipfs object patch add-link $qm 'public' $pub);
qm=$(ipfs object patch add-link $qm 'etc' $etc);
echo url: https://dweb.link/ipfs/$qm
echo url: $origin/ipfs/$qm
ipfs name publish /ipfs/$qm --allow-offline 1>/dev/null &
echo qm: $qm
# backup previous ...
if ipfs files rm -r /.../published 2>/dev/null; then
  ipfs files cp /ipfs/$qm /.../published
  prev=$(ipfs files stat /.../published/.../published --hash)
  echo "prev: $prev"
  ipfs files rm -r /.../published/.../published;
  tic=$(date +%s)
  #echo "$tic: $prev" > $IPFS_STAGING/prev.yml;
  #docker exec ipfs-node ls -l /export
  #ipfs files write --create /.../published/prev.yml /export/prev.yml
  echo "$tic: $prev" | ipfs files write --create /.../published/prev.yml
  echo "url: $origin/ipfs/$(ipfs files stat --hash /.../published)"
fi



