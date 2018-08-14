#!/usr/local/Cellar/perl/5.22.0/bin/perl

use DBI;
use DBD::mysql;

my $curdir = `pwd`;
chomp $curdir;
my $dbh = DBI->connect("DBI:mysql:mysql_read_default_file=$curdir/dbi.conf;mysql_read_default_group=history", undef, undef, {});

print "delete adjustedstats...\n";
my $isth = $dbh->prepare("delete adjustedstats from adjustedstats inner join batters on batters.uid=adjustedstats.uid where batters.year=2018");
$isth->execute();

print "delete stats...\n";
my $isth = $dbh->prepare("delete stats from stats inner join batters on batters.uid=stats.uid where batters.year=2018");
$isth->execute();

print "delete weightedcompwins...\n";
my $isth = $dbh->prepare("delete weightedcompwins from weightedcompwins inner join batters on batters.uid=weightedcompwins.uid where batters.year=2018");
$isth->execute();

print "delete batters...\n";
my $isth = $dbh->prepare("delete from batters where year=2018");
$isth->execute();

print "delete leaguestats...\n";
my $isth = $dbh->prepare("delete from leaguestats where year=2018");
$isth->execute();

print "delete adjustedcomps...\n";
my $isth = $dbh->prepare("delete from adjustedcomps where year=2018");
$isth->execute();

print "delete comps...\n";
my $isth = $dbh->prepare("delete from comps where year=2018");
$isth->execute();

system("./current/currentparseleaderbords.pl > log 2>&1");

system("./current/currentstats.pl");
system("./current/currentaverageleague.pl");
system("./current/currentadjustedstats.pl");
system("./current/adjcomputedistance.py 2018");
system("./current/weightedcompwins.pl 2018");

# TO DO : pitching comps
my $isth = $dbh->prepare("delete pitcherstats from pitcherstats inner join pitchers on pitchers.uid=pitcherstats.uid where pitchers.year=2018");
$isth->execute();
my $isth = $dbh->prepare("delete pitchingweightedcompwins from pitchingweightedcompwins inner join pitchers on pitchers.uid=pitchingweightedcompwins.uid where pitchers.year=2018");
$isth->execute();
my $isth = $dbh->prepare("delete from pitchers where year=2018");
$isth->execute();
#my $isth = $dbh->prepare("delete from leaguestats where year=2018");
#$isth->execute();
my $isth = $dbh->prepare("delete from pitchercomps where year=2018");
$isth->execute();

exit 0;
