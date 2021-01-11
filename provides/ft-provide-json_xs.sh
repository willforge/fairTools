# 
fname=${0##*/}
echo "--- # ${fname}"
prefix=${fname%%-*}; cli=$(which $prefix); wrapper=$(readlink -f $cli);
CLIDIR=$(dirname $wrapper); export PATH=$PATH:$CLIDIR;
if [ "x$FAIRTOOLS_PATH" = 'x' ]; then . $CLIDIR/ft-envrc.sh; fi # load run-time env

. $(which ft-provide-colors.sh)

if ! perl -MJSON::XS -e '1;'; then
if ! perl -MCPAN -e '1;'; then
  sh $(which ft-provide-cpan.sh)
fi
sh $(which ft-provide-local-lib.sh)
export PERL_MM_USE_DEFAULT=1
perl -MCPAN -Mlocal::lib=${PERL5LIB%/lib/perl5} -e 'CPAN::install(JSON::XS)'
# yes | perl -MCPAN -Mlocal::lib=${PERL5LIB%/lib/perl5} -e 'CPAN::install(JSON::XS)'
fi

if perl -MJSON::XS -e '1;'; then
  echo JSON/XS: ${green}provided${nc}
else
  echo "${red}Error: JSON::XS install failed!${nc}"
fi

if ! echo '{"json":true}' | json_xs >/dev/null; then
  echo "${red}Error: json_xs failed!${nc}"
fi

exit $?

true;
