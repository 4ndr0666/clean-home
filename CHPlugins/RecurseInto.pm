package RecurseInto;

use warnings;
use strict;
use File::Basename;
use Data::Dumper;

use constant {
    PLUGINNAME => 'Recurse Into',
    PLUGINDESCRIPTION => 'If dir is found, which is known to hold data of a program collection like .local/.kde, recurse into this
    Info is marked within SimpleDB Description containing "RECURSIVE" as keyword',
    PLUGINAUTHOR => 'Henning Mersch',
    PLUGINAUHTORCONTACT => 'Webpage: http://www.henning-mersch.de',
    PLUGINKEYPROPOSAL => 'r', #required to be an Action Plugin
    PLUGINDISABLED => 0,
};

my @data = (".kde",".local");

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
  my $self = shift;
  my $file = shift;
  
  return "";
}

# couldProcess()
# if this plugin could process this file, return a descriptive String
# otherwise return a empty string
sub couldProcess {
  my $self = shift;
  my $item = shift;
  my $file = basename($item);
  
  if($main::pluginHash{a}->getFileInfo($item) && $main::pluginHash{a}->getFileInfo($item)->{"AppDescription"} =~ /.*RECURSIVE.*/) {
	return "Recurse into known multi-config-holding ".$file." ?";
  }
  
  return "";
}

# process()
# process the file - eventually by interacting with user
# return TRUE if file is deleted or finally processed in any way
# return FALSE if other plugins should be able to process $file again
sub process {
  my $self = shift;
  my $file = shift;
  my @newdirs = glob("$file/*");
  unshift(@main::dirs, @newdirs);
  return 1;
}


1;
