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
my %end;
my $templateFile;
GetOptions (
  "start=s"=>\$start{input},
  "end=s"=>\$end{input},
  "template=s"=>\$templateFile,
);

# check the start date, if given
if(defined $start{input}){
    ($start{year},$start{month},$start{day}) = split(/-/,$start{input});
    # validate the start date - this will exit if there's an error
    $start{date} = DateTime->new(year => $start{year}, month => $start{month}, day => $start{day});
    $start{DayName} = $start{date}->day_name;
    # remove leading zeros, which stops things like 0003
    $start{day} =~ s/^0+//;
    $start{month} =~ s/^0+//;
    $start{day} = ($start{day}<10) ? "0".$start{day} : $start{day};
    $start{month} = ($start{month}<10) ? "0".$start{month} : $start{month};
} else {
    # today's date - default if $start{input} is not given
    ($start{day}, $start{month}, $start{year}) = (localtime)[3..5];
    $start{year} += 1900;
    $start{month} += 1;
    $start{date} = DateTime->new(year => $start{year}, month => $start{month}, day => $start{day});
    $start{DayName} = $start{date}->day_name;
    
    # fix the day and month to include a 0
    $start{day} = ($start{day}<10) ? "0".$start{day} : $start{day};
    $start{month} = ($start{month}<10) ? "0".$start{month} : $start{month};
}

# all the checks have been done, so the $startDate can be formed
$start{print} = $start{DayName}." ".$start{year}."-".$start{month}."-".$start{day};

# check the end date, if given
if(defined $end{input}){
    ($end{year},$end{month},$end{day}) = split(/-/,$end{input});
    # validate the end date - this will exit if there's an error
    $end{date} = DateTime->new(year => $end{year}, month => $end{month}, day => $end{day});
    $end{DayName} = $end{date}->day_name;
    # remove leading zeros, which stops things like 0003
    $end{day} =~ s/^0+//;
    $end{month} =~ s/^0+//;
    $end{day} = ($end{day}<10) ? "0".$end{day} : $end{day};
    $end{month} = ($end{month}<10) ? "0".$end{month} : $end{month};
} else { 
    # tomorrow's date - default if $end{input} is not given
    ($end{day}, $end{month}, $end{year}) = (localtime(time+86400))[3..5];
    $end{year} += 1900;
    $end{month} += 1;
    $end{date} = DateTime->new(year => $end{year}, month => $end{month}, day => $end{day});
    $end{DayName} = $end{date}->day_name;
    
    # fix the day and month to include a 0
    $end{day} = ($end{day}<10) ? "0".$end{day} : $end{day};
    $end{month} = ($end{month}<10) ? "0".$end{month} : $end{month};
}

# all the checks have been done, so the $endDate can be formed
$end{print} = $end{DayName}." ".$end{year}."-".$end{month}."-".$end{day};

# check to see if dates make sense (start needs to be before end)
if ($start{date}>$end{date}){
  print "Your start date is after your end date: exiting \n";
  exit 0;
}

# XML parsing starts here
my $filename = (defined $templateFile) ? $templateFile : 'blank-day-template.txt';
my $parser = XML::LibXML->new();
my $doc = $parser->parse_file($filename);

print "start = ",$start{print},"\n";
print "end = ",$end{print},"\n";
print "start = ",$start{date},"\n";
print "end = ",$end{date},"\n";

# need a variable for XML replacement
my $node;
while($start{date}<=$end{date}){
    (my $tmp=$start{date}) =~ s/T.*//;
    # change the date
    ($node) = $doc->findnodes('/day/date');
    $node->removeChildNodes();
    $node->appendText($tmp);

    # change the day
    ($node) = $doc->findnodes('/day/day-number');
    $node->removeChildNodes();
    $node->appendText($start{date}->day);
    
    # change the day-name
    ($node) = $doc->findnodes('/day/day-name');
    $node->removeChildNodes();
    $node->appendText($start{date}->day_name());

    # change the month-name
    ($node) = $doc->findnodes('/day/month-name');
    $node->removeChildNodes();
    $node->appendText($start{date}->month_name());

    # change the year
    ($node) = $doc->findnodes('/day/year');
    $node->removeChildNodes();
    $node->appendText($start{date}->year());
    
    print $doc->toString();
    $start{date}->add(days=>1);
}

exit;
