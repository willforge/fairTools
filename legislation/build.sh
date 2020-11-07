
gnome-terminal -- \
docker run --rm --volume="$PWD:/srv/jekyll" -u root:root -it jekyll/minimal \
  jekyll build --watch
