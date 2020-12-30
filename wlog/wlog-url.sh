#

core=fair
cachedir=$HOME/.cache/${core}Tools
if [ ! -d $cachedir ]; then
mkdir $cachedir
fi

container=ipfs-node


qmrelease='QmdEAbnezmD8NcnpBouJ8cYqbdhUiB6iYoitfwfSkoiyvc'
if [ "z$qmrelease" = 'z' ]; then
qmrelease=$(ipfs add -Q -w -r ../js ../wlog )
fi
echo qmrelease: $qmrelease

dockerip=$(docker exec $container ifconfig eth0 | grep addr | sed -n -e 's/^ *inet addr:\([^ ]*\).*/\1/p;')
apiaddr=$(docker exec $container ipfs config Addresses.API)
gwaddr=$(docker exec $container ipfs config Addresses.Gateway)
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
qmcfg=$(cat $cachedir/config.js | docker exec -i $container ipfs add -Q -)
echo qmcfg: $qmcfg

qm=$(docker exec $container ipfs object patch add-link $qmrelease js/config.js $qmcfg);


echo "url: http://$dockerip:$gw_port/ipfs/$qm/wlog/wlog.html"


