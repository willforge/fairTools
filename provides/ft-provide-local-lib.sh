#

# installing Perl Modules locally 
# see [*](https://metacpan.org/pod/local::lib)

# bootstrap : get local::lib tarball from CPAN
fname=${0##*/}
echo "--- # ${fname}"
prefix=${fname%%-*}; cli=$(which $prefix); wrapper=$(readlink -f $cli);
CLIDIR=$(dirname $wrapper); export PATH=$PATH:$CLIDIR;
if [ "x$FAIRTOOLS_PATH" = 'x' ]; then . $CLIDIR/ft-envrc.sh; fi # load run-time env

LOCALLIB=${PERL5LIB:-$FAIRTOOL_PATH/lib/perl5}
echo LOCALLIB: $LOCALLIB

sh $(which ft-provide-perl.sh)
if ! perl -I$LOCALLIB -Mlocal::lib -e '1;' 2>/dev/null; then
ver=2.000024
sh $(which ft-provide-curl.sh)
curl https://cpan.metacpan.org/authors/id/H/HA/HAARG/local-lib-${ver}.tar.gz | tar zxf -

cwd=$(pwd)
cd local-lib-${ver}
perl Makefile.PL --bootstrap=${LOCALLIB%/lib/perl5}

sh $(which ft-provide-make.sh)
make test && make install
cd $cwd
rm -rf local-lib-${ver}

fi

PERL5LIB=${PERL5LIB:-/usr/local/lib/perl5}
if ! perl -I$PERL5LIB -Mlocal::lib -e '1;'; then
export PERL5LIB=${LOCALLIB}
export PERL_LOCAL_LIB_ROOT=${LOCALLIB%/lib/perl5}
envf=$(which ft-envrc.sh)
echo "export PERL5LIB=${PERL5LIB}" >> $envf;
perl -I$LOCALLIB -Mlocal::lib=${PERL_LOCAL_LIB_ROOT} >> $envf

eval $(perl -I$LOCALLIB -Mlocal::lib=${PERL_LOCAL_LIB_ROOT})
#eval $(perl -Mlocal::lib=--deactivate,~/perl5)
#eval $(perl -I$LOCALLIB -Mlocal::lib)
#perl -Mlocal::lib=--deactivate-all

fi
echo PERL5LIB: $PERL5LIB

nc=$(echo -n "\e[0m")
# testing:
if perl -I$PERL5LIB -Mlocal::lib -e '1;'; then
  green=$(echo -n "\e[32m")
  echo "local/lib: ${green}provided${nc}"
else
  red=$(echo -n "\e[31m")
  echo "${red}Error: Local::lib failed to install${nc}"
fi


