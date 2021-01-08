# 

set -e
cwd=$(pwd)
cloned=/tmp/fairtools-dist
origin=$(git rev-parse --git-dir)
origin=${origin:-../.git}
echo origin: $origin
rm -rf $cloned
export GIT_ALLOW_PROTOCOL=keybase:file
git clone --single-branch --branch dbug --recursive $origin $cloned
cd $cloned
git remote set-url --add --push origin keybase://team/distributedbrain/fairTools
git remote add willforge git@willforge.github.com:willforge/fairjs.git

cd wlog
git rev-parse HEAD
git hash-object wlog-url.sh
ipfs add -n wlog-url.sh
cd ..

if [ false ]; then
cd js
git fetch origin dbug
git branch dbug
git checkout dbug
git pull origin dbug
#git branch --set-upstream-to=origin/dbug dbug
cd ..
fi

qm=$(ipfs add -Q -r -w js wlog)
# the release must not have a config file ..
qm=$(ipfs object patch rm-link $qm js/config.js)
echo qm: $qm
cd wlog
sh wlog-url.sh -l -u 

git add wlog-url.sh
gituser
git commit -m "new wlog release: $qm on $(date +%D)"
git push origin

cd $cwd
rm -rf $cloned

