#!/usr/local/Cellar/perl/5.22.0/bin/perl

use DBI;
use DBD::mysql;
use Math::Complex;

my $curdir = `pwd`;
my $pamin = 50;

chomp $curdir;
my $dbh = DBI->connect("DBI:mysql:mysql_read_default_file=$curdir/dbi.conf;mysql_read_default_group=history", undef, undef, {});

my $year = defined($ARGV[0]) ? shift(@ARGV) : "2017";

my $rankingsquery = "select b.uid, b.nameurl, b.name, b.level, b.league, b.team, b.age, c.war_off, c.runs_above_avg_off from batters b, weightedcompwins c where b.year = ? and b.uid = c.uid and b.pa > ? order by c.runs_above_avg_off desc";

my $insertquery = "insert into backtestranking(uid, nameurl, level, ranking, year, commithash) VALUES (?, ?, ?, ?, ?, ?)";

my $rankingsth = $dbh->prepare($rankingsquery);
my $insertsth = $dbh->prepare($insertquery);

$rankingsth->execute($year, $pamin);
my $rankcounter = 1;
while (@data = $rankingsth->fetchrow_array()) {
    my $counter = 0;
    my $uid = $data[$counter++];
    my $nameurl = $data[$counter++];
    my $name = $data[$counter++];
    my $level = $data[$counter++];
    my $league = $data[$counter++];
    my $team = $data[$counter++];
    my $age = $data[$counter++];
    my $war_off = $data[$counter++];
    my $rar_off = $data[$counter++];

    $insertsth->execute($uid, $nameurl, $level, $rankcounter++, $year, "AAA");
}

$insertsth->finish;

exit 0;
