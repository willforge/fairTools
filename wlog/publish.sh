# 

set -e
rm -rf cloned
export GIT_ALLOW_PROTOCOL=keybase:file
git clone --single-branch --branch dbug --recursive ../.git cloned
cd cloned
git remote set-url --add --push origin keybase://team/distributedbrain/fairTools

cd wlog
git rev-parse HEAD
git hash-object wlog-url.sh
ipfs add -n wlog-url.sh
cd ..

cd js
git fetch origin dbug
git branch dbug
git checkout dbug
git pull origin dbug
#git branch --set-upstream-to=origin/dbug dbug
cd ..
qm=$(ipfs add -Q -r -w js wlog)
cd wlog
sh wlog-url.sh -u 

git add wlog-url.sh
gituser
git commit -m "new wlog release: $qm on $(date +%D)"
git push origin
