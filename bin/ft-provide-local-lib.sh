#

# installing Perl Modules locally 
# see [*](https://metacpan.org/pod/local::lib)

export INSTALLDIR=${INSTALLDIR:-${HOME}/.local}
export BINDIR=${BINDIR:-$INSTALLDIR/bin}

# bootstrap : get local::lib tarball from CPAN
echo "--- # ${0##*/}"
bindir="$(readlink -f "$BINDIR")"
rootdir=$(readlink -f "${bindir}/..")

LOCALLIB=${PERL5LIB:-$rootdir/lib/perl5}
echo LOCALLIB: $LOCALLIB

sh ft-provide curl

if ! perl -I$LOCALLIB -Mlocal::lib -e '1;' 2>/dev/null; then
ver=2.000024
curl https://cpan.metacpan.org/authors/id/H/HA/HAARG/local-lib-${ver}.tar.gz | tar zxf -

cwd=$(pwd)
cd local-lib-${ver}
perl Makefile.PL --bootstrap=${LOCALLIB%/lib/perl5}
make test && make install
cd $cwd
rm -rf local-lib-${ver}


fi

if ! perl -I$PERL5LIB -Mlocal::lib -e '1;'; then
unset PERL5LIB
perl -I$LOCALLIB -Mlocal::lib=${LOCALLIB%/lib/perl5} >> $(which ft-envrc.sh)
eval $(perl -I$LOCALLIB -Mlocal::lib=${LOCALLIB%/lib/perl5})
#eval $(perl -Mlocal::lib=--deactivate,~/perl5)
#perl -Mlocal::lib=--deactivate-all
echo PERL5LIB: $PERL5LIB

fi


# testing:
if perl -Mlocal::lib -e '1;'; then
  echo "local/lib: ${green}provided${nc}"
else
  echo "${red}Error: Local::lib failed to install${nc}"
fi


