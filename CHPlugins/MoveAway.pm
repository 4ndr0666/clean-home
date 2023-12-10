package MoveAway;

use warnings;
use strict;
use File::Copy;

use constant {
    PLUGINNAME => 'MoveAway',
    PLUGINDESCRIPTION => 'Move the dir/file to a once-defined directory',
    PLUGINAUTHOR => 'Henning Mersch',
    PLUGINAUHTORCONTACT => 'Webpage: http://www.henning-mersch.de',
    PLUGINKEYPROPOSAL => 'm', #required to be an Action Plugin
    PLUGINDISABLED => 0,
};


my $destinationdir = "";

sub new {
    my $class = shift;
    my $self  = [];
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
  return "";
}

# couldProcess()
# if this plugin could process this file, return a descriptive String
# otherwise return a empty string
sub couldProcess {
  my $self = shift;
  my $file = shift;
  return "Move '$file' away";
}

# process()
# process the file - eventually by interacting with user
# return TRUE if file is deleted or finally processed in any way
# return FALSE if other plugins should be able to process $file again
sub process {
	my $self = shift;
	my $file = shift;
	
	if($destinationdir eq "") {
		print "Please enter destination of all moved files/dirs:";
		$destinationdir = <>;
		chomp($destinationdir);
		if(! -d $destinationdir) {
			if(mkdir($destinationdir)) { print "Directory $destinationdir created\n";}	
			else { 
				print "Sorry, cant create $destinationdir";
				$destinationdir = ""; #lets ask again next time
				return 0; #maybe user wnats to try again
			}
		}
	}
	if(! `mv $file $destinationdir`) {
# doesnt work on dirs:	if(move($file,$destinationdir)) {
		print "Moved.\n";
		return 1;
	} else { 
		print "Sorry, cant move: $!";
		return 0;
	}
}


1;
