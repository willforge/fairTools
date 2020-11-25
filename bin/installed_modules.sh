#

wrapper="$(readlink -f "$0")"
bindir=$(dirname "$wrapper")
rootdir=$(readlink -f "${bindir}/..")
export PERL5LIB=${PERL5LIB:-$rootdir/lib/perl5}

