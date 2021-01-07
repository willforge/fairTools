#

core=fair
prefix=ft

# colors : [see also](https://en.wikipedia.org/wiki/ANSI_escape_code)
default=$(echo -n "\e[39m");
red=$(echo -n "\e[31m");
green=$(echo -n "\e[1;32m");
yellow=$(echo -n "\e[1;33m");
cyan=$(echo -n "\e[2;36m");
grey=$(echo -n "\e[0;90m");
nc=$(echo -n "\e[0m");

echo "--- # ${prefix}-provide-envrc.sh"

INSTALLDIR=${INSTALLDIR:-${HOME}/.local}

if [ ! -d $INSTALLDIR ]; then
  mkdir -p $INSTALLDIR;
  echo "${grey}INSTALLDIR:${nc} ${yellow}$INSTALLDIR${nc}; ${green}created${nc}"
fi

XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
cachedir=$XDG_CACHE_HOME/${core}Tools}
if [ ! -d $cachedir ]; then
mkdir -p $cachedir
fi

wrapper="$(readlink -f "$0")"
bindir=$(dirname "$wrapper")
rootdir=$(readlink -f "${bindir}/..")


# -------------------------------------------------
if ! which ${prefix}-envrc.sh >/dev/null; then
cat >> $INSTALLDIR/bin/${prefix}-envrc.sh <<EOF
# ${core}Tools ENVIRONMENT

core="$core"
wrapper="$wrapper"
bindir="$bindir"
rootdir="$rootdir"
export PATH="$PATH:$INSTALLDIR/bin"
export XDG_CACHE_HOME="$XDG_CACHE_HOME"

EOF
chmod a+x $INSTALLDIR/bin/${prefix}-envrc.sh
fi
# -------------------------------------------------
#echo "ft-envrc.sh: ${green}provided${nc}"


