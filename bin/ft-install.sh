#

# bootstrap !
core=fair
pre=ft
FAIRTOOLS_PATH=${FAIRTOOLS_PATH:-${HOME}/.../opt/${core}Tools}

git_url=https://github.com/willforge/${core}Tools.git

# install deps: sudo, git
if ! which sudo >/dev/null; then
  su root -c "apt-get -y install sudo"
fi
if ! echo | sudo -Sv ; then
   cat <<EOM
   ATTENTION: ft-install.sh requires administrative privileges to continue setup
   On Linux and macOS please enter your current user password,
   in Ubuntu App for Windows 10 use Linux user password in this step.
   For more information, see $git_url
EOM
   sleep 1
fi

if ! which git >/dev/null; then
  apt-get install -y git
fi


export GIT_ALLOW_PROTOCOL=keybase:https:ssh:file
parent=$(dirname ${FAIRTOOLS_PATH})
if [ ! -d $FAIRTOOLS_PATH ]; then
  mkdir -p $parent
  cd $parent
  git clone --recursive $git_url
else
  cd "$FAIRTOOLS_PATH"
  git pull
fi
cd $FAIRTOOLS_PATH
sh bin/${pre}-init.sh

#https://github.com/willforge/fairTools/tags

XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
cachedir=$XDG_CACHE_HOME/${core}Tools
if [ ! -d $cachedir ]; then
  mkdir -p $cachedir
fi

exit $?

true
