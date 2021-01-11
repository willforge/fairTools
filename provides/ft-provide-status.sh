#

intent="report install status"

# colors : [see also](https://en.wikipedia.org/wiki/ANSI_escape_code)
red=$(echo -n "\e[31m")
green=$(echo -n "\e[1;32m")
nc=$(echo -n "\e[0m")

true;

fname=${0##*/}
echo "---"
rname=${fname%%.*}
what=${rname#*provide-}

if which $what >/dev/null; then
  echo "$what: ${green}provided${nc}"
  echo "... # $fname"
  return $?
else
  echo "${red}Error: $what failed to install!${nc}"
  echo "... # $fname 💣"
  return $(expr $$ % 252)
fi

true;
