#

# ENVIRONMENT STRUCTURE:
# 
#  LOCALDIR=$HOME/.local
#  $LOCALDIR/bin/ft -> $ROOTDIR/.../opt/fairTools/ftools/ft

if [ "x$FAIRTOOLS_PATH" != 'x' ]; then
echo FAIRTOOLS_PATH: $FAIRTOOLS_PATH
else
what=envrc

caller="${0##*/}"
prefix=${caller%%-*}
PROVIDEDIR=$(dirname $0)


echo "--- # ${prefix}-provide-$what.sh (caller $0)"
# colors : [see also](https://en.wikipedia.org/wiki/ANSI_escape_code)
. $PROVIDEDIR/${prefix}-provide-colors.sh


cli=$(which $prefix); wrapper=$(readlink -f $cli);
CLIDIR=$(dirname $wrapper); export PATH=$PATH:$CLIDIR;
# -------------------------------------------------
if [ -e $CLIDIR/../${prefix}-config.sh ]; then
. $CLIDIR/../${prefix}-config.sh # load config file
fi

echo "source: $CLIDIR/ft-envrc.sh"
. $CLIDIR/ft-envrc.sh;

# -------------------------------------------------
echo "---"

if [ "e$ROOTDIR" != 'e' ]; then
  echo "$what: ${green}provided${nc}"
  echo "... # $prefix-provide-$what.sh"
  return $?
else
  echo "${red}Error: $what failed to load!${nc}"
  echo "... # $prefix-provide-$what.sh 💣"
  return $(expr $$ % 252)
fi

fi # load run-time env
true;

