# 


qm=$(echo -n 'fairTeam' | ipfs add -Q --raw-leaves --hash sha3-224 --cid-base base58btc)
echo "ping: $qm"
echo "provs: |-"
ipfs dht findprovs "/ipfs/$qm" | sed -e 's/^/  /'

true;
