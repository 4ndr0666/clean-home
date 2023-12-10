#!/usr/bin/perl -w

# CleanHome by Henning Mersch - http://www.henning-mersch.de
# Please read README 
# or visit: http://cleanhome.sourceforge.net
# Licence: GPL

use strict;
use warnings;
use FindBin;
use File::Basename;
use Data::Dumper;

my $chpath = $FindBin::RealBin;
my $chpluginpath = "/usr/share/cleanHome/CHPlugins";

#program version
my $VERSION="0.6";

our @plugins; #plugins could call each others
our %pluginHash;
our @dirs; #List of Dirs could be manipulated by Plugins!

my $debugPluginLoad = 0;



sub loadPlugins {
print "Loading Plugins...";
for my $plugin ( glob("$chpluginpath/*.pm") ) {

    	my ($newplug) = $plugin =~ m!([^/]*).pm!;

    	if ( ! -r $plugin ) {
        	print "\n*** Plugin: Couldn't read file: $!\n";
        	next;
	}
	eval { require $plugin; };
	if ( $@ ) {
		my ($err) = $@ =~ m/^(.*) at.*/;
        	if($debugPluginLoad) {print "\n*** Plugin $newplug failed to load: $@\n";}
        	else{print "\n*** Plugin $newplug failed to load. Missing dependencies? Try '--debugPluginLoad' for more info \n";}
        	next;
	}

	my $plugin = $newplug->new;

	if($plugin->disabled()){
        	print "\n*** Plugin $newplug is disabled\n";
		next;
	}
	if(! $plugin->getKeyProposal() || $plugin->getKeyProposal() eq "") {
		push @plugins, $plugin;
	} elsif (defined($pluginHash{$plugin->getKeyProposal()})) {
		print "\n *** Key Binding Collision for ".$plugin->getKeyProposal().": " .$plugin->getName()."<->".$pluginHash{$plugin->getKeyProposal()}->getName()."\n";
		print " *** REJECTING TO LOAD PLUGIN: ".$plugin->getName()."\n";
	} else {
		$pluginHash{$plugin->getKeyProposal()} = $plugin;
		push @plugins, $plugin;
	}
}
print "Done Plugin Loading. \n";
print "Loaded Plugins:\n";
for my $plugin (@plugins) {
  print "\t'".$plugin->getName()."' by ".$plugin->getAuthor()." <".$plugin->getAuthorContact().">\n";
  print "\t\t".$plugin->getDescription()."\n";
}
if($debugPluginLoad) {print "...exiting due to '--debugPluginLoad'\n"; exit;}
}
sub clearAfterEnter {
	print "\nPress <Enter> to continue";
	<STDIN>;
	system('clear'); 
}

sub investigateDir {
  	my $dir  = shift;
        print "******************************************************************************** Left: $#dirs\n";
	print "************************** Investigating $dir \n";
	#ignore symbolic links since they could lead to loops and dont contain any data to clear (or iff, we dont trust to delete them ;-) 
	if(-l $dir) {
	  print "*** Ignoring $dir since its a symbolic link ***\n";
	  clearAfterEnter();
	  return;
	}
	#gather info from plugins
	print "*** Information ***\n";
	for my $plugin (@plugins) {
		my $info = $plugin->info($dir);
		if($info && $info ne "") {
			$info =~ s/\n//g;
			print "\t'".$plugin->getName()."': $info\n";
		}
	}
	#collect process capabilities
	my %processCaps;
	print "*** Actions ***\n";
	#print "*** 0) No processing / Skip this Dir\n";
	for my $key ( keys %pluginHash ) {
		my $plugin = $pluginHash{$key};
		my $cProcess = $plugin->couldProcess($dir);
		if($cProcess && $cProcess ne "") {
			$cProcess =~ s/\n//g;
			$processCaps{$key} = $plugin;
			print "\tHit: ".$plugin->getKeyProposal(). ") '".$plugin->getName()."': $cProcess\n";
		}
	}
	print "\tHit: <ENTER> to skip to next\n";

	#ask user which plugin to choose for processing
	print "Please choose:";
	my $userChoice = <STDIN>;
	chomp($userChoice);
	my $done = 0;
	print "choosen: '$userChoice' \n";
	#if($userChoice eq "0") {$done = 1;} #skip
	#els
	if(defined($processCaps{$userChoice})) {
		$done = $processCaps{$userChoice}->process($dir);
	} elsif ($userChoice eq "") {
		print "Processing to next\n";
		$done = 1;
	} else {
		print "Cant understand '$userChoice' - restarting this Dir\n";
	}
	clearAfterEnter();
	if(!$done) {investigateDir($dir)} # recursive call, if not finally processed
}

################################################# 
################################################# 
################################################# 
print "CleanHome Version $VERSION by Henning Mersch <cleanhome\@hmersch.de>\n";
################################################# PROCESS everything ".* in $HOME
if(! @ARGV) {
	@dirs = glob("~/.*");
} elsif ($ARGV[0] eq "--debugPluginLoad") {
	print "Just loading plugins and exit\n";
	$debugPluginLoad = 1;
} elsif ($ARGV[0] eq "--help") {
	print "Usage:\n";
	print "\t--startFrom FILE  -- skip processing until FILE\n";
	print "\t--startAfter FILE  -- skip processing until FILE is skipped\n";
	print "\t--debugPluginLoad -- Load all plugins, show errors if existing and exit.\n";
	print "\t--help -- print this help message\n";
	exit 0;
} elsif ($ARGV[0] eq "--startFrom") {
	@dirs = glob("~/.*");
	while($dirs[0] && basename($dirs[0]) ne $ARGV[1]) {
		shift(@dirs);
		# print $ARGV[1]."<-> ".basename($dirs[0])." --> Skipped: ".shift(@dirs)."\n";
	}
	if($dirs[0]) {print "Found requested startfile: $ARGV[1] / $dirs[0]";}
	else {print "Sorry, cant find $ARGV[1]";}
	pop @ARGV;
	pop @ARGV;
} elsif ($ARGV[0] eq "--startAfter") {
	@dirs = glob("~/.*");
	while($dirs[0] && basename($dirs[0]) ne $ARGV[1]) {
		shift(@dirs);
		# print $ARGV[1]."<-> ".basename($dirs[0])." --> Skipped: ".shift(@dirs)."\n";
	}
	shift(@dirs);
	if($dirs[0]) {print "Found requested startfile after skipping: $ARGV[1]";}
	else {print "Sorry, cant find $ARGV[1]";}
	pop @ARGV;
	pop @ARGV;
}
################################################# PREPARE - load plugins

&loadPlugins();

################################################# Start 
clearAfterEnter();
# my $dir = shift(@dirs);
while(my $dir = shift(@dirs)) {
	if(basename($dir) eq ".") {next;}
	if(basename($dir) eq "..") {next;}
	investigateDir($dir);
}

################################################# The END
print "That's all folks for CleanHome $VERSION \n";

__END__
