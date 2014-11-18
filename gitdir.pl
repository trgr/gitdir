#!/usr/bin/perl
use strict;

use Cwd;
use Data::Dumper;

our $CONSOLE_OUTPUT_MAX_SPACING = 20;

#################
#BEGIN FUNCTIONS#
#################
sub getDirContents{
		my $dirname = shift;
		my @contents;
		
		opendir( DIR , $dirname ) or die $!;
		@contents = readdir(DIR);
		closedir( DIR);
		
		return @contents;

}

# Ttakes a basedir and a list of strings
# Filters out those strings that resolve to directories from basedir and is not "." or ".."
sub filterDirectories{
		my $basedir = shift;
		my @dirContents = @_;
		
		#remove files
		my @filteredDirContents = map { (-d createPath($basedir,$_) ) ? $_ : () }  @dirContents;

		#remove "." and ".."
		@filteredDirContents = map /^\.$|^\.\.$/ ? () : $_ , @filteredDirContents;
		
		return @filteredDirContents;
		
}


sub createPath{ return join( "/" , @_ ) }

#Prints out a human readable table
sub printRow{
		my $numSpaces = $CONSOLE_OUTPUT_MAX_SPACING - length(@_[0]);
		my $sep = " " x $numSpaces;		
		my $out = join($sep, @_ );

		print $out;
}

sub gitStatus{
		my $dir = shift;
		my $lastcwd = getcwd();
		my @cmd = `cd $dir && git status --porcelain -s -b && cd $lastcwd`;
		return $cmd[0]
}

###############
#BEGIN PROGRAM#
###############

#Default basedir to current cwd
my $basedir = getcwd();;
while( my $opt = pop(@ARGV) ){
		if ( $opt eq "--help" ){
				print "Usage: $0 [dir]\n";
				print "Outputs the git status of all subdirectories of specified dir. \nIf no dir is specified, $0 defaults to current working directory.\n\n";
				print "--help\tPrint this help\n";
				exit;
		}

		if( -d $opt ){
				$basedir = $opt;
		}else{
				die( "$opt is not a directory");
		}
}


my @contents   = getDirContents( $basedir );

my @directories = filterDirectories( $basedir, @contents );


while( my $dir = pop(@directories) ){
		my $gitpath = createPath( $basedir , $dir , ".git" );
		
		if( -d $gitpath ){
				printRow( $dir , gitStatus( createPath( $basedir , $dir ) ) );
		}
}
