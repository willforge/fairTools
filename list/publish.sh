#


key=$(ipfs key list -l --ipns-base=b58mh | grep -w fairList | cut -d' ' -f1)

pwd=$(pwd)
cd ../quick-install
top=$(git rev-parse --show-toplevel)
gitdir=$(git rev-parse --absolute-git-dir)
cd $top
#git remote prune origin 
#git repack && git prune-packed && git reflog expire --expire=1.month.ago
git gc --aggressive
cd $gitdir
#rm -rf refs/remotes/*

git --bare update-server-info
qmgit=$(ipfs add -Q -r $gitdir)
echo qmgit: $qmgit;
cd $pwd;



qmemptyd=$(ipfs object new unixfs-dir)
qmroot=$(ipfs add -w ../welcome.html ../style.css ../fairTeam.html ../favicon.ico -Q)
qmjs=$(ipfs add -r ../js -Q)
qmimg=$(ipfs add -r ../img -Q)
qminstall=$(ipfs add -r ../quick-install -Q)
qmlist=$(ipfs add -w node_list_create_n_rank.html node_list_create_n_rank.js style.css *.md -Q)

qm=$(ipfs object patch add-link $qmroot quick-install.git $qmgit)
qm=$(ipfs object patch add-link $qm quick-install $qminstall)
qm=$(ipfs object patch add-link $qm js $qmjs)
qm=$(ipfs object patch add-link $qm list $qmlist)
qm=$(ipfs object patch add-link $qm img $qmimg)
ipfs ls /ipfs/$qm
echo https://ipfs.blockring™.ml/ipfs/$qm
ipfs name publish --key=fairList /ipfs/$qm
echo http://127.0.0.1:8080/ipns/$key


