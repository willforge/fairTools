#


# intent: publish /... and /public

# deps: 
#   - keybase
#   - ipfs
#   - curl

core=fair
cachedir=$HOME/.cache/${core}Tools
if [ ! -d $cachedir ]; then
mkdir $cachedir
fi

set -e
# api_port ?
api=$(ipfs config Addresses.API)
api_port=$(echo $api | cut -d/ -f 5)
echo api: $api
gw=$(ipfs config Addresses.Gateway)
gw_port=$(echo $gw | cut -d/ -f 5)
echo gw: $gw
# webui ?
if ipfs key list | grep -q -w 'webui'; then
 webui=$(ipfs key list -l --ipns-base=b58mh | grep -w 'webui' | cut -d' ' -f1)
 echo webui_url: http://127.0.0.1:$gw_port/ipns/$webui/#
fi

# identity ...
kbuser=$(keybase status | head -1 | sed -e 's/  */ /' | cut -d' ' -f 2)
peerid=$(env IPFS_PATH=$HOME/.ipfs ipfs config Identity.PeerID)
echo kbuser: $kbuser
echo peerid: $peerid


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
   pub=$(ipfs files stat /public --hash) || pub=$emptyd
fi
echo pub: $pub

# etc ... (spot computation)
if [ "x$kbuser" != 'x' ]; then
token=$(cat /keybase/private/$kbuser/secrets/ipinfo-token.txt 2>/dev/null)
if [ "x$token" != 'x' ]; then
curl -sL https://ipinfo.io/json?token=$token | json_xs -e " \$_->{tics} = \$^T; \$_; " > $cachedir/location.json
else
curl -sL https://ipinfo.io/json | json_xs -e " \$_->{tics}=\$^T;\$_->{kbuser}='$kbuser';\$_" > $cachedir/location.json
fi
else
token=$(perl -e 'printf "%x\n",rand(72057594037927936);')
ip=$(curl -sL http://iph.heliohost.org/cgi-bin/remote_addr.pl | tail -1)
curl -sL http://ipinfo.io/$ip/json | json_xs -e " \$_->{tics}=\$^T;\$_->{token}='$token';\$_->{peerid}='$peerid';\$_->{user}='$USER';\$_" > $cachedir/location.json
fi
spot=$(ipfs add -Q $cachedir/location.json)
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
 echo $tic: $tofu >> $cachedir/ids.yml
 echo $tic: $kbid >> $cachedir/ids.yml
 echo $tic: $nid >> $cachedir/ids.yml
 echo $tic: $id >> $cachedir/ids.yml
 qm=$(ipfs add -Q $cachedir/ids.yml)
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
qm=$(ipfs object patch add-link $emptyd '...' $dot3);
qm=$(ipfs object patch add-link $qm 'my' $my);
qm=$(ipfs object patch add-link $qm 'public' $pub);
qm=$(ipfs object patch add-link $qm 'etc' $etc);
echo url: https://dweb.link/ipfs/$qm
echo url: http://localhost:8080/ipfs/$qm
echo qm: $qm
if ipfs files rm -r /.../published 2>/dev/null; then
  ipfs files cp /ipfs/$qm /.../published
  prev=$(ipfs files stat /.../published/.../published --hash)
  ipfs files rm -r /.../published/.../published;
  tic=$(date +%s)
  echo "$tic: $prev" | ipfs files write --create /.../published/prev.yml
fi
ipfs name publish /ipfs/$qm --allow-offline 1>/dev/null &



