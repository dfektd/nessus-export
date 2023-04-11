#!/usr/local/bin/perl
#
use strict;
use warnings;
use Net::Nessus::REST;
use XML::Simple;
use Getopt::Long;

my ($xml, $server, $port, $scanId, $filename, $format, $user, $pass);


#get command line args
GetOptions("xml=s" => \$xml,
 	   "server=s" => \$server,
	   "port=i" => \$port,
	   "scanId=i" => \$scanId,
	   "filename=s" => \$filename,
	   "format=s" => \$format,
	   "user=s" => \$user,
	   "pass=s" => \$pass)
	   or die("Error in command line arguments\n");

#read in xml or command line values.

if (defined $xml )
{
	my $xml_file = new XML::Simple;
	my $config = $xml_file->XMLin($xml);
	$server = $config->{server};
	$port = $config->{port};
	$scanId= $config->{scanId};
	$filename = $config->{filename};
	$format = $config->{format};
	$user = $config->{user};
	$pass = $config->{pass};
	my $url = "https://$server:$port";
}

print "Exporting Scan ID: ${scanId} from Server: ${server}.\n\n";

#start export process!

my $nessus = Net::Nessus::REST->new(
    url => "https://$server:$port",
    ssl_opts =>    { SSL_verify_mode   => 0,
                    verify_hostname    => 0,   
                    SSL_use_cert => 0x00
                    },

);
 
$nessus->create_session(
    username => $user,
    password => $pass,
);

my $file_id = $nessus->export_scan(
    scan_id => $scanId,
    format  => $format
);


while ($nessus->get_scan_export_status(
    scan_id => $scanId,
    file_id => $file_id,
) ne 'ready') {
    sleep 1;
}
 
my $file_out = "${filename}_${file_id}.${format}";
$nessus->download_scan(
    scan_id  => $scanId,
    file_id  => $file_id,
    filename => $file_out
);
print "Scan ID ${scanId} exported to file ${file_out}.\n";
