#

# make: docker perl json_xs uniq.pl

core=fair
cachedir=$HOME/.cache/${core}Tools
if [ ! -d $cachedir ]; then
mkdir $cachedir
fi

if [ "o$1" = 'o-u' ]; then
 shift;
 update=1
else
 update=0
fi

# ----------------------------------------------
# by default Perl's modules are in ../lib/perl5
wrapper="$(readlink -f "$0")"
bindir=$(dirname "$wrapper")
rootdir=$(readlink -f "${bindir}/..")
#PERL5LIB=${PERL5LIB:-/usr/local/perl5/lib/perl5}
export PERL5LIB=${PERL5LIB:-$rootdir/lib/perl5}
export PATH=$PATH:../bin:${PERL5LIB%/lib/perl5}/bin
# ----------------------------------------------


IPFS_CONTAINER=${IPFS_CONTAINER:-ipfs-node}

if ! docker ps | grep -q -w $IPFS_CONTAINER; then
 echo -n 'IPFS_CONTAINER: '
 docker start $IPFS_CONTAINER
 sleep 10
 docker logs --since 59s $IPFS_CONTAINER
fi

qmrelease='QmUgVa3YA5UZHtwAm8u7Gxtk7cfGggPsPgLv5nntEJ7Nkb'
if [ "$update" -eq 1 -o "z$qmrelease" = 'z' ]; then
docker cp ../js $IPFS_CONTAINER:/export
docker exec -i $IPFS_CONTAINER rm -f /export/js/config.js
docker cp ../wlog $IPFS_CONTAINER:/export
qmrelease=$(docker exec -i $IPFS_CONTAINER ipfs add -Q -w -r /export/js /export/wlog )
docker exec -i $IPFS_CONTAINER rm -rf /export/js
docker exec -i $IPFS_CONTAINER rm -rf /export/wlog
sed -i -e "s/^qmrelease='.*'/qmrelease='$qmrelease'/" $0
fi
echo qmrelease: $qmrelease

dockerip=$(docker exec $IPFS_CONTAINER ifconfig eth0 | grep addr | sed -n -e 's/^ *inet addr:\([^ ]*\).*/\1/p;')
apiaddr=$(docker exec $IPFS_CONTAINER ipfs config Addresses.API)
gwaddr=$(docker exec $IPFS_CONTAINER ipfs config Addresses.Gateway)
api_port=$(echo $apiaddr | cut -d/ -f5)
gw_port=$(echo $gwaddr | cut -d/ -f5)

echo dockerip: $dockerip
echo apiaddr: $apiaddr
echo gwaddr: $gwaddr
echo api_port: $api_port
echo gw_port: $gw_port

cat > $cachedir/config.js <<EOF
window.config = {
 'gw_url': "http://${dockerip}:${gw_port}",
 'api_url': "http://${dockerip}:${api_port}/api/v0/"
};
EOF
qmcfg=$(cat $cachedir/config.js | docker exec -i $IPFS_CONTAINER ipfs add -Q -)
echo qmcfg: $qmcfg

qm=$(docker exec $IPFS_CONTAINER ipfs object patch add-link $qmrelease js/config.js $qmcfg);

# ---------------------------------------
# update (append) config for origins
if ! which uniq.pl > /dev/null; then
  qmbin=QmaYUY6WVY4SRB3HNmd2Uu56N6sbwMec53rpSNRBYb6bKe
  curl -o ../bin/uniq.pl "http://${dockerip}:${gw_port}/ipfs/$qmbin/uniq.pl"
  chmod a+x ../bin/uniq.pl
fi
if ! which json_xs > /dev/null; then
  sh ../bin/add-perl-modules.sh JSON::XS
fi

docker exec -i $IPFS_CONTAINER ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin | \
json_xs -t yaml > $cachedir/origin.yml
cat > $cachedir/default.yml <<EOT
- http://127.0.0.1:8080
- http://127.0.0.1:5001
- http://127.0.0.113:8080
- http://127.0.0.113:5001

- http://172.17.0.2:8396
- http://172.17.0.2:5001

- http://localhost
- http://localhost:3000
- http://localhost:4000
- http://localhost:8080
- https://webui.ipfs.io
EOT
json=$(cat $cachedir/origin.yml $cachedir/default.yml | \
perl -S uniq.pl | json_xs -f yaml -t json)

docker exec -i $IPFS_CONTAINER ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin "$json"

# ---------------------------------------
# restart docker to consider the new config

echo -n 'IPFS_CONTAINER: '
if docker ps | grep -q -w $IPFS_CONTAINER; then
 docker restart $IPFS_CONTAINER;
else
 docker start $IPFS_CONTAINER;
fi
# ---------------------------------------

echo "url: http://$dockerip:$gw_port/ipfs/$qm/wlog/wlog.html"

exit $?;

true # $Source: /my/shell/script/wlog-url.sh $
