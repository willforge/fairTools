#!/bin/echo source

# intent: setting ft environment

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

