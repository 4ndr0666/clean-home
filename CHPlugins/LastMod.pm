package LastMod;

use warnings;
use strict;

use constant {
    PLUGINNAME => 'LastMod',
    PLUGINDESCRIPTION => 'Info about last modified file, recursively',
    PLUGINAUTHOR => 'Henning Mersch',
    PLUGINAUHTORCONTACT => 'Webpage: http://www.henning-mersch.de',
    PLUGINKEYPROPOSAL => '', #required to be an Action Plugin
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
  my $self = shift;
  my $file = shift;

  if(! -e $file) {return "no file: $file"}

  my $newest = $self->newestFile($file); 
  return "Last modification time, recursively: ".scalar(localtime($newest));
}

# couldProcess()
# if this plugin could process this file, return a descriptive String
# otherwise return a empty string
sub couldProcess {
	return "";
}

# process()
# process the file - eventually by interacting with user
# return TRUE if file is deleted or finally processed in any way
# return FALSE if other plugins should be able to process $file again
sub process {
  return 0;
}

sub newestFile{
  my $self = shift;
  my $file = shift;
  if(-d $file) {
	my $newest = (stat($file))[9];
	for my $subFile (glob("$file/*")) {
		my $sub = $self->newestFile($subFile);
		if (! $newest) {$newest = $sub;}
		elsif ($sub && $sub > $newest) { $newest = $sub; }
	}
	return $newest;
  } else {
	return (stat($file))[9];
  }
}
	
1;
