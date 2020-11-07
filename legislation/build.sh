
gnome-terminal -- \
docker run --rm --volume="$PWD:/srv/jekyll" -it jekyll/minimal \
  jekyll build --watch
