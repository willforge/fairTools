#

netw="$1"
tic=$(date +%s)
regf=/.../registries/networks.log
# Location name service:
lns=$(echo -n "Location Name Service" | ipfs add -Q - --hash sha3-224 --cid-base base58btc)
echo "lns: $lns"
qm=$(sed -e "s/network: .*/network: $netw/" charter.html | ipfs add -Q - --hash sha3-224 --raw-leaves --cid-base base58btc)
echo qm: $qm
record="$tic $qm /public/networks/$netw"
ipfs-log append $regf "$record"

# stage registry file
qm=$(ipfs files stat $regf --hash)
ipfs-log append '/.../staged.idx' "$tic $qm $regf"

webkey=$(ipfs key list -l --ipns-base=b58mh | grep -w webui | cut -d' ' -f 1)
echo url: http://localhost:8080/ipns/$webkey/

if false; then # publish
qm=$(ipfs files stat '/...' --hash)
ipfs name publish /ipfs/$qm --allow-offline
fi


# TODO turn network into a folder
