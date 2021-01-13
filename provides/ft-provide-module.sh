#

echo "--- # ${0##*/} $*"
CALLINGDIR=$(dirname $0); export PATH=$PATH:$CALLINGDIR;
mod="$1"
module=$(echo ${mod%.pm} | sed -e 's,/,::,g')
echo module: $module

. $(which ft-provide-envrc.sh)
if ! perl -M$module -e '1;'; then
export PERL_MM_USE_DEFAULT=1

sh $(which ft-provide-local-lib.sh)
echo PERL5LIB: $PERL5LIB
perl -MCPAN -Mlocal::lib=${PERL5LIB%/lib/perl5} -e "CPAN::install($module)"
echo "perl -MCPAN -Mlocal::lib=\${PERL5LIB%/lib/perl5} -e 'CPAN::install($module)'" >> $ROOTDIR/bin/installed_modules.sh


fi


perl -M$module -e '1;'
. $(which ft-provide-status.sh)
