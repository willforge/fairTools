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
 docker exec $IPFS_CONTAINER ipfs "$@"
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

# adding CORS parameters
allowed_origins="['http://$dockerip:$gw_port', 'http://$dockerip:$api_port', 'http://localhost', 'http://127.0.0.1:5001', 'http://127.0.0.1:48084', 'https://ipfs.blockringtm.ml', 'https://webui.ipfs.io']"
allowed_origins=$(echo $allowed_origins | sed -e 's,'"'"',",g')
if ! _ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin | grep -q blockringtm.ml; then
_ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin "$allowed_origins"
_ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '["PUT", "POST"]'
else
echo "Allowed-Origins: |-"
_ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin | sed -e 's/^/ /'
fi
# adding bootstraps
#  "/ip4/212.129.2.151/tcp/24001/ws/p2p/Qmd2iHMauVknbzZ7HFer7yNfStR4gLY1DSiih8kjquPzWV"
bootstraps='[
"/ip4/212.129.2.151/tcp/24001/ws/p2p/Qmd2iHMauVknbzZ7HFer7yNfStR4gLY1DSiih8kjquPzWV",
"/dnsaddr/bootstrap.libp2p.io/p2p/QmNnooDu7bfjPFoTZYxMNLWUQJyrVwtbZg5gBMjTezGAJN",
"/dnsaddr/bootstrap.libp2p.io/p2p/QmQCU2EcMqAqQPR2i9bChDtGNJchTbq5TbXJJ16u19uLTa",
"/dnsaddr/bootstrap.libp2p.io/p2p/QmbLHAnMoJPWSCR5Zhtx6BHJX9KiKNN6tpvbUcqanj75Nb",
"/dnsaddr/bootstrap.libp2p.io/p2p/QmcZf59bWwK5XFi76CZX8cbJ4BhTzzA3gU1ZjYZcYW3dwt",
"/ip4/104.131.131.82/tcp/4001/p2p/QmaCpDMGvV2BGHeYERUEnRQAwe3N8SzbUtfsmvsqQLuvuJ",
"/ip4/104.131.131.82/udp/4001/quic/p2p/QmaCpDMGvV2BGHeYERUEnRQAwe3N8SzbUtfsmvsqQLuvuJ",
"/ip4/104.236.179.241/tcp/4001/p2p/QmSoLPppuBtQSGwKDZT2M73ULpjvfd3aZ6ha4oFGL1KrGM",
"/ip4/104.236.179.241/udp/4001/quic/p2p/QmSoLPppuBtQSGwKDZT2M73ULpjvfd3aZ6ha4oFGL1KrGM",
"/ip4/128.199.219.111/tcp/4001/p2p/QmSoLSafTMBsPKadTEgaXctDQVcqN88CNLHXMkTNwMKPnu",
"/ip4/128.199.219.111/udp/4001/quic/p2p/QmSoLSafTMBsPKadTEgaXctDQVcqN88CNLHXMkTNwMKPnu",
"/ip4/104.236.76.40/tcp/4001/p2p/QmSoLV4Bbm51jM9C4gDYZQ9Cy3U6aXMJDAbzgu2fzaDs64",
"/ip4/104.236.76.40/udp/4001/quic/p2p/QmSoLV4Bbm51jM9C4gDYZQ9Cy3U6aXMJDAbzgu2fzaDs64",
"/ip4/178.62.158.247/tcp/4001/p2p/QmSoLer265NRgSp2LA3dPaeykiS1J6DifTC88f5uVQKNAd",
"/ip4/178.62.158.247/udp/4001/quic/p2p/QmSoLer265NRgSp2LA3dPaeykiS1J6DifTC88f5uVQKNAd",
"/ip6/2604:a880:1:20::203:d001/tcp/4001/p2p/QmSoLPppuBtQSGwKDZT2M73ULpjvfd3aZ6ha4oFGL1KrGM",
"/ip6/2400:6180:0:d0::151:6001/tcp/4001/p2p/QmSoLSafTMBsPKadTEgaXctDQVcqN88CNLHXMkTNwMKPnu",
"/ip6/2604:a880:800:10::4a:5001/tcp/4001/p2p/QmSoLV4Bbm51jM9C4gDYZQ9Cy3U6aXMJDAbzgu2fzaDs64",
"/ip6/2a03:b0c0:0:1010::23:1001/tcp/4001/p2p/QmSoLer265NRgSp2LA3dPaeykiS1J6DifTC88f5uVQKNAd"
]'
_ipfs config --json Bootstraps "$(echo "$bootstraps" | tr -d '\n' )"

# adding OVH peer
peers='[{"Addrs":["/ip4/212.129.2.151/tcp/24001/ws"],"ID":"Qmd2iHMauVknbzZ7HFer7yNfStR4gLY1DSiih8kjquPzWV"}]'
# ipfs dht findpeer 12D3KooWHpj1ercuLscv78Ezz4TADdwSgNkmNmd4qH8dfCCcwZHX
_ipfs config --json Peering.Peers "$peers"

#curl -s -D - -X POST "http://$dockerip:$api_port/api/v0/id"
if curl -s -D - -X POST "${api_url}add?file=test&pin=true&raw-leaves=true&hash=sha3-224&cid-base=base58btc" -F "file=fairTeam" | grep -q z6CfPs4KMZEFsrvodUfZTtYjMWpxAbPsdZGzv3o1wtYj; then
echo "info: POST test ${green}successful${nc}; welcome to fairTeam"
else
  echo "info: POST test ${red}failed${nc}"
  echo "please: |-"
  echo " reboot your IPFS node"
  echo " by running:"
  echo " ${cyan}sh ipfs-reboot.sh${nc}"
  exit 251
fi
keylist=12D3KooWJEgKKeZuawJLDu7TP5qCwmq8RSA5fkdHxREVLoavaPmt
qmlist=$(_ipfs name resolve $keylist | sed -e 's,/ipfs/,,')
echo "Important-Info: |-"
sed -e 's/^/ /' <<EOT
your docker ip address is ${yellow}$dockerip${nc}
your gateway is running on port $gw_port
your api_url is "${yellow}$api_url${nc}"
your webui_url is "${yellow}$gw_url${grey}/ipfs/Qmb3cY3zFJ5isjJ5H9cP47Vfqa6pqNwypbuo2TiBGjUmLd/${nc}#/welcome

please open your webui_urli in your browser,
and if you have a "${red}Could not connect to the IPFS API${nc}" message
enter ${green}/ip4/$dockerip/tcp/$api_port${nc} in point (3.) of the page.

our application is running at 

xdg-open ${green}http://$dockerip:$gw_port/ipns/$keylist/list/node_list_create_n_rank.html${nc}
EOT

if [ "x$qmlist" != 'x' ]; then
echo or
echo "xdg-open ${green}http://$dockerip:$gw_port/ipfs/$qmlist/list/node_list_create_n_rank.html${nc}"
fi
echo ''

echo "${cyan}Happy fairJourney !${nc}"

echo .
