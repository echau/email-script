#!/usr/bin/perl
# Current mail is in /var/mail/.
# Backup mail is in /var/mailbackup/.

use warnings;

# Process each file in /var/mail/

opendir my($dh), "/var/mail";
my @files = readdir $dh;
closedir $dh;

foreach my $file ( @files ) {

	print "Processing $file ...\n";

	open F1, "</var/mail/$file";	#e-mails on server
	
	# Read in all the From header lines from the backup file
	open F2, "</var/mailbackup/$file";
	my $headersInBackupFile = '';
	while( <F2> ) {
		if( /^From / ) {
			$headersInBackupFile .= $_;
		}
	}
	close( F2 );
	
	open F2, "+>>/var/mailbackup/$file"; #e-mails on back-up server

	$header = ''; 
	while (<F1>) { 
		#Determine the start of an e-mail 
		if ($_ =~ /^From /) {
			$header = ''; 
			if ($_ =~ m/^From / && m/Feb (1[8-9]|2[0-8])/ && m/2013/) { 
				$str = $_;
				chomp( $str );
				if (index($headersInBackupFile, $str) == -1) { 
					#If the e-mail was sent between Feb. 18 - 28 and if it isn't already on the back-up server, start writing the message beginning with the header. 
					$header = $_; 
					print F2 $header; 
				} 
			} 
		} 
		else { 
			if ($header ne '') { 
				#If there is a $header variable, copy the body of the e-mail to the back-up server. 
				print F2 $_; 
			} 
		} 
	}

	close( F2 );
	close( F1 );
} # foreach
