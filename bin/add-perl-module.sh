#


# intent: 
#  adding a perl module to local libraries ...

wrapper="$(readlink -f "$0")"
bindir=$(dirname "$wrapper")
rootdir=$(readlink -f "${bindir}/..")


echo "--- # $0"
echo rootdir: $rootdir
module="$1"
mod=$(echo ${module%.pm} | sed -e 's,/,::,g')
echo mod: $mod
export PERL5LIB=${PERL5LIB:-$rootdir/lib/perl5}

echo PERL5LIB: $PERL5LIB

# check if local::lib is installed ...
if ! perl -I$PERL5LIB -Mlocal::lib=${PERL5LIB%/lib/perl5} 1>/dev/null; then
echo "Error: no local::lib"
sh $rootdir/bin/install_perl-local-lib.sh
fi

perl -MCPAN -Mlocal::lib=${PERL5LIB%/lib/perl5} -e "CPAN::install($mod)"


echo "perl -MCPAN -Mlocal::lib=\${PERL5LIB%/lib/perl5} -e 'CPAN::install($mod)'" >> $rootdir/bin/installed_modules.sh
