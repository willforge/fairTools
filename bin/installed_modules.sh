#

wrapper="$(readlink -f "$0")"
bindir=$(dirname "$wrapper")
rootdir=$(readlink -f "${bindir}/..")
export PERL5LIB=${PERL5LIB:-$rootdir/lib/perl5}

perl -MCPAN -Mlocal::lib=${PERL5LIB%/lib/perl5} -e 'CPAN::install(YAML::Syck)'
perl -MCPAN -Mlocal::lib=${PERL5LIB%/lib/perl5} -e 'CPAN::install(JSON::XS)'
perl -MCPAN -Mlocal::lib=${PERL5LIB%/lib/perl5} -e 'CPAN::install(Encode::Base58::BigInt)'
perl -MCPAN -Mlocal::lib=${PERL5LIB%/lib/perl5} -e 'CPAN::install(MIME::Base32)'
perl -MCPAN -Mlocal::lib=${PERL5LIB%/lib/perl5} -e 'CPAN::install(Math::Base36)'
perl -MCPAN -Mlocal::lib=${PERL5LIB%/lib/perl5} -e 'CPAN::install(Crypt::Digest)'
perl -MCPAN -Mlocal::lib=${PERL5LIB%/lib/perl5} -e 'CPAN::install(Text::QRCode)'
