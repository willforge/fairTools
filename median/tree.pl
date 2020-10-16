#!/usr/bin/perl

# intent:
#  create a set of number and compute the median
my $seed = srand('4451');


my $arity = 2;
my $nl = 30;


my $u = 0;
my $id = 0;
my $tree = {};
my @values;
for $i (0 .. $nl-1) {
  my $id = 'n'.$i;
  my $val = int (rand($nl)) + 1; # 1 .. 10
  push @values,$val;
  my $node = {
     val => $val, id => $id,
     sum => 0, d_order => 0, u_order => 0,
     children => [] };
  $tree = &insert($node,$tree);
  printf "node%s: %d\n",$node->{id},$node->{val};
}

use YAML::Syck qw(Dump);
printf "tree: %s...\n",Dump($tree);
print "...\n";
&display($tree);
print ".\n";

exit $?;

# --------------------------------------------------------------
sub display {
  my $root = shift;
  local *F; open F,'>','tree.dot';
  printf F "# %s\n",join', ',@values;
  printf F "digraph tree {\n";
  my @list = ($root);
  while (@list) {
    my $node = shift @list;
    my $children = $node->{children};
    if (exists $node->{id}) {
      printf F qq' %s [shape="record" label="%s|{{%d|%d|s=%d}|val=%s}" ];\n',$node->{id},
           $node->{id}, $node->{d_order},$node->{u_order},$node->{sum}, $node->{val};
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
# --------------------------------------------------------------
sub insert {
 my $node = shift;
 my $root = $tree;
 my @parents = ();
 if (! exists $root->{children}) { # empty tree
  return $node;
 }
 my $spot = undef;
 my $pos = $root;
 while (! $spot) {
 my $comp = &compare($node,$pos);
 if ($comp > 0) { # right insert 
    if (! exists $pos->{children}[1]) {
       # computes node's metrics
       $node->{sum} = $pos->{sum} + $node->{val};
       $node->{u_order} = $pos->{u_order};
       if (defined $pos->{children}[0]) {
         my $left_child = $pos->{children}[0];
         $left_child->{u_order} += 1;
       }
       do { $_->{u_order} = $_->{u_order} + 1 } for @parents;
       # attach node to tree (right branch);
       $pos->{children}[1] = $node;
       $spot = $pos;

    } else { # no spot available at this level : go down the right branch
       $pos = $pos->{children}[1];
       push @parents, $pos;

    }
 } elsif($comp <= 0) { # left insert 
    if (! exists $pos->{children}[0]) {
       # computes node's metrics
       $node->{sum} = $pos->{sum} + $node->{val};
       $node->{d_order} = $pos->{d_order};
       #do { $_->{d_order} = $node->{d_order} } for @parents;
       # attach node to tree (left branch)l
       $pos->{children}[0] = $node; 
       $spot = $pos;
    } else { # no spot available at this level : go down the left branch
       $pos = $pos->{children}[0];
       push @parents, $pos;
    }
 } 
 }
 return $root;
}
# --------------------------------------------------------------


sub compare {
  my ($a,$b) = @_;
  my $comp = $a->{val} <=> $b->{val};
  return  $comp;
}

