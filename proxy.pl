
# Setup:
# Added the following line to /etc/services
#
# ircprox         3128/tcp   #IRC action script proxy
# 
# Added the following line to /etc/inetd.conf
# 
# ircprox  stream  tcp     nowait  ircd    /usr/oops/proxy.pl proxy.pl
#
# Added the following line to /etc/rc.conf
# 
# inetd_enable="YES"
# 
# 
# The idea is to use inetd to manage the client socket creation - it binds
# socket IO to standard in and out. Then simply connect to the irc server 
# and pass characters back and forth - stripping \0s added by the flash
# client (make sure to end all IRC messages with \r\n so this works) and
# add \0's onto the end of any messages from the server.
#

#!/usr/bin/perl
#A simple Actionscript XMLObject proxy for arbitrary protocols

use Socket;
use FileHandle;
use IO::Select();

$server = "127.0.0.1";
$port = 6667;


$fhset = new IO::Select();

#Build an outbound socket
$internet_addr = inet_aton($server) || die "Couldn't convert $server
into an Internet address: $!\n";
$paddr = sockaddr_in($port, $internet_addr);
socket(SOCKET, PF_INET, SOCK_STREAM, getprotobyname('tcp'));
unless ( connect(SOCKET, $paddr) ) {
      print "Couldn't connect to $server:$port : $!\n";
      exit(100);
}

SOCKET->autoflush;
STDOUT->autoflush;

$fhset->add(\*SOCKET);
$fhset->add(\*STDIN);

while(1) {
 while(my @ready = $fhset->can_read(500)) {

  $lchar = '';
  $schar = '';

  foreach $fh (@ready) {
    if($fh == \*SOCKET) {
      my $sz = sysread( $fh, $schar, 1) || last;
    }

    if($fh == \*STDIN) {
      my $sz = sysread( $fh, $lchar, 1) || last;
    }

    #strip localy sent \0's
    unless( $lchar eq "\0") {
      print SOCKET "$lchar";
    }

    print STDOUT "$schar";

    #add trailing \0's
    if( $schar eq "\n" ) {
      print STDOUT "\0";
    }
  }
 }
}