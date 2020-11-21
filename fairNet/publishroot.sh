#


# intent: publish ... and public

# deps: 
#   - keybase
#   - ipfs
#   - curl

core=fair
cachedir=$HOME/.cache/${core}Tools
if [ ! -d $cachedir ]; then
mkdir $cachedir
fi


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

# my ...
peerid=$(env IPFS_PATH=$HOME/.ipfs ipfs config Identity.PeerID)
kbuser=$(keybase status | head -1 | sed -e 's/  */ /' | cut -d' ' -f 2)
echo kbuser: $kbuser
if ipfs files stat /my/identity/ids.yml --hash 1>/dev/null 2>&1; then
 qm=$(ipfs files stat /my/identity/ids.yml --hash)
else
 #keybase status -j > $cachedir/kb.json
 nid=$(echo "urn:/ipns/$peerid" | ipfs add -Q --hash sha3-224 --cid-base base58btc)
 kbid=$(echo "uri:keybase:$kbuser" | ipfs add -Q --hash sha3-224 --cid-base base58btc)
 id=$(echo "uri:nickname:$USER" | ipfs add -Q --hash sha3-224 --cid-base base58btc)
 echo "# identity logs $(date +%Y.%m.%d.%H.%M.%S)" > $cachedir/ids.yml
 echo $tic: $kbid >> $cachedir/ids.yml
 echo $tic: $nid >> $cachedir/ids.yml
 echo $tic: $id >> $cachedir/ids.yml
 qm=$(ipfs add -Q $cachedir/ids.yml)
 ipfs files cp /ipfs/$qm /my/identity/ids.yml
fi
echo ids: $qm
qm=$(ipfs object patch add-link $emptyd 'ids.yml' $qm);
qm=$(ipfs object patch add-link $emptyd 'identity' $qm);
my=$(ipfs object patch add-link $emptyd 'my' $qm);
echo my: $my


# etc ...
tic=$(date +%s)
token=$(cat /keybase/private/$kbuser/secrets/ipinfo-token.txt 2>/dev/null) ||\
token=$(perl -e 'printf "%x\n",rand(72057594037927936);')
#ip=$(curl -s http://iph.heliohost.org/cgi-bin/remote_addr.pl | head -1)
curl -sL https://ipinfo.io/json?token=$token | json_xs -e " \$_->{tics} = $tic; \$_; " > $cachedir/location.json
spot=$(ipfs add -Q $cachedir/location.json)
echo spot: $spot
etc=$(ipfs object patch add-link $emptyd 'spot.json' $spot);
echo etc: $etc


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
ipfs name publish /ipfs/$qm --allow-offline 1>dev/null &



