package BrowserCall;

use warnings;
use strict;
use File::Copy;
use File::Basename;

use constant {
    PLUGINNAME => 'BrowserCall',
    PLUGINDESCRIPTION => 'Google for the file/dir (starts min) or show homepage if set in SimpleDB',
    PLUGINAUTHOR => '4ndr0666',
    PLUGINAUHTORCONTACT => 'Webpage: http://www.github.com/4ndr0666',
    PLUGINKEYPROPOSAL => 'b', #required to be an Action Plugin
    PLUGINDISABLED => 0,
};



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
	my $googlefile = basename($file);
	if($main::pluginHash{a}->getFileInfo($file) && $main::pluginHash{a}->getFileInfo($file)->{"AppHomepage"}) {
	  return "Start min with Homepage ".$main::pluginHash{a}->getFileInfo($file)->{"AppHomepage"}
	}
	return "Start min and google for '$googlefile'";
}

# process()
# process the file - eventually by interacting with user
# return TRUE if file is deleted or finally processed in any way
# return FALSE if other plugins should be able to process $file again
sub process {
	my $self = shift;
	my $file = shift;
	my $googlefile = basename($file);
	
	print "Starting Min ..";
	if($main::pluginHash{a}->getFileInfo($file) && $main::pluginHash{a}->getFileInfo($file)->{"AppHomepage"}) {
	  system("min ".$main::pluginHash{a}->getFileInfo($file	)->{"AppHomepage"});
	  return 0;
	}
	system("min http://www.google.de/search?q=$googlefile&ie=UTF-8");
	return 0;
}


1;
