#

intent="provide colors"

# colors : [see also](https://en.wikipedia.org/wiki/ANSI_escape_code)
default=$(echo -n "\e[39m")
red=$(echo -n "\e[31m")
green=$(echo -n "\e[1;32m")
yellow=$(echo -n "\e[1;33m")
cyan=$(echo -n "\e[2;36m")
grey=$(echo -n "\e[0;90m")
nc=$(echo -n "\e[0m")


if echo "$0" | grep -q -e 'colors'; then
echo "we have ${red}c${green}o${yellow}l${cyan}o${grey}r${nc}s"
fi

true;
