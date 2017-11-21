Nagios check for Cisco ASA Failover.
Verifies that the Cisco ASA Failover status is ok.
The script does not care what is currently the active firewall and the standby one.
As long as there is an "active" and a "standby ready" firewall, it returns OK.

Requires:
  - perl 5
  - Net::SNMP perl library

Ubuntu:
sudo apt-get install libnet-snmp-perl

CentOS:
yum install net-snmp-perl
