# fairTools runtime ENVIRONMENT

core="${core:-fair}"
fname="${0##*/}"
prefix=${fname%%-*}
echo "--- # ${prefix}-envrc.sh (caller $0)"

export XDG_CACHE_HOME="$HOME/.cache"

FTCONFIG=$LOCALDIR/${core}Tools/${prefix}-config.sh

if [ "x$FAIRTOOLS_PATH" = 'x' ]; then

cli=$(which ${prefix})
root_cli=$(readlink $cli)
wrapper=$(readlink -f $cli)

echo "cli: $cli"
echo "root_cli: $root_cli"
echo "wrapper: $wrapper"

CLIDIR=$(dirname "$wrapper")
echo "CLIDIR: $CLIDIR"
LOCALDIR=$(readlink -m $CLIDIR/..)

INSTALLDIR=${cli%%/bin/*}
ROOTDIR="${root_cli%%/opt/*}"

# calling script
self=$(readlink -f $0)
CALLINGDIR=$(dirname $self)

# fairTools ENVIRONMENT
#export FAIRTOOLS_PATH=${FAIRTOOLS_PATH:-$ROOTDIR/opt/${core}Tools}
FAIRTOOLS_PATH=$(readlink -m "${CALLINGDIR}/..")

echo "ROOTDIR/bin: $ROOTDIR/bin"
echo "LOCALDIR/bin: $LOCALDIR/bin"
echo "FAIRTOOLS_PATH/bin: $FAIRTOOLS_PATH/bin"
echo "CALLINGDIR: $CALLINGDIR"

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
PATH="$PATH:$INSTALLDIR/bin" # for install only
PATH="$PATH:$ROOTDIR/bin:$LOCALDIR/bin:$FAIRTOOLS_PATH/bin:$CALLINGDIR"
export PATH;

fi

export PERL5LIB=$ROOTDIR/lib/perl5
PERL_MB_OPT="--install_base \"$ROOTDIR\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=$ROOTDIR"; export PERL_MM_OPT;

export IPFS_CONTAINER=ipfs-node

# --- all edits below this line are subject to be erased !
