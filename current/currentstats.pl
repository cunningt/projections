#!/usr/local/Cellar/perl/5.22.0/bin/perl

use DBI;
use DBD::mysql;
use Math::Complex;

my $curdir = `pwd`;
chomp $curdir;
my $dbh = DBI->connect("DBI:mysql:mysql_read_default_file=$curdir/dbi.conf;mysql_read_default_group=history", undef, undef, {});

my $year = defined($ARGV[0]) ? shift(@ARGV) : "2018";

my $playerquery = "select uid, age, pa, ab, h, doubles, triples, hr, bb, league, level, so from batters where year=?";
my $statsquery = "insert into stats(uid, isop, bbrate, woba, krate) VALUES (?, ?, ?, ?, ?)";

my $leaguesth = $dbh->prepare($leaguequery);
my $playersth = $dbh->prepare($query);
my $statsth = $dbh->prepare($statsquery);

my $playersth = $dbh->prepare($playerquery);
my $statsth = $dbh->prepare($statsquery);

$i = 0;

$playersth->execute($year);
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
 
    if ($ab > 0) {
        my $isop = ($doubles + ($triples * 2) + ($hr * 3)) / $ab;
        my $singles = $h - $doubles - $triples - $hr;
        my $woba = ((0.72 * $bb) + (0.9 * $singles) + (1.24 * $doubles)
            + (1.56 * $triples) + (1.95 * $hr)) / $pa;
        my $bbrate = $bb / $pa;
        
        my $krate = $so / $pa;
                
        $statsth->execute($uid,
                $isop, 
		$bbrate, 
                $woba,
                $krate);

    $i++;
    if ($i % 100) {
    } else {
      print "Updated $i....\n";
      print "UID $uid ISOP $isop BBRATE $bbrate KRATE $krate WOBA $woba\n";
    }


    }
}
