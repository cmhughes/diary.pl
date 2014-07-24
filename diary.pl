#!/usr/bin/perl
# diary.pl
#
# PURPOSE:
#   read in an XML template from a file,
#   together with START dates and END dates (optional) and append the XML 
#   with dates in between START and END. It appends the footer file 
#   to the end. A check is done on the START and END dates, and the 
#   script will exit if the dates are not valid.
#
# USAGE
#   diary.pl --start=yyyy-mm-dd --end=yyyy-mm-dd --template=<filename> --footer=<filename>
#
#   All of the flags are *optional*:
#       --start=yyyy-mm-dd is the start date, given in ISO format
#         default value is today's date
#       --end=yyyy-mm-dd is the end date, given in ISO format
#         default value is tomorrow's date
#       --template=<filename> is the name of the template
#         default value is default: blank-day-template.txt
#       --footer=<filename> is the name of the footer file
#         default: other-blank-templates.txt
#
# SAMPLE USAGE
#   You can either run
#       perl diary.pl
#   or, if you choose to make the file executable (chmod +x diary.pl), then you can simply run 
#       diary.pl
#   You might like to put diary.pl (together with the template files) in /usr/local/bin, or 
#   otherwise put it somewhere else and then update your PATH variable. 
#
#   1. Running
#           diary.pl
#      will output to diary-<today's date>-to-<tomorrow's date>.xml
#   2. Running
#           diary.pl --start=2014-07-24 --end=2014-09-21
#      will output to diary-2014-07-24-to-2014-09-21.xml
#   3. Running
#           diary.pl --start=2014-02-31
#      will cause an error, as there are not 31 days in February
#   4. Running
#           diary.pl --start=2014-7-24 --end=2014-9-21
#      will output to diary-2014-07-24-to-2014-09-21.xml
#      as the script knows to add in the extra 0s
#
# REQUIRED PERL modules
#   Need to install XML::LibXML which 
#   I did using:
#
#     sudo apt-get install libxml-libxml-perl
#   
#   If this doesn't work, let me know
#
# DEMONSTRATIONS of XML::LibXML
#   http://www.perlmonks.org/?node_id=490846
#   http://stackoverflow.com/questions/154762/how-can-i-create-xml-from-perl
#   http://stackoverflow.com/questions/8411684/xmllibxml-replace-element-value
# DateTime module reading
#   http://search.cpan.org/~drolsky/DateTime-1.10/lib/DateTime.pm

# load the perl modules
use strict;         # strict and warnings should, imho, always be loaded
use warnings;       # to help find coding mistakes
use XML::LibXML;    # to process the XML
use Getopt::Long;   # to get the switches/options/flags
use DateTime;       # for Date and Time manipulations/calculations

# read the arguments
my %start;
my %end;
my $templateFile;
my $footerFile;
GetOptions (
  "start=s"=>\$start{input},
  "end=s"=>\$end{input},
  "template=s"=>\$templateFile,
  "footer=s"=>\$footerFile,
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

# all the checks have been done, so the $start{print} can be formed
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

# all the checks have been done, so the $end{print} can be formed
$end{print} = $end{DayName}." ".$end{year}."-".$end{month}."-".$end{day};

# check to see if dates make sense (start needs to be before end)
if ($start{date}>$end{date}){
  print "Your start date is after your end date: exiting \n";
  exit 0;
}

# set up name of output file, and diary tags
my %diary;
$diary{tag} = "".$start{year}."-".$start{month}."-".$start{day}."-to-".$end{year}."-".$end{month}."-".$end{day};

# open the diary file
my $diaryfile;
open($diaryfile,">","diary-$diary{tag}.xml") or die "Can't open $diary{tag}.xml";

# print the header to the diary file
print $diaryfile <<ENDQUOTE
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="diary.xsl"?>

<diary-$diary{tag}>
ENDQUOTE
;

# XML parsing starts here
$templateFile = (defined $templateFile) ? $templateFile : 'blank-day-template.txt';
$footerFile = (defined $footerFile) ? $footerFile : 'other-blank-templates.txt';
my $parser = XML::LibXML->new();
my $doc = $parser->parse_file($templateFile);

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
    
    # ugly hack to remove <?xml version.*?> - I'm not proud of it
    # and hope to change it
    $tmp = $doc->toString();
    $tmp =~ s/<\?xml.*\?>//;
        
    print $diaryfile $tmp;
    $start{date}->add(days=>1);
}

# close the diary tag
print $diaryfile <<ENDQUOTE

</diary-$diary{tag}>

<!--
ENDQUOTE
;

# print the 'footer' to the diary file
open(FOOTER, $footerFile) or die "Could not open $footerFile";
while(<FOOTER>){
    print $diaryfile $_;
}
close(FOOTER);

# last comment
print $diaryfile "-->";
close($diaryfile);
exit;
