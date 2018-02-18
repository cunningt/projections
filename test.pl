#!/usr/local/Cellar/perl/5.22.0/bin/perl

use DBI;
use DBD::mysql;
use Math::Complex;

my $curdir = `pwd`;
chomp $curdir;
my $dbh = DBI->connect("DBI:mysql:mysql_read_default_file=$curdir/dbi.conf;mysql_read_default_group=history", undef, undef, {});

my $playerquery = "select uid, age, pa, ab, h, doubles, triples, hr, bb, league, level, so from batters";

my $leaguesth = $dbh->prepare($leaguequery);
my $playersth = $dbh->prepare($query);

my $playersth = $dbh->prepare($playerquery);

$i = 0;

$playersth->execute;
while (@data = $playersth->fetchrow_array()) {
    #uid, age, pa, ab, h, doubles, triples, hr, bb, league
    my $uid = $data[0];
    my $age = $data[1];
    my $pa = $data[2];
    my $ab = $data[3];
    my $h = $data[4];
    my $doubles = $data[5];
    my $triples = $data[6];
    my $hr = $data[7];
    my $bb = $data[8];
    my $league = $data[9];
    my $level = $data[10];
    my $so = $data[11];
 
    if ($i % 100) {
    } else {
      print "Updated $i....\n";
      print "UID $uid ISOP $isop BBRATE $bbrate KRATE $krate WOBA $woba\n";
    } 
    $i++;
}
