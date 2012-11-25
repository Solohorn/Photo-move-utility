# Photo Move utility
#
# Using EXIF data encoded in JPEG file, creates a folder corresponding the date, e.g., YYYY_MM_DD, and moves file to the folder
# If no date is encoded in the EXIF metadata, moves the file to the BADEXIF folder

use strict;
use Image::EXIF;
use Data::Dumper;
use Image::EXIF::DateTime::Parser;
use File::Copy "move";
use File::Path qw(make_path);

my ($imageFile, $exif, $image_info, $parser, $imageTimeStamp, $folder);
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst);

$parser = Image::EXIF::DateTime::Parser->new;

while (glob("*.jpg")) {
	$imageFile = $_;
	$exif = Image::EXIF->new($imageFile);
	$image_info = $exif->get_image_info();
#	print "$imageFile info\n";
#	print Dumper($image_info);
	eval { $imageTimeStamp = $parser->parse($image_info->{'Image Created'}) . "\n\n"; };
	if ($@) {
		$folder = "BADEXIF";
	} else {
		($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($imageTimeStamp);
		$folder = sprintf("%s_%02s_%02s", $year+1900, $mon+1, $mday);
	}
#	print "$folder\n";
	make_path($folder);
	move("./$imageFile","./$folder/$imageFile") || die "Failed to move file: $!\n";
}