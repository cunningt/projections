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

my $pitcherquery = "select uid, year, team from pitchers";
my $pitchersth = $dbh->prepare($pitcherquery);

my $teamquery = "select league, level from teams where team=? and year=?";
my $teamsth = $dbh->prepare($teamquery);

my $updatequery = "update pitchers set league=?, level=? where uid=?";
my $updatesth = $dbh->prepare($updatequery);

$pitchersth->execute();
$i = 0;
while (@row = $pitchersth->fetchrow_array()) {
    my ($uid, $year, $team) = @row;
    $team =~ s|,[A-Z0-9]+||g;
    my $league = "";
    my $level = "";
    
    $teamsth->execute($team, $year); 
    while (@teamrow = $teamsth->fetchrow_array()) {
        ($league, $level) = @teamrow;
    }
	
    $updatesth->execute($league, $level, $uid);

    $i++;
    if ($i % 100) {
    } else {
      print "Updated $i....\n";
      print "$team $league $level $uid $year\n";
    } 
}

exit 0;


