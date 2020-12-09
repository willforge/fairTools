# README

This folder contains some jekyll source to allow for easy translation for the web page.
To compile the html file run

- if you have docker install you can run :

```sh
docker run --rm --volume="$PWD:/srv/jekyll" \
  -it -u root:root jekyll/minimal jekyll build
```

- if you have jekyll you can run :

```sh
gnome-terminal -- jekyll build --watch
```

Results are in ``_site``

```sh
xdg-open _site/text.htm
```

