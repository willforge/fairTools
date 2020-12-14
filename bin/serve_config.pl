#!/usr/bin/perl -w

use IO::Socket;
use YAML::XS qw(Dump);

my $port = 1124;
my $configf = '../js/config.json';

# -------------------------------------
# route table
my %dispatch = (
    '/config.json' => \&resp_config
);
# -------------------------------------

my $server = new IO::Socket::INET(Proto => 'tcp',
                                  LocalPort => $port,
                                  Listen => SOMAXCONN,
                                  Reuse => 1);
$server or die "Unable to create server socket: $!" ;

# Await requests and handle them as they arrive
while (our $client = $server->accept()) {
   $client->autoflush(1);
   local $/ = "\r\n";

   while (<$client>) {
      chomp; # Main http request
      print "request: $_\n";
      if (/\s*(\w+)\s*([^\s]+)\s*HTTP\/(\d.\d)/) {
         $request{METHOD} = uc $1;
         $request{URL} = $2;
         $request{HTTP_VERSION} = $3;
      }
      last if /^$/;
   }
   printf "--- %s...\n",Dump(\%request);

   if ($request{METHOD} eq 'GET') {
      &{$dispatch{$request{URL}}};     
   } else {
      &resp_error();
   }
   close $client;

}

sub resp_error {
  print "HTTP/1.0 500 Bad Request\r\n";
  print $client "HTTP/1.0 500 Bad Request\r\n";
  print $client "Status: 500\r\n";
  print $client "\r\n";
  print $client "500: Bad Request\n";
}

sub resp_config { 
  local *F;
  open F,'<',$configf or die $!;
  local $/ = undef;
  my $body = <F>;
  print "HTTP/1.0 200 OK\r\n";
  print $client "HTTP/1.0 200 OK\r\n";
  print $client "Status: 200\r\n";
  print $client "Access-Control-Allow-Origin: *\r\n";
  print $client "Content-Type: application/json\r\n";
  printf $client "Content-Length: %u\r\n",length($body);
  print $client "\r\n";
  print $client $body;
  close F;
  
}

1;
