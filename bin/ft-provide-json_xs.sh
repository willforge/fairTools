# 
echo "--- # ${0##*/}"

. $(which ft-provide-envrc.sh)
sh ft-provide cpan
sh ft-provide local-lib

if ! perl -MJSON::XS -e '1;'; then
perl -MCPAN -Mlocal::lib=${PERL5LIB%/lib/perl5} -e 'CPAN::install(JSON::XS)'
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
