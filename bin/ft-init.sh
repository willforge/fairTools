#

# bootstrap !
core=fair
pre=ft
FAIRTOOLS_PATH=${HOME}/.../opt/${core}Tools
git_url=https://github.com/willforge/${core}Tools.git

parent=$(dirname ${FAIRTOOLS_PATH})
if [ ! -d $FAIRTOOLS_PATH ]; then
  mkdir -p $parent
  cd $parent
  git clone $git_url
else
  cd $parent
  git pull
fi
cd $FAIRTOOLS_PATH
sh bin/${pre}-install.sh

#https://github.com/willforge/fairTools/tags

cachedir=$HOME/.cache/${core}Tools
if [ ! -d $cachedir ]; then
  mkdir -p $cachedir
fi


exit $?

true
