#!/usr/bin/perl

# --- # meta for uniq.pl
# name: uniq.pl
# details: a uniq that doesnt required a sort
# usage: perl -S uni.pl $file | more
# ---

my %seen = ();
local $/ = "\n";
while (<>) {
   if ($_ =~ /^$/) {
      print "\n";
   } else {
      print $_ unless $seen{$_}++;
   }
}
exit $?;
1; # $Source: /my/perl/scripts/uniq.pl $

