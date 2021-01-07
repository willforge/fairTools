#
echo "--- # ${0##*/}"

. $(which ft-provide-envrc.sh)
if ! which curl >/dev/null; then
sudo apt-get curl
fi


if ! which curl >/dev/null; then
  echo "${red}Error: ft-provide curl failed!${nc}"
  exit 251
else
  echo "curl: ${green}provided${nc}"
fi

true;
