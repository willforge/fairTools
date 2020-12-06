#!/usr/bin/perl

# --- meta:
# purpose: script to compute namespace identifier for uri
#
# usage: perl -S nid.pl urn:domain:space-uniq-name-within-domain
#
# details: |-
#  an uri is an uniq ressource identifier used
#  to create the name space id
#
#  requirement space-uniq-name-within-domain need to be permanent and global !
#
#  it is a sort of permanent global address for the namespace
#
#  ex: urn:ipns:QmdHmC48ipAsKSQcaJZ4X6b48b5mxtN5NjNEVrLbTGF8Un
#  ---

my $yml = 0;
if ($ARGV[0] eq '-y') {
  $yml=1;
  shift;
}

my $uri = shift;

my $nid = &get_nid($uri,13);
if ($yml) {
   my $vi = &varint(length($uri));
   my $mhash = pack('H*','015500').$vi.$uri;
   my $topiz = 'z'.substr(lc&encode_base58($mhash),0,34);
   my $topik = 'k'.lc&encode_base36($mhash);
   my $gravid = unpack'H*',&khash('MD5',$uri);
   printf "--- %s\n",$0;
   printf "nid: %s\n",$nid;
   printf "url: https://qwant.com/?q=%s\n",$nid;
   printf "tpz: https://github.com/search?q=%s\n",$topiz;
   printf "tpk: https://github.com/search?q=%s\n",substr($topik,0,35);
   printf "search: https://duckduckgo.com/?q=%%22%s%%22\n",$gravid;
   printf "grv: https://gravatar.com/avatar/%s\n",$gravid;
   # printf "grv1: https://robohash.org/%s?gravatar=yes\n",$uri;
   printf "grv2: https://robohash.org/%s?gravatar=hashed\n",$gravid;
   printf "bot: https://robohash.org/%s.jpg?set=set3&ignoreext=false&size=200x200&bgset=bg1\n",$nid;
   printf "bot2: https://robohash.org/%s.png?set=any&size=480x480&bgset=any\n",$nid;
   printf "ns: https://holoverse.ml/.../%s/\n",$nid
} else {
   print $nid;
}
exit $?;

# ----------------------------------
# namespace id: 13 char of base36(sha256)
# 13 is chosen to garantie uniqness
# over a population of 2^64 nodes
sub get_nid {
 my $s = shift;
 my $len = $_[0] || 13;
 my $sha2 = &khash('SHA256',$s);
 my $ns36 = &encode_base36($sha2);
 my $nid = substr($ns36,0,$len);
 return lc $nid;
}

sub khash { # keyed hash
   use Crypt::Digest qw();
   my $alg = shift;
   my $data = join'',@_;
   my $msg = Crypt::Digest->new($alg) or die $!;
      $msg->add($data);
   my $hash = $msg->digest();
   return $hash;
}
# ----------------------------------
sub encode_base58 {
  use Math::BigInt;
  use Encode::Base58::BigInt qw();
  my $bin = join'',@_;
  my $bint = Math::BigInt->from_bytes($bin);
  my $h58 = Encode::Base58::BigInt::encode_base58($bint);
  $h58 =~ tr/a-km-zA-HJ-NP-Z/A-HJ-NP-Za-km-z/;
  return $h58;
}
# ----------------------------------
sub encode_base36 {
  use Math::BigInt;
  use Math::Base36 qw();
  my $n = Math::BigInt->from_bytes(shift);
  my $k36 = Math::Base36::encode_base36($n,@_);
  #$k36 =~ y,0-9A-Z,A-Z0-9,;
  return $k36;
}
# ----------------------------------
sub varint {
  my $i = shift;
  my $bin = pack'w',$i; # Perl BER compressed integer
  # reverse the order to make is compatible with IPFS varint !
  my @C = reverse unpack("C*",$bin);
  # clear msb on last nibble
  my $vint = pack'C*', map { ($_ == $#C) ? (0x7F & $C[$_]) : (0x80 | $C[$_]) } (0 .. $#C);
  return $vint;
}
# ----------------------------------

1; # $Source: /my/perl/scripts/nid.pl $

