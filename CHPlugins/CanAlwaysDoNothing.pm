package CanAlwaysDoNothing;

use warnings;
use strict;

use constant {
    PLUGINNAME => 'CanAlwaysDoNothing',
    PLUGINDESCRIPTION => 'Stupid Plugin doing nothing but always saying it could',
    PLUGINAUTHOR => 'Henning Mersch',
    PLUGINAUHTORCONTACT => 'Webpage: http://www.henning-mersch.de',
    PLUGINKEYPROPOSAL => 'c', #required to be an Action Plugin
    PLUGINDISABLED => 1,
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
  my $self = shift;
  my $file = shift;
  if(-d $file) {return "Dir '$file' is NOT interesting !";}
  elsif(-f $file) {return "File '$file' is quite interesting !";}
  else {return "'$file' is confusing me - no file and no dir ?!";}
}

# couldProcess()
# if this plugin could process this file, return a descriptive String
# otherwise return a empty string
sub couldProcess {
  my $self = shift;
  my $file = shift;
  if(-d $file) {return ""; }# we cant handle directories :-) 
  elsif(-f $file) {return "File '$file' could be processed by doing nothing :-) !";}
  else {return "'$file' is confusing me - no file and no dir ?!";}
}

# process()
# process the file - eventually by interacting with user
# return TRUE if file is deleted or finally processed in any way
# return FALSE if other plugins should be able to process $file again
sub process {
  my $self = shift;
  my $file = shift;
  print "I'm doing nothing\n";
  return 1;
}


1;
