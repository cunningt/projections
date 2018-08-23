#!/usr/local/Cellar/perl/5.22.0/bin/perl

use DBI;
use DBD::mysql;

my $curdir = `pwd`;
chomp $curdir;
my $dbh = DBI->connect("DBI:mysql:mysql_read_default_file=$curdir/dbi.conf;mysql_read_default_group=history", undef, undef, {});

my $year = defined($ARGV[0]) ? shift(@ARGV) : "2018";

print "delete adjustedstats...\n";
my $isth = $dbh->prepare("delete adjustedstats from adjustedstats inner join batters on batters.uid=adjustedstats.uid where batters.year=?");
$isth->execute($year);

print "delete stats...\n";
my $isth = $dbh->prepare("delete stats from stats inner join batters on batters.uid=stats.uid where batters.year=?");
$isth->execute($year);

print "delete weightedcompwins...\n";
my $isth = $dbh->prepare("delete weightedcompwins from weightedcompwins inner join batters on batters.uid=weightedcompwins.uid where batters.year=?");
$isth->execute($year);

print "delete leaguestats...\n";
my $isth = $dbh->prepare("delete from leaguestats where year=?");
$isth->execute($year);

print "delete adjustedcomps...\n";
my $isth = $dbh->prepare("delete from adjustedcomps where year=?");
$isth->execute($year);

print "delete comps...\n";
my $isth = $dbh->prepare("delete from comps where year=?");
$isth->execute($year);

print "delete batters...\n";
my $isth = $dbh->prepare("delete from batters where year=?");
$isth->execute($year);

system("./current/parseteampages.pl $year > log 2>&1");
system("./current/currentstats.pl $year");
system("./current/currentaverageleague.pl $year");
system("./current/currentadjustedstats.pl $year");
system("./current/adjcomputedistance.py $year");
system("./current/weightedcompwins.pl $year");

exit 0;
