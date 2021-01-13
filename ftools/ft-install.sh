# 

intent="install a soft link ft in the bin directory"

fname="${0##*/}"
prefix=${fname%%-*}
self=$(readlink -f "$0")
CALLINGDIR=$(dirname $self);
FAIRTOOLS_PATH=${FAIRTOOLS_PATH:-$(readlink -m "$CALLINGDIR/..")}
PROVIDEDIR=$FAIRTOOLS_PATH/provides
# export PATH=$PATH:$CALLINGDIR; # DO NOT put CALLINGDIR befor INSTALLDIR

# deps:
# - readlink,sudo

# install ${cli} in either
#    ~/.local/bin
#    ~/bin
#    /usr/local/bin
#
if [ "e$INSTALLDIR" = 'e' ]; then
if [ -d $HOME/.local/bin ]; then
  INSTALLDIR=$HOME/.local
else
  if [ -e $HOME/bin ]; then
  INSTALLDIR=$HOME
  else
   if echo $PATH | sed -e 's/:/\n/g' | grep -q -e '/usr/local/bin'; then
     INSTALLDIR=/usr/local
   else
     INSTALLDIR=$HOME/.local
     mkdir -p $INSTALLDIR/bin
     echo "${grey}INSTALLDIR:${nc} ${yellow}$INSTALLDIR${nc}; ${green}created${nc}"
   fi
  fi
fi
export INSTALLDIR;
fi
echo INSTALLDIR: $INSTALLDIR

cli=$prefix
#install -p -m 0755 ft $INSTALLDIR
if [ -w $INSTALLDIR/bin ]; then
 rm -f $INSTALLDIR/bin/$cli
 echo ln -s $CALLINGDIR/$cli $INSTALLDIR/bin/$cli
 ln -s $CALLINGDIR/$cli $INSTALLDIR/bin/$cli
else
 sh $PROVIDEDIR/${prefix}-provide.sudo.sh
 #install -p -m 0755 ft /usr/local/bin
 sudo rm -f $INSTALLDIR/bin/$cli
 echo sudo ln -s $CALLINGDIR/$cli $INSTALLDIR/bin/$cli
 sudo ln -s $CALLINGDIR/$cli $INSTALLDIR/bin/$cli
fi 

## update path if necessary 
if ! echo $PATH | sed -e 's/:/\n/g' | grep -q -e $INSTALLDIR/bin; then
  cat >> $HOME/.profile <<EOT
 
  # setup for $cli (${core}Tools) modified on $(date +%D) by $0
  export PATH=$PATH:$INSTALLDIR/bin 

EOT
fi

exit $?;
