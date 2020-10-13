#

use YAML::Syck qw(LoadFile Dump);
my $cond = LoadFile('condition.yml');

my $seed = 1452162;
srand($seed);

my $n = $cond->{n}; # test under review
my $nt = $cond->{texts} - 1; # number of texts - 1
my $nn = $cond->{nodes} - 1; # number of nodes - 1
my @text_idx = (0 .. $nt); # all texts
my @registry = map {'t'.$_; } (0 .. $nt); # all texts

my @grades = ( map { (); } @text_idx );
my @med = ();

# all nodes sort texts ...
for $node (0 .. $nn) {
   @sorted = sort by_preference @text_idx;
   printf "node%03d: %s ... t%s\n",$node,join(',',map { 't'.$_; } @sorted[0 .. $n]),$sorted[-1];
   $orders[$node] = @sorted;


   # node to score n texts :
   my @local_grades = ();
   # pref is the position of the text in the node's prefered ordered list
   for my $pref (0 .. $n-1) {
     my $grade = $n-1 - $pref;
     my $tidx = $sorted[$pref];
     #printf "%sth choice: t%d grade: %s\n",$pref+1,$tidx,$grade;
     $local_grades[$tidx] = $grade;
     #printf " grades of texts: %s\n",join',',@local_grades;
     $grades[$tidx][$node] = $grade;
   }
}
print ".\n";

# --------------------------
for my $node (0 .. $nn) {
   printf "node%03d: %s ... t%s\n",$node,join(',',map {'t'.$_; } (0 .. $n-1)),$text_idx[-1];
   print "grades:   ";
   for my $tidx (0 .. $n-1, -1) {
      printf "%s, ",join',',map { defined $_?$_:' '} $grades[$tidx][$node];
   }
   print "\n";
}
print ".\n";
# --------------------------


   for my $tidx (0 .. $nt) {
     $med[$tidx] = &get_median(@{$grades[$tidx]});
   }
   my $i = 0;
   for my $tidx (sort by_nview (0 .. $nt)) {
     my $nv = grep { defined $_; } @{$grades[$tidx]};
     printf "text%04d: [%s] %d -> med= %s\n",$tidx,join(',',@{$grades[$tidx]}),$nv,$med[$tidx];
     last if $i++ > 10;
   }


exit $?;

sub by_nview { 
  my $na = grep { defined $_; } @{$grades[$a]};
  my $nb = grep { defined $_; } @{$grades[$b]};
  return $nb <=> $na;
}
sub by_med { 
  $med[$a] <=> $med[$b];
}
sub by_preference { 
  rand(1) > 0.5 ? +1 : -1
}
sub get_median {
 my @grades = grep { (defined $_ && $_ ne '') } @_;
 my $nn = scalar(@grades);
 my @sorted = reverse sort @grades;
 #printf "unsorted grades: %s\n",join',',@_;
 #printf "reduced grades: %s\n",join',',@grades;
 #printf "sorted grades: %s\n",join',',@sorted;
 my $med = 0;
 if ($nn % 2) {
   $med = $sorted[$nn/2];
 } else {
   $med0 = $sorted[($nn-1)/2] + $sorted[($nn+1)/2];
   $med = $sorted[($nn-1)/2];
 }
 return $med;
}
