#!/usr/bin/perl

use warnings;
use strict;

use Getopt::Std;
use Net::SNMP qw(:snmp);

my $usage = <<"EOF";
usage:  $0 [-h] -H <hostname> -c <community>

Nagios check for Cisco ASA Failover monitoring

[-h]              :       Print this message
[-H] <ip>         :       IP Address or Hostname of the ASA
[-c] <community>  :       SNMP Community String

EOF

# Must be "2"
my $oid_failover_interface = ".1.3.6.1.4.1.9.9.147.1.2.1.1.1.3.4";

# One must be "9", the other must be "10", error in all other cases
my $oid_primary_unit = ".1.3.6.1.4.1.9.9.147.1.2.1.1.1.3.6";
my $oid_secondary_unit =  ".1.3.6.1.4.1.9.9.147.1.2.1.1.1.3.7";

#===============================================================================
#                              Input Phase
#===============================================================================

our ($opt_h, $opt_c, $opt_H);
die $usage if (!getopts('hH:c:') || $opt_h);
die $usage if (!$opt_H || !$opt_c || $opt_h);
my $community = $opt_c;
my $hostname = $opt_H;

#-------------------------------------------------------------------------------
# Open an SNMPv2 session with the router
#-------------------------------------------------------------------------------
my ($session, $error) = Net::SNMP->session(
        -version     => 'snmpv2c',
        -timeout     => 2,
        -hostname    => $hostname,
        -community   => $community
);

if (!defined($session)) {
  printf("ERROR: %s.\n", $error);
  exit (2);
}

my $result = $session->get_request(-varbindlist => [ $oid_failover_interface, $oid_primary_unit, $oid_secondary_unit ],);

if (!defined $result) {
   printf "ERROR: %s.\n", $session->error();
   $session->close();
   exit 2;
}

if ($result->{$oid_failover_interface} != 2) {
    print "error on failover interface";
    exit 2;
}

my @values = (9, 10);
@values = grep(!/$result->{$oid_primary_unit}/, @values);
@values = grep(!/$result->{$oid_secondary_unit}/, @values);

if (scalar @values != 0) {
    print "error on cluster nodes";
    exit 2;
}

print "cluster working fine";
$session->close();
exit 0;
