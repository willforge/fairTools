# install ${prefix} in either
#    ~/.local/bin
#    ~/bin
#    /usr/local/bin
#

# intent: install a git toolkit from its url 
# usage:
#  ft get https://github.com/willforge/fairTools.git
#
git_url=$1
gitrepo=${git_url##*/}
toolkit=${gitrepo%%.git}
ROOTDIR="${ROOTDIR:-$HOME/...}"
TOOLKIT_PATH=${TOOLKIT_PATH:-${ROOTDIR}/opt/${toolkit}}
echo TOOLKIT_PATH: $TOOLKIT_PATH
core=${toolkit%%Tools}
#export PATH="$PATH:$TOOLKIT/ftools" # /!\ DO NO MESS W/ PATH !

# -----------------------------------------------------
# install deps: sudo, git
if ! which sudo >/dev/null; then
  su root -c "apt-get -y update && apt-get -y install sudo"
fi
if ! which git >/dev/null; then
if ! echo | sudo -Sv 2>/dev/null; then
   cat <<EOM
   ATTENTION: $toolkit requires administrative privileges to continue setup
   On Linux and macOS please enter your current user password,
   in Ubuntu App for Windows 10 use Linux user password in this step.
   For more information, see $git_url
EOM
   sleep 1
fi

  # TODO: install ssh-askpass
  export SUDO_ASKPASS=/usr/libexec/seahorse/ssh-askpass
  sudo apt-get install -y git
fi
# -----------------------------------------------------
export GIT_ALLOW_PROTOCOL=keybase:https:ssh:file
parent=$(dirname ${TOOLKIT_PATH})
if [ ! -d $TOOLKIT_PATH ]; then
  mkdir -p $parent
  cd $parent
  git clone --branch dbug $git_url
  cd "$TOOLKIT_PATH"
  git config pull.rebase false
else
  cd "$TOOLKIT_PATH"
  git pull origin dbug
fi
cd $TOOLKIT_PATH
. ./config.sh
sh $TOOLKIT_PATH/ftools/ft-install.sh

exit $?
true
