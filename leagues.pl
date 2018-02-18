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

my $query = "insert into leagues(league, level, leaguehash, year) VALUES (?, ?, ?, ?)";
my $isth = $dbh->prepare($query);

my %league_hash = (
"PCL" => "AAA",
"IL" => "AAA", 
"EL" => "AA",
"TL" => "AA",
"SOUL" => "AA",
"CALL" => "A+",
"CARL" => "A+",
"FLOR" => "A+",
"SALL" => "A",
"MIDW" => "A",
"NORW" => "A-",
"NYPL" => "A-",
"APPY" => "Rk",
"PION" => "Rk",
"GULF" => "Rk",
"ARIZ" => "Rk"
);

my $urltemplate = "https://www.baseball-reference.com/register/league.cgi?code=%code%&class=%class%";

foreach $code (keys %league_hash) {
   my $class = $league_hash{$code};
   my $url = $urltemplate;

   $url =~ s|%code%|$code|;
   $url =~ s|%class%|$class|;

   print "$league ... fetching data [$url]...\n";
   insertLeagues($url, $code, $class);
}
exit 0;


sub findAge {
    my ($url, $name) = @_;
    
    $nameurl = $url;
    $nameurl =~ s|.*id=||;
    
    $birthsth->execute($nameurl);
    $resultsflag = false;
    if (@data = $birthsth->fetchrow_array()) {
        $resultsflag = true;
        my @date = split("-", $data[0]);
        $date[2] =~ s|^([0-9]+) .*|$1|;
        
        my($day, $month, $year)=(localtime)[3,4,5];
        my @today = (1900 + $year, 1 + $month, $day);
        
        my $dd = Delta_Days(@date, @today);
        return ($dd / 365 ) ;
    }
    
    # We can't find the birthdate in the db, need to query it from B-R.com
    $page = get("http://www.baseball-reference.com/". $url);
    if ($page =~ m|data-birth=\"([^\"]+)\"|g) {
        $age = $1;
        my @date = split("-", $age);
        print "DATE @date \n";
        
        # Insert the ID/birthdate into the database
        if ($resultsflag == false) {
            $birthinsertsth->execute($nameurl, $name, $age);
        }
        
        my($day, $month, $year)=(localtime)[3,4,5];
        my @today = (1900 + $year, 1 + $month, $day);
        
        my $dd = Delta_Days(@date, @today);
        
        return ($dd / 365 ) ;
    }
}

sub insertLeagues {
	my ($url, $code, $class) = @_;
	print "URL $url\n";
	my $page = get($url);
	#print "PAGE [$page]\n";
    
    while ($page =~ m|register\/league.cgi\?id=([a-z0-9]+)\"\>([0-9]+)|g) {
        print "EXECUTE $code, $class, $1, $2\n";
        $isth->execute($code, $class, $1, $2);
    }
    
}
