#!/usr/bin/perl
#
# Need to install XML::LibXML which 
# I did using:
#
#   sudo apt-get install libxml-libxml-perl
# 
# If this doesn't work, let me know
#
# Demonstrations of XML::LibXML
#   http://www.perlmonks.org/?node_id=490846
#   http://stackoverflow.com/questions/154762/how-can-i-create-xml-from-perl
#   http://stackoverflow.com/questions/8411684/xmllibxml-replace-element-value

# load the perl modules
use strict;         # strict and warnings should, imho, always be loaded
use warnings;       # to help find coding mistakes
use XML::LibXML;    # to process the XML
use Getopt::Long;   # to get the switches/options/flags
use DateTime;

# read the arguments
my %start;
my $endDate;
GetOptions (
  "start=s"=>\$start{input},
  "end=s"=>\$endDate,
);

# today's date
($start{day}, $start{month}, $start{year}) = (localtime)[3..5];
$start{year} += 1900;
$start{month} += 1;

my $dt = DateTime->new(year => $start{year}, month => $start{month}, day => $start{day});
$start{DayName} = $dt->day_name;

# fix the day and month to include a 0
$start{day} = ($start{day}<10) ? "0".$start{day} : $start{day};
$start{month} = ($start{month}<10) ? "0".$start{month} : $start{month};

# tomorrow's date
my ($day, $month, $year) = (localtime(time+86400))[3..5];
$year += 1900;
$month += 1;

$dt = DateTime->new(year => $year, month => $month, day => $day);
my $endDayName = $dt->day_name;

# fix the day and month to include a 0
my $endDay = ($day<10) ? "0".$day : $day;
my $endMonth = ($month<10) ? "0".$month : $month;

# check the start date, if given
if(defined $start{input}){
    ($year,$month,$day) = split(/-/,$start{input});
    # validate the start date - this will exit if there's an error
    $dt = DateTime->new(year => $year, month => $month, day => $day);
    # remove leading zeros, which stops things like 0003
    $day =~ s/^0+//;
    $month =~ s/^0+//;
    $start{day} = ($day<10) ? "0".$day : $day;
    $start{month} = ($month<10) ? "0".$month : $month;
} 

# all the checks have been done, so the $startDate can be formed
$start{date} = $start{DayName}." ".$year."-".$start{month}."-".$start{day};

# check the end date, if given
if(defined $endDate){
    ($year,$month,$day) = split(/-/,$endDate);
    # validate the end date - this will exit if there's an error
    $dt = DateTime->new(year => $year, month => $month, day => $day);
    # remove leading zeros, which stops things like 0003
    $day =~ s/^0+//;
    $month =~ s/^0+//;
    $endDay = ($day<10) ? "0".$day : $day;
    $endMonth = ($month<10) ? "0".$month : $month;
} 

# all the checks have been done, so the $endDate can be formed
$endDate = $endDayName." ".$year."-".$endMonth."-".$endDay;

#$endDate = (defined $endDate) ? $endDate : $endDayName." ".$year."-".$endMonth."-".$endDay;

print "start = ",$start{date},"\n";
print "end = ",$endDate,"\n";

my $filename = 'blank-day-template.txt';
# my $filename = 'library.xml';

my $parser = XML::LibXML->new();
my $doc    = $parser->parse_file($filename);

my ($node) = $doc->findnodes('/day/date');
$node->removeChildNodes();
$node->appendText('394');

($node) = $doc->findnodes('/day/day-name');
$node->removeChildNodes();
$node->appendText('cmh is king!');

print $doc->toString();

exit;
