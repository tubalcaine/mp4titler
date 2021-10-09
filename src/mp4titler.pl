#! /usr/bin/perl

## Some dev notes:
#
# I like to use PAR::Packer to make perl scripts into self-contained binaries sometimes.
# Before doing that, I would probably want to use something like Getopt::Long to
# parameterize the $pattern and the $mod setting, and to have if $mod is zero, no
# run time output. I may do that in my non-existant spare time.
#
# This code is just public domain. There is nothing here that needs licensing. Do what
# you like with it.
#
# Written by Michael Schwarz
# mschwarz at multitool dot net


use strict;

use Image::ExifTool;
use Data::Dumper;
use File::Find;
use File::Basename;

# Regular expression used to match files
my $pattern = "\\.mpeg|\\.mp4|\\.m4v";

if ( ( scalar @ARGV ) < 1 ) {
	print
"Usage:\n\nmp4titler <dirlist>\n\nYou must specify one or more directories to search for $pattern files.\n\n";
	print << "EOF";
The purpose of this script is to use the base name of media files as the Title
field of the media metadata, adding or replacing as necessary.

It was developed by Michael Schwarz (mschwarz at multitool dot net) to
easily manage and assign titles to MP4 video files from various devices that
either do not assign titles or assign meaningless titles.

This recursively iterates over one or more directories given on the command line
and processes any files matching the regular expression given in the anonymous
function in the call to find().

It should be able to handle ANY format that the CPAN library Image::ExifTool
supports.

The variable \$mod determines how many files are processed between activity updates
on the screen. Set it to 0 to get no progress messages.
EOF
	exit 1;
}

# File match count
my $fc = 0;
# Modulo to report progress, report every $mod files
my $mod = 3;

find(
	{
		no_chdir => 1,
		wanted   => sub {
			return if ( !/$pattern/i );
			
			$fc++;
			print "Processed $fc files\r" if ($mod && $fc % $mod == 0);
			select()->flush() if ($mod && $fc % $mod == 0);
			
			my ( $title, $a2, $a3, $a4 ) = fileparse($_);
			$title =~ s/\.[^.]*$//;

			if ( setTitle( $File::Find::name, $title ) ) {
			}
			else {
				print "\nRetitled [$File::Find::name], file # $fc to [$title]\n";
			}
		}
	},
	@ARGV
);

print "\nExamined $fc files total.\n";

exit 0;



# Change the title of $filename to $title. Returns 0 on success.
sub setTitle {
	my ( $filename, $title ) = @_;

	my $et   = new Image::ExifTool;
	$et->Options("LargeFileSupport", 1);
	my $info = $et->ImageInfo($filename);

	return 1 if ( $info->{Title} eq $title );

	print "\n";
	print( ( $info->{Title} eq $title ) ? "EQUAL\t" : "Unequal\t" );
	print "Title b4 [$info->{Title}] after [$title]\n";

	my $rc = $et->SetNewValue( Title => $title );
	
	# Whatever we did, we need to write it out.
	my $result = $et->WriteInfo($filename);
	
	if (!$result) {
		print "\nFile $fc\nError on [$filename] ";
		print $et->GetValue("Error");
		print "\n\n";
	}
	
	return !$result;
}

