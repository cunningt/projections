#!/usr/local/Cellar/perl/5.22.0/bin/perl

use DBI;
use DBD::mysql;

my $curdir = `pwd`;
chomp $curdir;
my $dbh = DBI->connect("DBI:mysql:mysql_read_default_file=$curdir/dbi.conf;mysql_read_default_group=history", undef, undef, {});

my $isth = $dbh->prepare("delete pitcherstats from pitcherstats inner join pitchers on pitchers.uid=pitcherstats.uid where pitchers.year=2018");
$isth->execute();
my $isth = $dbh->prepare("delete pitcheradjustedstats from pitcheradjustedstats inner join pitchers on pitchers.uid=pitcheradjustedstats.uid where pitchers.year=2018");
$isth->execute();
my $isth = $dbh->prepare("delete pitchingweightedcompwins from pitchingweightedcompwins inner join pitchers on pitchers.uid=pitchingweightedcompwins.uid where pitchers.year=2018");
$isth->execute();
my $isth = $dbh->prepare("delete from pitchers where year=2018");
$isth->execute();
my $isth = $dbh->prepare("delete from pitchercomps where year=2018");
$isth->execute();
my $isth = $dbh->prepare("delete from adjpitchercomps where year=2018");
$isth->execute();

system("./pitching/parsepitchingleaderboards.pl 2018");
system("./pitching/pitcherstats.pl");
system("./pitching/pitchingaverageleague.pl 2018");
system("./pitching/pitchingadjustedstats.pl 2018");
system("./pitching/pitchingadjcomputedistance.py 2018");
system("./pitching/pitchingweightedcompwins.pl 2018");

exit 0;
