#!/usr/bin/perl

# intent:
#  create a set of number (size = nl) and compute the median

my $seed = srand('4r51');


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
     val => $val, id => $id, n => 0,
     sum => 0, d_order => 0, u_order => 0, r_order => $rank[$i],
     children => [] };
  $tree = &insert($node,$tree);
  printf "node%s: %d\n",$node->{id},$node->{val};
}
use YAML::Syck qw(Dump);
printf "tree: %s...\n",Dump($tree);
# tree traversal
&DFS_traversal($tree);

print "...\n";
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
  return $node;
 }
 my $spot = undef; # place where node is to be inserted
 my $pos = $root;
 while (! $spot) {
 my $comp = &compare($node,$pos);
 if ($comp > 0) { # right insert 
    if (! exists $pos->{children}[1]) {
       # computes node's metrics
       $node->{sum} = $pos->{sum} + $node->{val};
       $node->{n}++;
       do { $_->{n} = $_->{n} + 1 } for @parents;
       # attach node to tree (right branch);
       $pos->{children}[1] = $node;
       $spot = $pos;

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
       # attach node to tree (left branch)l
       $pos->{children}[0] = $node; 
       $spot = $pos;
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

# --------------------------------------------------------------
sub DFS_traversal {
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
  my @list = ($root);
  while (@list) {
    my $node = shift @list;
    my $children = $node->{children};
    if (exists $node->{id}) {
      printf F qq' %s [shape="record" label="%s|{{%d|%d|%d|s=%d}|{val=%s|n=%d}}" ];\n',$node->{id},
           $node->{id}, $node->{d_order},$node->{r_order},$node->{u_order},$node->{sum}, $node->{val},
           $node->{n};
    }
    if (scalar @{$children}) {
      push @list, @{$children};
      $children->[0]{id} = 'u'.$u++ if (! defined $children->[0]);
 
      printf F " %s -> { %s };\n",$node->{id},join',',map { $_->{id}; } (@{$children});
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

