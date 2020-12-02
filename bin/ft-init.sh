#

# bootstrap !
core=fair
pre=ft
FAIRTOOLS_PATH=${HOME}/.../opt/${core}Tools
git_url=https://github.com/willforge/${core}Tools.git

if [ ! -d $FAIRTOOLS_PATH ]; then
  parent=$(dirname ${FAIRTOOLS_PATH})
  mkdir -p $parent
  cd $parent
  git clone $git_url
fi
cd $FAIRTOOLS_PATH
sh bin/${pre}-install.sh

#https://github.com/willforge/fairTools/tags

cachedir=$HOME/.cache/${core}Tools
if [ ! -d $cachedir ]; then
  mkdir -p $cachedir
fi
cd $cachedir
