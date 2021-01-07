#

green=$(echo -n "\e[1;32m");
red=$(echo -n "\e[31m");
nc=$(echo -n "\e[0m");

echo "--- # ${0##*/}"

if ! which perl > /dev/null; then
sudo apt-get install perl
fi

if ! perl -MCPAN -e '1;'; then
sudo apt-get install cpanminus
fi

# testing
if perl -MCPAN -e '1;'; then
 echo "CPAN: ${green}provided${nc}"
else
 echo "${red}ERROR${nc}: CPAN failed"
 exit 251
fi

true;
