#!/usr/bin/perl

# intent:
#  create a set of number (size = nl) and compute the median

my $seed = srand('4351');


my $arity = 2;
my $nl = 15; # 


my $u = 0;
my $id = 0;
my $tree = {};
my @values;
for $i (0 .. $nl-1) {
  my $val = int (rand($nl)) + 1; # 1 .. nl
  push @values,$val;
}
my @rank = ();
my @sorted_idx = sort { $values[$a] <=> $values[$b] } (0 .. $nl-1);
foreach my $i (@sorted_idx) { 
  $rank[$sorted_idx[$i]] = $i;
}

# build tree ...
for $i (0 .. $nl-1) {
  my $id = 'n'.$i;
  my $val = $values[$i];
  my $node = {
     val => $val, id => $id, n => 0, median => 0,
     sum => 0, d_order => 0, u_order => 0, r_order => $rank[$i],
     children => [], medians => [] };
  $tree = &insert($node,$tree);
  printf "node%s: %d\n",$node->{id},$node->{val};
}
use YAML::Syck qw(Dump);
printf "tree: %s...\n",Dump($tree);
# tree traversal
print "DFS:\n";
&DFS_traversal($tree);
print "BFS:\n";
&BFS_traversal($tree);

print "display:\n";
&display($tree);
print "...\n";

print ".\n";
exit $?;

# --------------------------------------------------------------
sub insert {
 my $node = shift;
 my $tree = shift;
 my $root = $tree;
 my @parents = ($root);
 if (! exists $root->{children}) { # empty tree
  $node->{n}++;
  $node->{medians} = [$node,$node];
  $node->{median} = $node->{val};
  return $node;
 }
 my $pos = undef;
 my $comp0 = &compare($node,$root->{medians}[0]);
 my $comp1 = &compare($node,$root->{medians}[1]);
 if ($comp0 <0) {  # smaller than smallest median
    my $medianm = $root->{medians}[0];
    if (exists $medianm->{children}[0]) {
      $pos = $medianm->{children}[0];
    } else {
      $pos = $medianm;
    }
 } elsif ($comp1 > 0) { # bigger than biggest median
    my $medianp = $root->{medians}[1];
    if (exists $medianp->{children}[1]) {
       $pos = $medianp->{children}[1];
    } else {
       $pos = $medianp;
    }
 } else { # in between
    my $medianm = $root->{medians}[0];
    my $medianp = $root->{medians}[1];
    if (! exists $medianp->{children}[0]) {
      $pos = $medianp;
    } elsif (! exists $median->{children}[1]) {
      $pos = $medianm;
    } else {
      $pos = $medianm->{children}[1];
    }
 }

 my $spot = undef; # place where node is to be inserted
 while (! $spot) {

 my $comp = &compare($node,$pos);
 if ($comp > 0) {
    if (! exists $pos->{children}[1]) {
       # computes node's metrics
       $node->{sum} = $pos->{sum} + $node->{val};
       $node->{n}++;
       do { $_->{n} = $_->{n} + 1 } for @parents;
       # attach node to tree (right branch);
       $pos->{children}[1] = $node;
       $spot = $pos;
       # update medians
       if ($node->{n} % 2) { # odd
         $root->{medians}[0] = $root->{medians}[1];
         $root->{median} = $root->{medians}[1]->{val};
       } else { # even
         $root->{medians}[0] = $root->{medians}[1];
         $root->{medians}[1] = &find_next($root->{medians}[1],@parents);
         $root->{median} = ($root->{medians}[1]->{val} + $root->{medians}[0]->{val})/2;
       }

    } else { # no spot available at this level : go down the right branch
       $pos = $pos->{children}[1];
       push @parents, $pos;

    }
    $node->{u_order} = $pos->{u_order} + 1;
 } elsif($comp <= 0) { # left insert 
    if (! exists $pos->{children}[0]) {
       # computes node's metrics
       $node->{sum} = $pos->{sum} + $node->{val};
       $node->{n}++;
       do { $_->{n} = $_->{n} + 1 } for @parents;
       # attach node to tree (left branch)
       $pos->{children}[0] = $node; 
       $spot = $pos;
       # update medians
       if ($node->{n} % 2) { # odd
         $root->{medians}[1] = $root->{medians}[0];
         $root->{median} = $root->{medians}[0]->{val};
       } else { # even
         $root->{medians}[1] = $root->{medians}[0];
         $root->{medians}[0] = &find_prev($root->{medians}[0],@parents);
         $root->{median} = ($root->{medians}[1]->{val} + $root->{medians}[0]->{val})/2;
       }

    } else { # no spot available at this level : go down the left branch
       $pos = $pos->{children}[0];
       push @parents, $pos;
    }
    $node->{d_order} = $pos->{d_order} +1;
 } 
 }
 return $root;
}
# --------------------------------------------------------------
sub find_next {
  my $pos = shift;
  my @parents = @_;
  # all nodes in right subtree are bigger
  # next == smaller (redest) of bigger "right (blue)" branch ...
  # or first parent who has a "left (red) edge"

  if (exists $pos->{children}[1]) { # next is in blue branch
    $pos = $pos->{children}[1];
    while (exists $pos->{children}[0]) { # if a red branch exists
      $pos = $pos->{children}[0];
    }
  } else { # next is in a parent subtree
    $parent = $pos;
    foreach $gdparent (reverse @parents) {
       if ($gdparent->{children}[0]->{id} == $parent->{id}) {
          $pos = $gdparent; last;
       }
       $parent = $gdparent;
    }
  }
  return $pos;
}
# --------------------------------------------------------------
sub find_prev {
  my $pos = shift;
  my @parents = @_;
  if (exists $pos->{children}[0] && defined $pos->{children}[0]) { # prev is in red branch
     $pos = $pos->{children}[0];
     while (exists $pos->{children}[1]) { # if blue children then descend blue side;
        $pos = $pos->{children}[1];
     }
  } else { # next is in parent subtree
     $parent = $pos;
     foreach $gdparent (reverse @parents) {
        if ($gdparent->{children}[1]->{id} == $parent->{id}) { # go up unil blue
           $pos = $gdparent; last;
        }
        $parent = $gdparent;
     }

  }
  return $pos;
}
# --------------------------------------------------------------
sub BFS_traversal { # breadth-first-search: using a queue
  my @queue = ();
  my %discovered = {};
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
  my %discovered = {};
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
  printf F "# i: %s\n",join',', map { sprintf '%2d',$_ } (0 .. $nl-1);
  printf F "# s: %s\n",join',', map { sprintf '%2d',$_ } @values[@sorted_idx];
  printf F "# v: %s\n",join',', map { sprintf '%2d',$_ } @values;
  printf F "#rk: %s\n",join',', map { sprintf '%2d',$_ } @rank;
  printf F "# si: %s\n",join', ',@sorted_idx;
  printf F "digraph tree {\n";

  printf F qq'"median-" -> %s\n',$root->{medians}[0]{id};
  printf F qq'"median+" -> %s\n',$root->{medians}[1]{id};
  my @list = ($root);
  while (@list) {
    my $node = shift @list;
    my $children = $node->{children};
    if (exists $node->{id}) {
      my $ismed = ($root->{medians}[0]->{id} eq $node->{id}) ? 'm-' :
                  ($root->{medians}[1]->{id} eq $node->{id}) ? 'm+' : '';

      printf F qq' %s [shape="record" label="%s|{{%d|%d|%d|s=%d}|{val=%s|%s|n=%d}}" ];\n',$node->{id},
           $node->{id}, $node->{d_order},$node->{r_order},$node->{u_order},$node->{sum},
           $node->{val},$ismed, $node->{n};
    }
    if (scalar @{$children}) {
      push @list, @{$children};
      $children->[0]{id} = 'u'.$u++ if (! defined $children->[0]);
 
      #printf F " %s -> { %s };\n",$node->{id},join',',map { $_->{id}; } (@{$children});
      if (defined $children->[0]) { # red link
         printf F qq' %s -> %s [ color="red" ];\n',$node->{id}, $children->[0]{id};
      }
      if (defined $children->[1]) { # blue link
         printf F qq' %s -> %s [ color="blue" ];\n',$node->{id}, $children->[1]{id};
      }
    }
    printf "%s: val=%d\n",$node->{id},$node->{val};
  }

  printf F "}\n";
  
}

sub compare {
  my ($a,$b) = @_;
  my $comp = $a->{val} <=> $b->{val};
  return  $comp;
}

