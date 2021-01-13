status=$?;

intent="report install status"

# colors : [see also](https://en.wikipedia.org/wiki/ANSI_escape_code)
red=$(echo -n "\e[31m")
green=$(echo -n "\e[1;32m")
nc=$(echo -n "\e[0m")

fname=${0##*/}
prefix=${fname%%-*}
echo "---"
rname=${fname%%.*}
what=${rname#*provide-}

if [ $status -eq 0 ]; then
  echo "$what: ${green}ok${nc}"
  echo "... # $fname"
else
if which $what >/dev/null; then
  echo "$what: ${green}provided${nc}"
  echo "... # $prefix-provide-$what.sh"
else
  echo "${red}Error: $what failed to install!${nc}"
  status=$(expr $$ % 252)
  echo "... # $prefix-provide-$what.sh 💣"
fi
fi
return $status
true;
