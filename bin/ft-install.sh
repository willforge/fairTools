# 

pgm=ft
self=$(readlink -f "$0")
bindir=$(dirname "$self")

if [ -d $HOME/.local/bin ]; then
 #install -p -m 0755 ft $HOME/.local/bin;
 rm -f $HOME/.local/bin/$pgm
 ln -s $bindir/$pgm $HOME/.local/bin/$pgm
 symlinks -csor ~/.local/bin/ | grep -w changed | sed -e 's/changed/installed/'
else
 #install -p -m 0755 ft /usr/local/bin
 sudo rm -f /usr/local/bin/$pgm
 sudo ln -s $bindir/$pgm /usr/local/bin/$pgm
 symlinks -tsor /usr/local/bin/
fi
