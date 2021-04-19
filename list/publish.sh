#


key=$(ipfs key list -l --ipns-base=b58mh | grep -w fairList | cut -d' ' -f1)

qmemptyd=$(ipfs object new unixfs-dir)
qmroot=$(ipfs add -w ../welcome.html ../style.css ../fairTeam.html -Q)
qmjs=$(ipfs add -r ../js -Q)
qmimg=$(ipfs add -r ../img -Q)
qmlist=$(ipfs add -w node_list_create_n_rank.html node_list_create_n_rank.js style.css *.md -Q)

qm=$(ipfs object patch add-link $qmroot js $qmjs)
qm=$(ipfs object patch add-link $qm list $qmlist)
qm=$(ipfs object patch add-link $qm img $qmimg)
ipfs ls /ipfs/$qm
echo https://ipfs.blockring™.ml/ipfs/$qm
ipfs name publish --key=fairList /ipfs/$qm
echo http://127.0.0.1:8080/ipns/$key


