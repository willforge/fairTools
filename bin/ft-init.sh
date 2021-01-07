# 

intent="install a soft link ft in the bin directory"

# deps:
# - readlink

pgm=ft
self=$(readlink -f "$0")
bindir=$(dirname "$self")

if [ -d $HOME/.local/bin ]; then
 #install -p -m 0755 ft $HOME/.local/bin;
 rm -f $HOME/.local/bin/$pgm
 echo ln -s $bindir/$pgm $HOME/.local/bin/$pgm
 ln -s $bindir/$pgm $HOME/.local/bin/$pgm
else
  if [ -e $HOME/bin ]; then
   #install -p -m 0755 ft $HOME/bin;
   rm -f $HOME/bin/$pgm
   echo ln -s $bindir/$pgm $HOME/bin/$pgm
   ln -s $bindir/$pgm $HOME/bin/$pgm
  else
   #install -p -m 0755 ft /usr/local/bin
   sudo rm -f /usr/local/bin/$pgm
   echo sudo ln -s $bindir/$pgm /usr/local/bin/$pgm
   sudo ln -s $bindir/$pgm /usr/local/bin/$pgm
  fi
fi

