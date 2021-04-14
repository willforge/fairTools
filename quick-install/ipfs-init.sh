#

echo "--- # ${0##*/}"

if echo -n "\e" | grep -q -e 'e'; then
 e="-e" # bash needs a -e !
fi
# colors : [see also](https://en.wikipedia.org/wiki/ANSI_escape_code)
default=$(echo -n $e "\e[39m")
red=$(echo -n $e "\e[31m")
green=$(echo -n $e "\e[1;32m")
yellow=$(echo -n $e "\e[1;33m")
cyan=$(echo -n $e "\e[2;36m")
grey=$(echo -n $e "\e[0;90m")
nc=$(echo -n $e "\e[0m")



export IPFS_CONTAINER=${IPFS_CONTAINER:-ipfs-node}
dockerip=$(docker exec $IPFS_CONTAINER ifconfig eth0 | grep inet | sed -n -e 's/inet addr:/inet /' -e 's/^ *inet \([^ ]*\).*/\1/p;')

# dockerized ipfs is _ipfs
_ipfs() {
 docker exec $IPFS_CONTAINER ipfs $@
}
IPFS_PATH=$(_ipfs repo stat | grep RepoPath: | sed -e 's/  */ /g' | cut -d' ' -f 2)

echo "IPFS_PATH: ${yellow}$IPFS_PATH${grey} on $dockerip${nc}"


peerid=$(_ipfs config Identity.PeerID) && echo "peerid: ${green}$peerid${nc}"
echo dockerip: $dockerip
echo "repo: |-"
_ipfs repo stat | sed -e 's/^/ /'
api=$(_ipfs config Addresses.API)
echo "api: $api"
gateway=$(_ipfs config Addresses.Gateway)
gw_port=$(echo $gateway | cut -d/ -f 5)
api_port=$(echo $api | cut -d/ -f 5)
swarm_port=$(_ipfs config Addresses.Swarm | grep -e /tcp | head -1 | cut -d/ -f5 | sed -e 's/".*//')
echo gw_port: ${cyan}$gw_port${nc}
echo api_port: ${cyan}$api_port${nc}
echo swarm: $swarm_port
gw_url="http://$dockerip:$gw_port"
api_url="http://$dockerip:$api_port/api/v0/"

allowed_origins="['http://$dockerip:$gw_port', 'http://$dockerip:$api_port', 'http://localhost', 'http://127.0.0.1:5001', 'http://127.0.0.1:48084', 'https://ipfs.blockringtm.ml', 'https://webui.ipfs.io']"
allowed_origins=$(echo $allowed_origins | sed -e 's,'"'"',",g')
if ! _ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin | grep -q blockringtm.ml; then
_ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin "$allowed_origins"
_ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '["PUT", "POST"]'
else
echo "Allowed-Origins: |-"
_ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin | sed -e 's/^/ /'
fi

#curl -s -D - -X POST "http://$dockerip:$api_port/api/v0/id"
if curl -s -D - -X POST "${api_url}add?file=test&pin=true&raw-leaves=true&hash=sha3-224&cid-base=base58btc" -F "file=fairTeam" | grep -q z6CfPs4KMZEFsrvodUfZTtYjMWpxAbPsdZGzv3o1wtYj; then
echo "info: POST test ${green}successful${red}; welcome to fairTeam"
else
  echo "info: POST test ${red}failed${red}"
  echo "please: |-"
  echo " reboot your IPFS node"
  echo " by running:"
  echo " ${cyan}sh ipfs-reboot.sh${nc}"
  exit 251
fi

echo "Important-Info: |-"
sed -e 's/^/ /' <<EOT
your docker ip address is ${yellow}$dockerip${nc}
your gateway is running on port $gw_port
your api_url is "${yellow}$api_url${nc}"
your webui_url is "${yellow}$gw_url${grey}/ipfs/Qmb3cY3zFJ5isjJ5H9cP47Vfqa6pqNwypbuo2TiBGjUmLd/${nc}#/welcome

please open your webui_url, and if you have a "${red}Could not connect to the IPFS API${nc}" message
enter ${green}/ip4/$dockerip/tcp/$api_port${nc} in point (3.)


our application is running at 

xdg-open ${green}http://$dockerip:$gw_port/ipns/12D3KooWJEgKKeZuawJLDu7TP5qCwmq8RSA5fkdHxREVLoavaPmt/list/node_list_create_n_rank.html${nc}

${cyan}Happy fairJourney !${nc}
EOT

echo .
