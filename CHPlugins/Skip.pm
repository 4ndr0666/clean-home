package Skip;

use warnings;
use strict;

use constant {
    PLUGINNAME => 'Skip',
    PLUGINDESCRIPTION => 'Skip current dir/file',
    PLUGINAUTHOR => 'Henning Mersch',
    PLUGINAUHTORCONTACT => 'Webpage: http://www.henning-mersch.de',
    PLUGINKEYPROPOSAL => 's', #required to be an Action Plugin
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
  return "Skip '$file'";
}

# process()
# process the file - eventually by interacting with user
# return TRUE if file is deleted or finally processed in any way
# return FALSE if other plugins should be able to process $file again
sub process {
  my $self = shift;
  my $file = shift;
  return 1;
}


1;
