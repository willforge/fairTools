#!/usr/bin/perl -w

# intent:
#  create a set of number (size = nl) and compute the median

use YAML::Syck qw(Dump);
my $seed = srand('4451');


my $arity = 2;
my $nl = 15; #  size of random set
my $nm = 15; # number of know


my $u = 0;
my $id = 0;
my $tree = {};
my @values;
for $i (0 .. $nl-1) {
  my $val = int (rand($nl)) + 1; # 1 .. nl
  push @values,$val;
}
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
  my $node = {
     val => $val, id => $id, n => 0, median => 0,
     sum => 0, d_order => 0, u_order => 0, r_order => $rank[$i],
     children => [], medians => [], parents => []};
  $tree = &insert($node,$tree);
  printf "node-%s: %d (n=%d, m=%.2f) inserted\n",$node->{id},$node->{val},$node->{n},$tree->{median};
  printf "parents-%s: [%s]\n",$node->{id},join',',map { $_->{id} } @{$node->{parents}};
  printf "list: %s\n",join',',map { sprintf '%2d',$_ } sort { $a <=> $b } @values[0 .. $i];
  printf "      %s^\n",' 'x(3*int(($i+1)/2) + (($i+1)%2) - 1);
}

# testing next
my $prev = { id => 'x' };
my $pos = $tree;
while ($pos->{id} ne $prev->{id}) {
  my $next = &find_next($pos);
  $prev = $pos;
  $pos = $next;
}
print ".\n";
# testing prev;
for $i (0 .. $nm-1) {
  my $prev = &find_prev($pos);
  $pos = $prev;
}
# travel the missing ones (smaller than root)
while ($pos->{id} ne $tree->{id}) {
  my $next = &find_next($pos);
  $pos = $next;
}

print "display:\n";
&display($tree);
print "...\n";

exit;


if (0) {
printf "tree: %s...\n",Dump($tree);
# tree traversal
print "DFS:\n";
&DFS_traversal($tree);
print "BFS:\n";
&BFS_traversal($tree);

}

print ".\n";
exit $?;
# --------------------------------------------------------------
sub insert {
   my $node = shift;
   printf "\ninsert-node: %s:%d\n",$node->{id},$node->{val};
   my $tree = shift;
   my $root = $tree;
   if (! exists $root->{children}) { # empty tree
      $node->{n} = 1;
      $node->{medians} = [$node,$node];
      $node->{median} = $node->{val};
      $node->{parents} = [];
      return $node;
   }
   my $pos = undef;
   my $spot = undef; # place where node is to be inserted;
   my $medianm = $root->{medians}[0];
   my $medianp = $root->{medians}[1];
   my $comp0 = &compare($node,$medianm);
   my $comp1 = &compare($node,$medianp);
   printf "median-comp0: %s <=> %s:%d = %s\n",$node->{id},$medianm->{id},$medianm->{val},$comp0;
   printf "median-comp1: %s <=> %s:%d = %s\n",$node->{id},$medianp->{id},$medianp->{val},$comp1;

   if ($comp0 < 0) {  # smaller than smallest median
      if (exists $medianm->{children}[0]) {
         $pos = $medianm->{children}[0];
         printf "start-at-medianm: %s:%d (left red branch)\n",$pos->{id},$pos->{val};
      } else {
         $pos = $medianm;
         ; #$spot = $medianm;
      }
   } elsif ($comp1 > 0) { # bigger than biggest median
      if (exists $medianp->{children}[1]) {
         $pos = $medianp->{children}[1];
         printf "start-at-medianp: %s:%d (right blue branch)\n",$pos->{id},$pos->{val};
      } else {
         $pos = $medianp;
         ; #$spot = $medianp;
      }
   } else { # in between
      if (! exists $medianp->{children}[0]) {
         $pos = $medianp;
         ; #$spot = $medianp;
      } elsif (! exists $medianm->{children}[1]) {
         $pos = $medianm;
         ; #$spot = $medianm;
      } else {
         warn "m- red branch and m+ blue branch exist)";
         $pos = $medianm;
      }
      printf "between-median: %s:%d, %s:%d\n",$medianm->{id},$medianm->{val},$medianp->{id},$medianp->{val};
   }
   $pos = $root;
   printf "start-at-root: %s:%d (reset)\n",$pos->{id},$pos->{val};

   while (! $spot) {
      my $comp = &compare($node,$pos);
      printf "comp: %s <=> %s = %s\n",$node->{id},$pos->{id},$comp;
      if ($comp > 0) {
         if (! exists $pos->{children}[1]) {
            ; # attach node to tree (right branch);
            $pos->{children}[1] = $node;
            $spot = $pos;
         } else { # no spot available at this level : go down the right branch
            $pos = $pos->{children}[1];
         }
         $node->{u_order} = $pos->{u_order} + 1;
      } elsif($comp < 0) { # left insert 
         if (! exists $pos->{children}[0]) {
            ; # attach node to tree (left branch)
            $pos->{children}[0] = $node; 
            $spot = $pos;
         } else { # no spot available at this level : go down the left branch
            $pos = $pos->{children}[0];
         }
         $node->{d_order} = $pos->{d_order} +1;
      } else { # comp = 0
         if ($comp0 >= 0 && $comp1 <= 0) { # if 2 medians (even) -> pos will become new median (odd)
            if (! exists $medianm->{children}[1]) {
               $pos = $medianm;
               $pos->{children}[1] = $node;
               $comp0 = 1; # considering comp0 > 0
               $spot = $pos;
            } elsif (! exists $medianp->{children}[0]) {
               $pos = $medianp;
               $pos->{children}[0] = $node;
               $comp1 = -1; # considering comp1 < 0
               $spot = $pos;
            } else {
               ; #push(@parents,$pos);
               die "error: median non consecutive ...";
            }
         } else {
            if (! exists $pos->{children}[0]) { # left branch prefered ...
               ; # attach node to tree (left branch)
               $pos->{children}[0] = $node; 
               $comp = -1; # consideing new node smaller than pos
               $spot = $pos;
            } elsif (! exists $pos->{children}[1]) {
               ; # attach node to tree (right branch)
               $pos->{children}[1] = $node; 
               $comp = 1; # consideing new node bigger than pos
               $spot = $pos;
            } else { # no spot available at this level : go down the any branch
               $pos = $pos->{children}[0];
            }
         }
      }
   }
   if ($spot) {
      $node->{parents} = [@{$spot->{parents}},$spot];
      printf "%s's parents: %s\n",$node->{id},join',',map { $_->{id}; } @{$node->{parents}};
   }
   # update n
   $node->{n} = 1;
   do { $_->{n} = $_->{n} + 1 } for @{$node->{parents}};

   ; # update medians
   if ($comp1 > 0) {
      printf "update(m+ < node) : %s:%d >= %s:%d\n",$spot->{id},$spot->{val},$medianp->{id},$medianp->{val};
      if ($medianm->{id} ne $medianp->{id}) { # odd
         if ($root->{n} % 2 == 0) {
           print "error: n is even w/ one median /!\\\n",
         } else {
           print "odd : one median \n";
         }
         $root->{medians}[0] = $medianp; # insertion was on the right side !
            $root->{median} = $medianp->{val};
      } else { # even
         if ($root->{n} % 2) {
           print "error: n is odd w/ two median /!\\\n",
         } else {
           print "even : two medians \n";
         }
         $root->{medians}[0] = $medianp;
         $root->{medians}[1] = &find_next($medianp);
         $root->{median} = ($root->{medians}[1]->{val} + $root->{medians}[0]->{val})/2;
      }
      printf "update-medianm: %s:%d\n",$root->{medians}[0]->{id},$root->{medians}[0]->{val};
      printf "update-medianp: %s:%d\n",$root->{medians}[1]->{id},$root->{medians}[1]->{val};
      printf "update-median: %.2f\n",$root->{median};
   } elsif ($comp0 < 0) {
      printf "update(node < m-) : %s:%d >= %s:%d\n",$spot->{id},$spot->{val},$medianm->{id},$medianm->{val};
      if ($medianm->{id} ne $medianp->{id}) { # odd
         if ($root->{n} % 2 == 0) {
           print "error: n is even w/ one median /!\\\n",
         } else {
           print "odd : one median\n";
         }
         $root->{medians}[1] = $medianm;
         $root->{median} = $medianm->{val};
      } else { # even
         if ($root->{n} % 2) {
           print "error: n is odd w/ two median /!\\\n",
         } else {
           print "even : two medians\n";
         }
         $root->{medians}[1] = $medianm;
         $root->{medians}[0] = &find_prev($medianm);
         $root->{median} = ($root->{medians}[1]->{val} + $root->{medians}[0]->{val})/2;
      }
      printf "update-medianm: %s:%d\n",$root->{medians}[0]->{id},$root->{medians}[0]->{val};
      printf "update-medianp: %s:%d\n",$root->{medians}[1]->{id},$root->{medians}[1]->{val};
      printf "update-median: %.2f\n",$root->{median};
   } elsif (0 < $comp0 && $comp1 < 0) {
     printf "update(m- < node < m+) : %s:%d < %s:%d < %s:%d \n",$medianm->{id}, $medianm->{val}, $spot->{id},$spot->{val},$medianp->{id},$medianp->{val};
      if ($root->{n} % 2 == 0) {
        die "error: n is even an val in between /!\\",
      }
      $root->{medians}[1] = $node;
      $root->{medians}[0] = $node;
      $root->{median} = ($root->{medians}[1]->{val} + $root->{medians}[0]->{val})/2;
      printf "update-medianm: %s:%d\n",$root->{medians}[0]->{id},$root->{medians}[0]->{val};
      printf "update-medianp: %s:%d\n",$root->{medians}[1]->{id},$root->{medians}[1]->{val};
      printf "update-median: %.2f\n",$root->{median};

   } elsif ($comp0 == 0) { # node was inserted in between
     printf "update(m- == node) : %s:%d == %s:%d \n", $spot->{id},$spot->{val},$medianm->{id},$medianm->{val};
      if ($medianp->{id} eq $medianm->{id}) { # is even now
        $root->{medians}[1] = $node;
      } else {
         printf "update-medianm: %s:%d\n",$root->{medians}[0]->{id},$root->{medians}[0]->{val};
         $root->{medians}[1] = $node;
         $root->{medians}[0] = $node;
      } 
      printf "update-medianp: %s:%d\n",$root->{medians}[1]->{id},$root->{medians}[1]->{val};
   } elsif ($comp1 == 0) { # node was insered in between
     printf "update(node == m+) : %s:%d == %s:%d \n", $spot->{id},$spot->{val},$medianp->{id},$medianp->{val};
      if ($medianp->{id} eq $medianm->{id}) { # is even now : need 2 medians
        $root->{medians}[1] = $node;
      } else { # is odd now : need one medians
        $root->{medians}[0] = $node;
        $root->{medians}[1] = $node;
        printf "update-medianm: %s:%d\n",$root->{medians}[0]->{id},$root->{medians}[0]->{val};
      }
      printf "update-medianmp %s:%d\n",$root->{medians}[1]->{id},$root->{medians}[1]->{val};
   }

   printf "root->{n}: %d\n",$root->{n};
   ; # computes node's metrics
   $node->{sum} = $spot->{sum} + $node->{val};
   return $root;
}
# --------------------------------------------------------------
sub find_next {
  my $pos = shift;
  my $parents = $pos->{parents};
  #printf "--- # %s: %s...\n",$pos->{id},Dump($parents);
  # all nodes in right subtree are bigger
  # next == smaller (redest) of bigger "right (blue)" branch ...
  # or first parent who has a "left (red) edge"

  my $next = $pos;
  if (exists $pos->{children}[1]) { # next is in blue branch
    $next = $pos->{children}[1];
    while (exists $next->{children}[0]) { # if a red branch exists
      $next = $next->{children}[0];
    }
  } else { # next is in a parent subtree
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
  printf "next-to: %s:%d is %s:%d\n",$pos->{id},$pos->{val},$next->{id},$next->{val};
  return $next;
}
# --------------------------------------------------------------
sub find_prev {
  my $pos = shift;
  my $parents = $pos->{parents};
  my $prev = $pos;
  # lookup in the children tree
  if (exists $pos->{children}[0] && defined $pos->{children}[0]) { # prev is in red branch
     $prev = $pos->{children}[0];
     while (exists $prev->{children}[1]) { # if blue children then descend blue side;
        $prev = $prev->{children}[1];
     }
  } else { # prev is in parent subtree
     if (scalar(@{$parents})) {
        printf "parents: [%s]\n",join',',map { $_->{id}; } @{$parents};
     } else {
        printf "parents: [] (%s no parents)\n",$pos->{id};
     }
     $parent = $pos;
     foreach $gdparent (reverse @{$parents}) {
        if (exists $gdparent->{children}[1] && $gdparent->{children}[1]->{id} eq $parent->{id}) { # go up until blue
           printf "gdparent: %s:%d (is blue)\n",$gdparent->{id},$gdparent->{val};
           $prev = $gdparent; last;
        } else {
           printf "gdparent: %s:%d (is red)\n",$gdparent->{id},$gdparent->{val};
        }
        $parent = $gdparent;
     }
  }
  printf "prev-to: %s:%d is %s:%d\n",$pos->{id},$pos->{val},$prev->{id},$prev->{val};
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
 printf "%s: %s val=%s\n",$label, $node->{id},$node->{val};
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
  while (@list) {
    my $node = shift @list;
    my $children = $node->{children} || [];
    if (exists $node->{id}) {
      my $ismed = ($root->{medians}[0]->{id} eq $node->{id}) ? 'm-' :
                  ($root->{medians}[1]->{id} eq $node->{id}) ? 'm+' : '';

      printf F qq' %s [shape="record" label="%s|{{%d|%d|%d|s=%d}|{val=%s|%s|n=%d}}" ];\n',$node->{id},
           $node->{id}, $node->{d_order},$node->{r_order},$node->{u_order},$node->{sum},
           $node->{val},$ismed, $node->{n};
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
       printf "%s: val=%d\n",$node->{id},$node->{val};
    } else{
       printf "node: undefined\n";
    }
  }

  printf F "}\n";
  
}

sub compare {
  my ($a,$b) = @_;
  my $comp = $a->{val} <=> $b->{val};
  return  $comp;
}

