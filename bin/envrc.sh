#!/bin/echo source

# intent: setting ft environment
if [ "x$bindir" = 'x' ]; then
if echo "$-" | grep -q 'i'; then
cmd=$(history | tail -1 | sed -e 's/.*://' -e 's/^[^ ]*/echo/' )
zero=$(eval "$cmd" | cut -d' ' -f2);
wrapper="$(readlink -f "$zero")"
#set $zero $*
else
wrapper="$(readlink -f "$0")"
fi
bindir=$(dirname "$wrapper")

fi
rootdir=$(readlink -f "${bindir}/..")
export FAIRTOOLS_PATH=$rootdir
export PERL5LIB=${PERL5LIB:-$FAIRTOOLS_PATH/lib/perl5}
if echo "$-" | grep -q '.*i.*'; then
export PATH=${PERL5LIB%/lib/perl5}/bin:$bindir:$PATH
else
export PATH=${PERL5LIB%/lib/perl5}/bin:/usr/local/bin:/usr/bin:$bindir:/bin
fi



#if ! which ipms 1>/dev/null 2&>1; then
# alias ipms='ipfs'
#fi
if ! which ipfs 1>/dev/null 2>&1; then
 export IPFS_CONTAINER=${IPFS_CONTAINER:-ipfs-node}
 echo info: no ipfs found, use docker 1>&2
ipfs() {
 docker exec $IPFS_CONTAINER ipfs $@
}
else
 if ! ipfs id 1>/dev/null 2>&1; then
  export IPFS_CONTAINER=${IPFS_CONTAINER:-ipfs-node}
  #echo info: dockerized ipfs 1>&2
  ipfs() {
   echo docker exec ipfs-node ipfs $@ 1>&2
   docker exec $IPFS_CONTAINER ipfs $@
  }
 else
  echo info: using $(which ipfs) 1>&2
 fi
fi

