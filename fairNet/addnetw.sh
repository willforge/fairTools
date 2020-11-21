#

netw="$1"
tics=$(date +%s)
regf=/.../registries/networks.log
# Location name service:
lns=$(echo -n "LNS" | ipfs add -Q - --hash sha3-224 --cid-base base58btc)
echo "lns: $lns"
qm=$(sed -e "s/network: .*/network: $netw/" charter.txt | ipfs add -Q - --hash sha3-224 --raw-leaves --cid-base base58btc)
echo qm: $qm
record="$tics $qm /public/networks/$netw"
ipfs-log append $regf "$record"
# publish registry file
qm=$(ipfs files stat $regf --hash)
ipfs-log append '/.../staged.idx' "$tics $qm $regf"

webkey=$(ipfs key list -l --ipns-base=b58mh | grep -w webui | cut -d' ' -f 1)
echo url: http://localhost:8080/ipns/$webkey/
qm=$(ipfs files stat '/...' --hash)
ipfs name publish /ipfs/$qm --allow-offline


# TODO turn network into a folder
