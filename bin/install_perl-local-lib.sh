#

# installing Perl Modules locally 
# see [*](https://metacpan.org/pod/local::lib)

# bootstrap : get local::lib tarball from CPAN
echo "--- # $0"
wrapper="$(readlink -f "$0")"
bindir=$(dirname "$wrapper")
rootdir=$(readlink -f "${bindir}/..")

LOCALLIB=${PERL5LIB:-$rootdir/lib/perl5}

cwd=$(pwd)

if ! perl -I$LOCALLIB -Mlocal::lib=${LOCALLIB%/lib/perl5} >/dev/null ; then
ver=2.000024
if ! which curl >/dev/null; then
  ft-get curl
fi
curl https://cpan.metacpan.org/authors/id/H/HA/HAARG/local-lib-${ver}.tar.gz | tar zxf -

cd local-lib-${ver}
perl Makefile.PL --bootstrap=${LOCALLIB%/lib/perl5}
make test && make install
cd $cwd
rm -rf local-lib-${ver}
fi

eval $(perl -I$LOCALLIB -Mlocal::lib=${LOCALLIB%/lib/perl5})
#eval $(perl -Mlocal::lib=--deactivate,~/perl5)
#perl -Mlocal::lib=--deactivate-all
echo PERL5LIB: $PERL5LIB

exit $?

true;
