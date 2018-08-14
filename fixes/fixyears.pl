#!/usr/local/Cellar/perl/5.26.0/bin/perl

use Date::Calc qw/Delta_Days/;
use LWP::Simple;
use HTML::TableExtract qw(tree);
use DBI;
use DBD::mysql;
use Data::Dumper;

my $curdir = `pwd`;
chomp $curdir;
my $dbh = DBI->connect("DBI:mysql:mysql_read_default_file=$curdir/dbi.conf;mysql_read_default_group=history", undef, undef, {});

my $birthdatequery = "select birthdate from birthdate where nameurl = ?";
my $birthsth = $dbh->prepare($birthdatequery);

my $battersquery = "select nameurl, name, year from batters";
my $battersth = $dbh->prepare($battersquery);

my $ageupdatequery = "update batters set age=? where nameurl=? and year=?";
my $ageupdatesth = $dbh->prepare($ageupdatequery);

$battersth->execute;

$i = 0;
while (@row = $battersth->fetchrow_array()) {
    my ($nameurl, $name, $year) = @row;

    my $age = findAge($nameurl, $year); 
   
    $ageupdatesth->execute($age, $nameurl, $year);
    $i++;

    if ($i % 100) {
    } else {
      print "Updated $i....\n";
      print "AGE $age NAMEURL $nameurl YEAR $year\n";
    } 
}

exit 0;

sub findAge {
    my ($uid, $statyear) = @_;
    
    
    $birthsth->execute($uid);
    $resultsflag = false;
    if (@data = $birthsth->fetchrow_array()) {
        $resultsflag = true;
        my @date = split("-", $data[0]);
        $date[2] =~ s|^([0-9]+) .*|$1|;
        
        my($day, $month, $year)=(localtime)[3,4,5];
        my @today = ($statyear, 4, 1);

        my $dd = Delta_Days(@date, @today);

        return ($dd / 365 ) ;
    }
    
}

