package SimpleDB;

use warnings;
use strict;
use Data::Dumper;
use File::Basename;
# we dont use Text::CSV::Simple since it isnt part of perl base packages
use HTTP::Request::Common;
use LWP::UserAgent;

use constant {
    PLUGINNAME => 'SimpleDB',
    PLUGINDESCRIPTION => 'Retrieves Info from a plain Text file - pure info plugin!',
    PLUGINAUTHOR => 'Henning Mersch',
    PLUGINAUHTORCONTACT => 'Webpage: http://www.henning-mersch.de',
    PLUGINKEYPROPOSAL => 'a', #required to be an Action Plugin
    PLUGINDISABLED => 0,
};


my @data;
my $newContributor = "";
my $file = $FindBin::RealBin."/CHPlugins/simpledb.csv";
# my $remoteServer = "http://localhost:8080";
my $remoteServer = "http://chome.appspot.com";
my $askUserIfRemote;
my $contactway = "";
sub new {
    	my $class = shift;
	my $self  = [];

	readData();

	readRemoteData();

	bless $self, $class;
	return $self;
}
# Plugin Info Getter
sub getName { return PLUGINNAME;}
sub getDescription { return PLUGINDESCRIPTION;}
sub getAuthor { return PLUGINAUTHOR;}
sub getAuthorContact { return PLUGINAUHTORCONTACT;}
sub getKeyProposal { return PLUGINKEYPROPOSAL;} #required to be an Action-Plugin!!!
sub disabled { return PLUGINDISABLED;}

# Plugin Methods
# info: 
# return information or empty String
sub info {
	my $self = shift;
	my $file = basename(shift);

	for my $er (@data) {
		my %e = %$er;
		#print STDERR "file $file with hashfile ".$e{File};
		if ($file && defined $e{File} && $e{File} eq $file) {
			#print "Match:".$e{File}."-> ".$file."\n";
			return "Application: ".$e{AppName}."<".$e{AppHomepage}.">: ".$e{AppDescription}." (by ".$e{Contributor}.")";
		}
	}
	return "";
}



# couldProcess()
# if this plugin could process this file, return a descriptive String
# otherwise return a empty string
sub couldProcess {
	my $self = shift;
	my $file = shift;
	if($self->info($file) eq ""){ #we dont know this file, yet
		return "Add to SimpleDB";
	}
}

# process()
# process the file - eventually by interacting with user
# return TRUE if file is deleted or finally processed in any war
# return FALSE if other plugins should be able to process $file again
sub process {
	my $self = shift;
	my $file = basename(shift);
	my %e;
	my $userin;

	print "Please enter data for '$file' \n";
	$e{File} = $file;
	print "ApplicationName:";
	$e{AppName} = <>;
	chomp($e{AppName});
	print "Application Homepage:";
	$e{AppHomepage} = <>;
	chomp($e{AppHomepage});
	print "Application Description:";
	$e{AppDescription} = <>;
	chomp($e{AppDescription});
	if($newContributor eq "") {
		print "Your Name:";
		$newContributor = <>;
		chomp($newContributor);
	}
	$e{Contributor} = $newContributor;
	$self->appendEntry(\%e);  # Adding $file as a parameter
	readData(); #reread data just to be sure....
	return 0; #thus user could process using other plugins
}



# NON Plugin Method!
# getFileInfo: 
# return has of known file item in DB
# this could be used by other plugins to retrieve known files and their data
sub getFileInfo {
	my $self = shift;
	my $file = basename(shift);

	for my $er (@data) {
		my %entry = %$er;
		#print STDERR "file $file with hashfile ".$e{File};
		if ($file && defined $entry{File} && $entry{File} eq $file) {{
			#print "Match:".$e{File}."-> ".$file."\n";
			return \%entry;
		}
	}
	return 0;
}


# Private methods
#################

sub readData {
	my $file = $FindBin::RealBin."/CHPlugins/simpledb.csv";
	open (F, $file) || die ("Could not open $file!");
	while (my $line = <F>) {
		if($line =~ /^#/) {next;} #ignore comment lines
		if($line eq "\n") {next;} #ignore empty lines
		chomp $line;
		my %e;
  		($e{File},$e{AppName},$e{AppDescription},$e{AppHomepage},$e{Contributor}) = split '\|', $line;
		push @data, \%e;
	}
	close(F);

}

sub readRemoteData {
	if($askUserIfRemote) {return;}
	print "SimpleDB Plugin: Download up-to-date DB from CleanHome's Remote DB? (y/n)";
	$askUserIfRemote = <STDIN>;
	chomp($askUserIfRemote);
	if($askUserIfRemote =~ /y/i) {
		my $ua = LWP::UserAgent->new();
		my $re = GET "$remoteServer/ws/showall";
	        my $remotedb = $ua->request($re)->content;
		print "Parsing Entries:";
		for my $line (split(/\n/,$remotedb)) {
			if($line =~ /^#/) {next;} #ignore comment lines
			# print "Parsing entry: $line\n";
			my %e;
  			($e{File},$e{AppName},$e{AppDescription},$e{AppHomepage},$e{Contributor}) = split '\|', $line;
			print ".";
			push @data, \%e;
		}
		print " Done.\n";
	}
}
sub appendEntry {
        my ($self, $er) = @_;  # Removed $file from parameters, as it's not needed for appending to SimpleDB
        my %e = %{$er};
        my $simpleDB_file = $FindBin::RealBin."/CHPlugins/simpledb.csv";  # Define the correct SimpleDB file path

        open(F, ">>$simpleDB_file") || die ("Could not open $simpleDB_file!");
        print F $e{File}."|".$e{AppName}."|".$e{AppDescription}."|".$e{AppHomepage}."|".$e{Contributor}."\n";
        close F;
        print "Entry Saved to your database\n";
	print "Please contribute! Am I allowed to submit this entry to the removte Database? (y/n)";
	my $askUserSendEntry = <STDIN>;
	chomp($askUserSendEntry);
	if($askUserSendEntry =~ /y/i) {
		if($contactway eq "") {
			print "Please provide one way contacting you (e.g email addres, XMPP...) - will never be published!\n";
			$contactway = <STDIN>;
			chomp($contactway);
		}
		my $ua = LWP::UserAgent->new;
		my $re = POST "$remoteServer/ws/addstore",[ file => $e{File}, 
							appname =>  $e{AppName}, 
							appdescriptor => $e{AppDescription}, 
							apphomepage => $e{AppHomepage},
							contributor => $e{Contributor},
							contributorcontact => $contactway];
		my $result = $ua->request($re)->content;
		print "Remote Response:'$result'";
	} else {
		print "PLEASE send the database ($file) via eMail to the author: cleanhome\@hmersch.de\n";
	}


}
}
1;
