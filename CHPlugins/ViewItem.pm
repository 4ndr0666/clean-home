package ViewItem;

use warnings;
use strict;
use Data::Dumper;

use constant {
    PLUGINNAME => 'ViewItem',
    PLUGINDESCRIPTION => 'View the item - first lines (if file) or contained elements (if directory)',
    PLUGINAUTHOR => 'Henning Mersch',
    PLUGINAUHTORCONTACT => 'Webpage: http://www.henning-mersch.de',
    PLUGINKEYPROPOSAL => 'v', #required to be an Action Plugin
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
  if(-f $file) {return "$file is a FILE ";}
  elsif (-d $file) {return "$file is a DIRECTORY";}
  else {return "";}
}

# couldProcess()
# if this plugin could process this file, return a descriptive String
# otherwise return a empty string
sub couldProcess {
  my $self = shift;
  my $file = shift;
  if(-f $file) {return "View first 10 lines from file '$file'";}
  elsif (-d $file) {return "View first 10 subfiles of diretory '$file'";}
  else {return "";}
}

# process()
# process the file - eventually by interacting with user
# return TRUE if file is deleted or finally processed in any way
# return FALSE if other plugins should be able to process $file again
sub process {
	my $self = shift;
	my $file = shift;
	
	if(-f $file) {
		open (F, $file) || die ("Could not open $file!");
		print "Viewing File $file, 10 lines\n----------------\n";
		my $i=0;
		while (defined(<F>) && (my $line = <F>) && $i < 10) {
			print $line;
			$i = $i+1;
		}
		print "----------------\n";
	} elsif (-d $file) {
		print "Viewing Directory $file, 10 items\n----------------\n";
		my $i=0;
		opendir (DIR, $file) or die "Couldn't open directory, $!";
		while ( defined(my $line = readdir DIR) && $i < 10) {
			if($line eq "." || $line eq "..") {next;}
			print $line."\n";;
			$i = $i+1;
		}
		print "----------------\n";

	}
	return 0;
}


1;
