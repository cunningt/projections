#!/usr/local/Cellar/perl/5.22.0/bin/perl

use DBI;
use DBD::mysql;
use Math::Complex;

my $curdir = `pwd`;
my $pamin = 50;

chomp $curdir;
my $dbh = DBI->connect("DBI:mysql:mysql_read_default_file=$curdir/dbi.conf;mysql_read_default_group=history", undef, undef, {});

my $year = defined($ARGV[0]) ? shift(@ARGV) : "2017";

my $rankingsquery = "select nameurl, level, ranking, year, commithash from backtestranking where year = ? order by ranking asc";
my $scorequery = "select s.runs_above_avg_off from summedwins s, nameurl n where n.brminorid = ? and s.nameurl=n.brid";

my $insertquery = "insert into backtestscore(year, score, commithash, descr) VALUES (?, ?, ?, ?)";

my $rankingsth = $dbh->prepare($rankingsquery);
my $scoresth = $dbh->prepare($scorequery);
my $insertsth = $dbh->prepare($insertquery);

$rankingsth->execute($year);
my $rankcounter = 1;

my $score = 0;
while (@data = $rankingsth->fetchrow_array()) {
    my $counter = 0;
    my $nameurl = $data[$counter++];
    my $level = $data[$counter++];
    my $ranking = $data[$counter++];
    my $year = $data[$counter++];

    $scoresth->execute($nameurl);
    while (@sdata = $scoresth->fetchrow_array()) { 
        print "$ranking $nameurl $sdata[0] $rankcounter\n";
        $score += ($sdata[0] / $rankcounter);
    }
    $rankcounter++;
}
$insertsth->execute($year, $score, "", "");

print "====== $score\n";
$insertsth->finish;

exit 0;


