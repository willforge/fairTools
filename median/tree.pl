#!/usr/bin/perl -w

# intent:
#  create a set of number (size <= zmax) and compute the median

use YAML::Syck qw(Dump);

my $seed;
our $dbug = 0;
my $count = 30; # iterations: count down to 0
my $zmax = 36; # set max size
my $period = 59; # save tree every {period}sec.
while (@ARGV && $ARGV[0] =~ m/^-/)
{
  $_ = shift;
  #/^-(l|r|i|s)(\d+)/ && (eval "\$$1 = \$2", next);
  if (/^-v(?:erbose)?/) { $verbose= 1; }
  elsif (/^--?d(?:e?bug)?/) { $dbug= 1; }
  elsif (/^--?c(?:o?u?nt)?=?([\-\w]*)/) { $count= $1 ? $1 : shift; }
  elsif (/^--?s(?:eed)?=?([\w]*)/) { $seed= $1 ? $1 : shift; }
  elsif (/^--?zm(?:ax)?=?([\w]*)/) { $zmax= $1 ? $1 : shift; }
  elsif (/^--?per(?:iod)?=?([\w]*)/) { $period= $1 ? $1 : shift; }
  elsif (/^-y(?:ml)?/) { $yml= 1; }
  elsif (/^--?h(?:elp)?/) { $help= 1; }
  else                  { die "Unrecognized switch: $_\n"; }

}
#understand variable=value on the command line...
eval "\$$1='$2'"while exists$ARGV[0] && $ARGV[0] =~ /^(\w+)=(.*)/ && shift;

if ($help) {
 printf "usage:\n perl $0 --dbug --cnt=30 --zm 36 --seed=54321\n";
 exit $?;
}
my $tree;

my $iv; # Initialization Vector
if ($seed) {
   $iv = srand($seed);
} else {
   $iv = srand();
}
printf "iv: %s\n",$iv;

printf "count: %s\n",$count;
while ($count--) {
   print '-'x76,"\n";
   printf " RUN: $count <--- \n";
   print '-'x36,"\n";


   my $arity = 2;
   our $zrs = 3 + int (rand($zmax - 3)) + (rand(1.0)>0.5? 0 : 1); #  size of random set 
   our $nm = $zrs; # number of node considered (sampled set)
   
   printf "zmax: %s\n",$zmax;
   printf "zrs: %s\n",$zrs;
   printf "nm: %s\n",$nm;


   my $u = 0;
   my $id = 0;
   $tree = { id => 'god' };
   our @values = ();
   # create (value) set :
   for $i (0 .. $zrs-1) {
      my $val = int (rand($zrs/2)) + 1; # 1 .. zrs
         push @values,$val;
   }
   printf "main.values: %s\n",join',',map { sprintf '%2d',$_; } @values;
   my @rank = ();
   my @sorted_idx = sort { $values[$a] <=> $values[$b] } (0 .. $nm-1);
   foreach my $i (@sorted_idx) { 
      $rank[$sorted_idx[$i]] = $i;
   }
# --------------------------------------------------------------
# build tree ...
   for $i (0 .. $nm-1) {
      my $id = 'n'.$i;
      my $val = $values[$i];
      my $node = { # new node ...
         val => $val, id => $id, n => 0, median => 0, addr => 0, level => 0,
         sum => 0, d_order => 0, u_order => 0, r_order => $rank[$i],
         children => [], medians => [], parents => []};
      $tree = &insert($node,$tree);
      # ----------------------------
      printf "-> node-%s: %d (m=%.2f n=%d @%f) inserted\n",$node->{id},$node->{val},$tree->{median},$tree->{n},&frac_addr($node->{addr},$node->{level});
      printf "parents-%s: [%s]\n",$node->{id},join',',map { $_->{id} } @{$node->{parents}};
      my $median = &verif($tree);
      printf "tree median: %.2f <----- \n",$tree->{median};
      if ($median != $tree->{median}) {
         &display($tree);
         printf "iv: %s\n",$iv;
         printf "ERROR: computed median: %.2f\n",$median;
         die "error: wrong median";
      }
      # -------------------------------------
     print ".\n";
   }
   # display tree every {period} sec.
   if (time() % $period == 0) {
      print "display:\n";
      &display($tree);
      sleep (1);
   }

} # while count--

print "display last tree:\n";
&display($tree);

if (0) {
   printf "tree: %s...\n",Dump($tree);
   # tree traversal
   print "DFS:\n";
   &DFS_traversal($tree);
   print "BFS:\n";
   &BFS_traversal($tree);

}

exit $?;
# --------------------------------------------------------------
# verif...
sub verif {
  my $root = shift;
  my $first = &find_min($root);
  my @sorted_nodes = &climb_up($first);
  my $n = scalar(@sorted_nodes);
  printf "verif.n: %s\n",$n;
  my @sorted_idx = sort { $values[$a] <=> $values[$b] } (0 .. $n-1);
  # printf "values: %s\n",join',',map { sprintf '%s',$_; } @values;
  printf "       %s\n",join',',map { sprintf '%2d',$_; } (0 .. $n-1);
  printf "set:   %s\n",join',',map { sprintf '%2s',$_; } @values[0 .. $n-1];
  printf "soidx: %s\n",join',',map { sprintf '%2d',$_; } @sorted_idx;
  printf "nodes: %s\n",join',',map { sprintf '%2s',substr($_->{id},1) } @sorted_nodes;
  printf "values:%s\n",join',',map { sprintf '%2s',$_->{val} } @sorted_nodes;
  printf "list:  %s\n",join',',map { sprintf '%2d',$_ } sort { $a <=> $b } @values[0 .. $n-1];
  printf "       %s^\n",' 'x(3*int(($i+1)/2) + (($i+1)%2) - 1);

  my $nmin = $sorted_nodes[0];
  my $nmax = $sorted_nodes[$n-1];
  my $cmin = $values[$sorted_idx[0]];
  my $cmax = $values[$sorted_idx[$n-1]];
  printf "min: %s:%d (%d*)\n",$nmin->{id},$nmin->{val},$cmin;
  printf "max: %s:%d (%d*)\n",$nmax->{id},$nmax->{val},$cmax;
  warn sprintf"min: %s:%d != %d",$nmin->{id},$nmin->{val},$cmin if $nmin->{val} != $cmin;
  warn sprintf"max: %s:%d != %d",$nmax->{id},$nmax->{val},$cmax if $nmax->{val} != $cmax;
  
  my $mm = int(($n-1)/2);
  my $mp = int(($n)/2);
  my $medianm = $sorted_nodes[$mm];
  my $medianp = $sorted_nodes[$mp];

  my $cmedm = $values[$sorted_idx[$mm]];
  my $cmedp = $values[$sorted_idx[$mp]];
  printf "m-: %s=%s (%d*)\n",$medianm->{id},$medianm->{val},$cmedm;
  printf "m+: %s=%s (%d*)\n",$medianp->{id},$medianp->{val},$cmedp;
  warn sprintf "Warn: m-: %s:%s != %d\n",$medianm->{id},$medianm->{val},$cmedm if $medianm->{val} != $cmedm;
  warn sprintf "warn: m+: %s:%s != %d\n",$medianp->{id},$medianp->{val},$cmedp if $medianp->{val} != $cmedp;

  return ($cmedm + $cmedp)/2;
}

# --------------------------------------------------------------
sub insert {
   my $node = shift;
   printf "\n// insert-node: %s:%d\n",$node->{id},$node->{val};
   my $tree = shift;
   my $root = $tree;
   if (! exists $root->{children}) { # empty tree
      $node->{n} = 1;
      $node->{medians} = [$node,$node];
      $node->{median} = $node->{val};
      $node->{parents} = [];
      return $node;
   }
   # start search at root :
   my $pos = $root;
   my $spot = undef; # place where node is to be inserted;
   my $medianm = $root->{medians}[0];
   my $medianp = $root->{medians}[1];

   while (! $spot) {
      my $comp = &compare($node,$pos);
      printf "comp: %s <=> %s = %s\n",$node->{id},$pos->{id},$comp;
      if ($comp > 0) {
         if (! exists $pos->{children}[1]) {
            ; # attach node to tree (right branch);
            $pos->{children}[1] = $node;
            $node->{level} = $pos->{level}+1;
            $node->{addr} = &get_addr($pos->{addr},1);
            $spot = $pos;
         } else { # no spot available at this level : go down the right branch
            $pos = $pos->{children}[1];
         }
         $node->{u_order} = $pos->{u_order} + 1;
      } elsif($comp < 0) { # left insert 
         if (! (exists $pos->{children}[0] && defined $pos->{children}[0]) ) {
            ; # attach node to tree (left branch)
            $pos->{children}[0] = $node; 
            $node->{level} = $pos->{level}+1;
            $node->{addr} = &get_addr($pos->{addr},0);
            $spot = $pos;
         } else { # no spot available at this level : go down the left branch
            $pos = $pos->{children}[0];
         }
         $node->{d_order} = $pos->{d_order} +1;
      } else { # comp = 0
          if (0 && $pos->{id} eq $medianm->{id}) {
            if (! exists $pos->{children}[1]) { # right branch prefered ...
               $pos->{children}[1] = $node;
               $node->{level} = $pos->{level}+1;
               $node->{addr} = &get_addr($pos->{addr},1);
               $comp0 = $comp = 1; # considering comp > 0
               printf "node inserted on the right side of m-:%s comp=%d\n",$pos->{id},$comp;
               $spot = $pos;
            } elsif (! ( exists $pos->{children}[0] && defined $pos->{children}[0]) ) {
               $pos->{children}[0] = $node;
               $node->{level} = $pos->{level}+1;
               $node->{addr} = &get_addr($pos->{addr},0);
               $comp0 = $comp = -1; # considering comp < 0
               printf "node inserted on the left side of m-:%s comp=%d\n",$pos->{id},$comp;
               $spot = $pos;
            } else {
               my $dir = rand(1.0) > 0.5 ? 1 : 0;
               printf "RANDOM bifurcation: %s !\n",($dir)?'right':'left';
               printf "continue down the %s branch of %s\n",(($dir)?'right':'left'),$pos->{id};
               $comp = ($dir)?1:-1;
               printf "set: comp = %d\n",$comp;
               $pos = $pos->{children}[$dir];
            }
          } elsif (0 && $pos->{id} eq $medianp->{id}) {
            if (! ( exists $pos->{children}[0] && defined $pos->{children}[0]) ) { # left branch prefered ...
               $pos->{children}[0] = $node;
               $node->{level} = $pos->{level}+1;
               $node->{addr} = &get_addr($pos->{addr},0);
               $comp1 = $comp = -1; # considering comp < 0
               printf "node inserted on the left side of m+:%s comp=%d\n",$pos->{id},$comp;
               $spot = $pos;
            } elsif (! exists $pos->{children}[1]) {
               $pos->{children}[1] = $node;
               $node->{level} = $pos->{level}+1;
               $node->{addr} = &get_addr($pos->{addr},1);
               $comp1 = $comp = 1; # considering comp > 0
               printf "node inserted on the right side of m+:%s comp=%d\n",$pos->{id},$comp;
               $spot = $pos;
            } else {
               my $dir = rand(1.0) > 0.5 ? 1 : 0;
               printf "RANDOM bifurcation: %s !\n",($dir)?'right':'left';
               printf "continue down the %s branch of %s\n",(($dir)?'right':'left'),$pos->{id};
               $comp = ($dir)?1:-1;
               printf "set: comp = %d\n",$comp;
               $pos = $pos->{children}[$dir];
            }
          } elsif (0 && rand(1.0) > 0.5) {
            if (! exists $pos->{children}[1]) { # right branch prefered ...
               $pos->{children}[1] = $node;
               $node->{level} = $pos->{level}+1;
               $node->{addr} = &get_addr($pos->{addr},1);
               $comp = 1; # considering comp > 0
               printf "node inserted on the right side of %s comp=%d\n",$pos->{id},$comp;
               $spot = $pos;
            } elsif (! (exists $pos->{children}[0] && defined $pos->{children}[0]) ) {
               $pos->{children}[0] = $node;
               $comp = -1; # considering comp < 0
               $node->{level} = $pos->{level}+1;
               $node->{addr} = &get_addr($pos->{addr},0);
               printf "node inserted on the left side of %s comp=%d\n",$pos->{id},$comp;
               $spot = $pos;
            } else {
               my $dir = rand(1.0) > 0.5 ? 1 : 0; # /!\ hack for test
               printf "RANDOM bifurcation: %s !\n",($dir)?'right':'left';
               printf "continue down the %s branch of %s\n",(($dir)?'right':'left'),$pos->{id};
               $comp = ($dir)?1:-1;
               printf "set: comp = %d\n",$comp;
               $pos = $pos->{children}[$dir];
            }
         } else {
            if (! (exists $pos->{children}[0] && defined $pos->{children}[0]) ) { # left branch prefered ...
               ; # attach node to tree (left branch)
               $pos->{children}[0] = $node; 
               $node->{level} = $pos->{level}+1;
               $node->{addr} = &get_addr($pos->{addr},0);
               $comp = -1; # considering new node smaller than pos
               $spot = $pos;
               printf "node inserted on the left side of %s:%d comp=%d\n",$spot->{id},$spot->{val},$comp;
            } elsif (! exists $pos->{children}[1]) {
               ; # attach node to tree (right branch)
               $pos->{children}[1] = $node; 
               $node->{level} = $pos->{level}+1;
               $node->{addr} = &get_addr($pos->{addr},1);
               $comp = 1; # considering new node bigger than pos
               $spot = $pos;
               printf "node inserted on the right side of %s:%d comp=%d\n",$spot->{id},$spot->{val}, $comp;
            } else { # no spot available at this level : go down the any branch
               my $dir = rand(1.0) > 0.5 ? 1 : 0; # /!\ hack for test
               printf "RANDOM bifurcation: %s !\n",($dir)?'right':'left';
               printf "continue down the %s branch of %s\n",(($dir)?'right':'left'),$pos->{id};
               $comp = ($dir)?1:-1;
               $pos = $pos->{children}[$dir];
            }
         }
      }
   } # while
   if ($spot) {
      $node->{parents} = [@{$spot->{parents}},$spot]; # update parents list ...
      printf "%s's parents: %s\n",$node->{id},join',',map { $_->{id}; } @{$node->{parents}};
   }
   # update n
   $node->{n} = 1;
   do { $_->{n} = $_->{n} + 1 } for @{$node->{parents}};

   # compate node w/ medians
   my $comp0 = &compare($node,$medianm);
   my $comp1 = &compare($node,$medianp);
   printf "median-comp0: %s <=> %s:%d = %s\n",$node->{id},$medianm->{id},$medianm->{val},$comp0;
   printf "median-comp1: %s <=> %s:%d = %s\n",$node->{id},$medianp->{id},$medianp->{val},$comp1;
   if (0) {
      # check w/ spot 
      if ($comp0 == 0) {
         my $comps = &compare($spot,$medianm);
         print "comps: $comps\n";
         $comp0 = ($comps < 0) ? -1 : ($comps > 0) ? +1 : 0;
      }
      if ($comp1 == 0) {
         my $comps = &compare($spot,$medianp);
         print "comps: $comps\n";
         $comp1 = ($comps < 0) ? -1 : ($comps > 0) ? +1 : 0;
      }
   }

   ; # update medians
   if ($comp1 > 0) {
      printf "update(m+ < node) : %s:%d >= %s:%d\n",$node->{id},$node->{val},$medianp->{id},$medianp->{val};
      if ($medianm->{id} ne $medianp->{id}) { # 2 medians : was even so now it's odd
         if ($root->{n} % 2 == 0) {
           print "error: n is even w/ one median /!\\\n",
         } else {
           print "odd : one median \n";
         }
         # ??
         $root->{medians}[0] = $medianp; # insertion was on the right side !
         printf "update-medianm: %s:%d\n",$root->{medians}[0]->{id},$root->{medians}[0]->{val};
      } else { # even
         if ($root->{n} % 2) {
           print "error: n is odd w/ two median /!\\\n",
         } else {
           print "even : two medians \n";
         }
         $root->{medians}[0] = $medianp;
         $root->{medians}[1] = &find_next($medianp);
         printf "update-medianm: %s:%d\n",$root->{medians}[0]->{id},$root->{medians}[0]->{val};
         printf "update-medianp: %s:%d\n",$root->{medians}[1]->{id},$root->{medians}[1]->{val};
      }
   } elsif ($comp0 < 0) {
      printf "update(node < m-) : %s:%d >= %s:%d\n",$node->{id},$node->{val},$medianm->{id},$medianm->{val};
      if ($medianm->{id} ne $medianp->{id}) { # odd
         if ($root->{n} % 2 == 0) {
           print "error: n is even w/ one median /!\\\n",
         } else {
           print "odd : one median\n";
         }
         $root->{medians}[1] = $medianm;
         printf "update-medianp: %s:%d\n",$root->{medians}[1]->{id},$root->{medians}[1]->{val};
         #$root->{median} = $medianm->{val};
         #printf "update-median: %.2f\n",$root->{median};
      } else { # even
         if ($root->{n} % 2) {
           print "error: n is odd w/ two median /!\\\n",
         } else {
           print "even : two medians\n";
         }
         $root->{medians}[1] = $medianm;
         $root->{medians}[0] = &find_prev($medianm);
         printf "update-medianm: %s:%d\n",$root->{medians}[0]->{id},$root->{medians}[0]->{val};
         printf "update-medianp: %s:%d\n",$root->{medians}[1]->{id},$root->{medians}[1]->{val};
      }
   } elsif (0 < $comp0 && $comp1 < 0) {
     printf "update(m- < node < m+) : %s:%d < %s:%d < %s:%d \n",$medianm->{id}, $medianm->{val}, $spot->{id},$spot->{val},$medianp->{id},$medianp->{val};
      if ($root->{n} % 2 == 0) {
        die "error: n is even an val in between /!\\",
      }
      $root->{medians}[1] = $node;
      $root->{medians}[0] = $node;
      printf "update-medianm: %s:%d\n",$root->{medians}[0]->{id},$root->{medians}[0]->{val};
      printf "update-medianp: %s:%d\n",$root->{medians}[1]->{id},$root->{medians}[1]->{val};

   } elsif ($comp0 == 0) {
     die "ERROR: comp0 == 0";
     printf "update(m- == node) : %s:%d == %s:%d \n", $node->{id},$node->{val},$medianm->{id},$medianm->{val};
      if ($medianp->{id} eq $medianm->{id}) { # is even now : need 2 medians
        # node was inserted in below m+ which is also below m-
        $root->{medians}[1] = $medianm;
        $root->{medians}[0] = $node;
      } else {
        # node was insered in between
         $root->{medians}[1] = $node;
         $root->{medians}[0] = $node;
      } 
      printf "update-medianm: %s:%d\n",$root->{medians}[0]->{id},$root->{medians}[0]->{val};
      printf "update-medianp: %s:%d\n",$root->{medians}[1]->{id},$root->{medians}[1]->{val};
   } elsif ($comp1 == 0) {
     die "ERROR: comp1 == 0";
     printf "update(node == m+) : %s:%d == %s:%d \n", $node->{id},$node->{val},$medianp->{id},$medianp->{val};
      if ($medianp->{id} eq $medianm->{id}) { # is even now : need 2 medians
        # node was inserted in above m- which is also above m+
        $root->{medians}[0] = $medianp;
        $root->{medians}[1] = $node;
      } else { # is odd now : need one medians
        # node was insered in between
        $root->{medians}[0] = $node;
        $root->{medians}[1] = $node;
      }
      printf "update-medianm: %s:%d\n",$root->{medians}[0]->{id},$root->{medians}[0]->{val};
      printf "update-medianp: %s:%d\n",$root->{medians}[1]->{id},$root->{medians}[1]->{val};
   } else {
     die "ERROR !";
   }
   $root->{median} = ($root->{medians}[1]->{val} + $root->{medians}[0]->{val})/2;
   printf "update-median: %.2f\n",$root->{median};

   printf "root->{n}: %d\n",$root->{n};
   ; # computes node's metrics
   $node->{sum} = $spot->{sum} + $node->{val};
   return $root;
}

sub get_addr {
  my $parent_addr = shift;
  my $dir = shift;
  my $addr = $parent_addr << 1 | $dir;
  return $addr;
}
sub frac_addr {
  my $addr = shift;
  my $level = shift;
  return ($addr + 0.5) / (2.0**$level);
}
# --------------------------------------------------------------
sub climb_up {
  my $first = shift;
  #printf "climb_up: from %s\n",$first->{id};
  my @nodes = ();
  my $pos = $first;
  while (1) { 
     push @nodes, $pos;
     $pos = &find_next($pos);
     last unless $pos->{id};
  }
  return @nodes;
}
# --------------------------------------------------------------
sub find_min {
  my $pos = shift;
  my $min = $pos;
  while (1) {
     $pos = &find_prev($pos);
     last unless defined $pos->{id};
     $min = $pos;
     #printf "find_min: min: %s:%s (updated)\n",$min->{id},$min->{val};
  }
  return $min;
}
# --------------------------------------------------------------
sub find_next {
  my $pos = shift;
  #printf "--- # %s: %s...\n",$pos->{id},Dump($parents);
  # all nodes in right subtree are bigger
  # next == smaller (redest) of bigger "right (blue)" branch ...
  # or first parent who has a "left (red) edge"
  my $next = { id => undef };
  if (exists $pos->{children}[1]) { # next is in blue branch
    $next = $pos->{children}[1];
    while (exists $next->{children}[0]) { # if a red branch exists
      $next = $next->{children}[0];
    }
  } else { # next is in a parent subtree
     if (! exists $pos->{parents}) { 
        return $next;
     } 
     my $parents = $pos->{parents};
     if ($dbug) {
        printf "find_next.pos: %s\n",$pos->{id};
        printf "find_next.parents: [%s]\n",join',',map { $_->{id} } @{$parents};
     }

     my $parent = $pos;
     foreach $gdparent (reverse @{$parents}) {
        if (exists $gdparent->{children} && defined $gdparent->{children}[0]) {
           if ($gdparent->{children}[0]->{id} eq $parent->{id}) {
              $next = $gdparent; last;
           }
        }
        $parent = $gdparent;
     }
  }
  if ($dbug) {
     if (defined $next->{id}) {
        printf "next-to: %s:%d is %s:%d\n",$pos->{id},$pos->{val},$next->{id},$next->{val};
     } else {
        printf "no-next-to: %s:%d (undef)\n",$pos->{id},$pos->{val};
     }
  }
  return $next;
}
# --------------------------------------------------------------
sub find_prev {
  my $pos = shift;
  #printf "find_prev.pos: %s\n",$pos->{id};

  my $prev = { id => undef };
  # lookup in the children tree
  if (exists $pos->{children}[0] && defined $pos->{children}[0]) { # prev is in red branch
     $prev = $pos->{children}[0];
     while (exists $prev->{children}[1]) { # if blue children then descend blue side;
        $prev = $prev->{children}[1];
     }
  } else { # prev is in parent subtree
     if (! exists $pos->{parents}) {
        return $prev;
     }
     my $parents = $pos->{parents};
     if ($dbug) {
        if (scalar(@{$parents})) {
           printf "find_prev.parents: [%s]\n",join',',map { $_->{id}; } @{$parents};
        } else {
           printf "find_prev.parents: [] (%s no parents)\n",$pos->{id};
        }
     }
     $parent = $pos;
     foreach $gdparent (reverse @{$parents}) {
        if (exists $gdparent->{children}[1] && $gdparent->{children}[1]->{id} eq $parent->{id}) { # go up until blue
           #printf "gdparent: %s:%d (is blue)\n",$gdparent->{id},$gdparent->{val};
           $prev = $gdparent; last;
        } else {
           #printf "gdparent: %s:%d (is red)\n",$gdparent->{id},$gdparent->{val};
        }
        $parent = $gdparent;
     }
  }
  if ($dbug) {
     if (defined $prev->{id}) {
        printf "prev-to: %s:%d is %s:%d\n",$pos->{id},$pos->{val},$prev->{id},$prev->{val};
     } else {
        printf "no-prev-to: %s:%d (undef)\n",$pos->{id},$pos->{val};
     }
  }
  return $prev;
}
# --------------------------------------------------------------
sub BFS_traversal { # breadth-first-search: using a queue
  my @queue = ();
  my %discovered = ();
  my $root = shift;
  push @queue,$root;
  while (@queue) {
    my $node = shift @queue;
    if (! $discovered{$node->{id}}++) {
       &display_node('breath-first',$node);
       push @queue, grep { defined $_ } @{$node->{children}} if (@{$node->{children}});
    }
  }
}
# --------------------------------------------------------------
sub DFS_traversal { # depth-first-search: using a stack
  my @stack = ();
  my %discovered = ();
  my $root = shift;
  push @stack,$root;
  while (@stack) {
    my $node = pop @stack;
    if (! $discovered{$node->{id}}++) {
       &display_node('right-first',$node);
       push @stack, grep { defined $_ } @{$node->{children}} if (@{$node->{children}});
    }
  }
}
# --------------------------------------------------------------
sub display_node {
 my $label = shift;
 my $node = shift;
 printf "%s: %s @%.f val=%s\n",$label, $node->{id},&frac_addr($node->{addr},$node->{level}),$node->{val};
}
# --------------------------------------------------------------
sub display {
  my $root = shift;
  local *F; open F,'>','tree.dot';

  printf F "# i: %s\n",join',', map { sprintf '%2d',$_ } (0 .. $nm-1);
  my $s = 3 * int(($nm)/2) + 1 * ($nm%2) - 1;
  printf F "#    %sV\n",' 'x($s);
  printf F "# s: %s\n",join',', map { sprintf '%2d',$_ } @values[@sorted_idx];
  printf F "# v: %s\n",join',', map { sprintf '%2d',$_ } @values[0 .. $nm-1];
  printf F "#rk: %s\n",join',', map { sprintf '%2d',$_ } @rank;
  printf F "#si: %s\n",join',', map { sprintf '%2d',$_ } @sorted_idx;
  printf F "digraph tree {\n";

  printf F qq'"median-" -> %s\n',$root->{medians}[0]{id};
  printf F qq'"median+" -> %s\n',$root->{medians}[1]{id};
  
  printf "root: %s\n",$root->{id};
  my @list = ($root);
  my $u = 0; # a left sibling for single blue nodes !
  while (@list) {
    my $node = shift @list;
    my $children = $node->{children} || [];
    if (exists $node->{id}) {
      my $ismed = ($root->{medians}[0]->{id} eq $node->{id}) ? 'm-' :
                  ($root->{medians}[1]->{id} eq $node->{id}) ? 'm+' : '';
      my $faddr = &frac_addr($node->{addr},$node->{level});
      printf F qq' %s [shape="record" label="%s|{{%d|%d|%d|s=%d}|{%s|val=%s|%s|n=%d}}" ];\n',
           $node->{id},$node->{id},
           $node->{d_order},$node->{r_order},$node->{u_order},$node->{sum},
           $faddr,$node->{val},$ismed, $node->{n};
    }
    if (scalar @{$children}) {
      push @list, grep { defined $_ } @{$children};
      #printf "list: [%s]\n",join',',map { $_->{id} } @list;
      $children->[0]{id} = 'u'.$u++ if (! defined $children->[0]);
 
      #printf F " %s -> { %s };\n",$node->{id},join',',map { $_->{id}; } (@{$children});
      if (exists $children->[0]) { # red link
         printf F qq' %s -> %s [ color="red" ];\n',$node->{id}, $children->[0]{id};
      }
      if (exists $children->[1]) { # blue link
         printf F qq' %s -> %s [ color="blue" ];\n',$node->{id}, $children->[1]{id};
      }
    }
    if (exists $node->{id}) {
       printf "%s: \@%s val=%d\n",$node->{id},&frac_addr($node->{addr},$node->{level}),$node->{val};
    } else{
       printf "node: undefined\n";
    }
  }

  printf F "}\n";

  close(F);
  system "dot -T png -o tree.png tree.dot"; 
  
}

sub compare {
  my ($a,$b) = @_;
  my $comp = $a->{val} <=> $b->{val} || &addr_compare($a,$b);
  return  $comp;
}

sub addr_compare {
  my ($a,$b) = @_;
  my $fa = &frac_addr($a->{addr},$a->{level});
  my $fb = &frac_addr($b->{addr},$b->{level});
  return $fa <=> $fb;
}

