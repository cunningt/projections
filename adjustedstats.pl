#!/usr/local/Cellar/perl/5.22.0/bin/perl

use DBI;
use DBD::mysql;
use Math::Complex;

my $curdir = `pwd`;
chomp $curdir;
my $dbh = DBI->connect("DBI:mysql:mysql_read_default_file=$curdir/dbi.conf;mysql_read_default_group=history", undef, undef, {});

my $statsquery = "select s.uid, s.isop, s.bbrate, s.woba, s.krate, b.league, b.year from stats s, batters b where s.uid=b.uid";
my $leaguequery = "select isop, woba, krate from leaguestats where league = ? and year = ?";
my $avgquery = "select avg(isop), avg(woba), avg(krate) from leaguestats";
my $adjstatsquery = "insert into adjustedstats(uid, isop, bbrate, woba, krate) VALUES (?, ?, ?, ?, ?)";

my $statssth = $dbh->prepare($statsquery);
my $leaguesth = $dbh->prepare($leaguequery);
my $avgsth = $dbh->prepare($avgquery);
my $adjstatsth = $dbh->prepare($adjstatsquery);


my $avgisop, $avgwoba, $avgkrate = 1;
$avgsth->execute();
while (@data = $avgsth->fetchrow_array()) {
    $avgisop = $data[0];
    $avgwoba = $data[1];
    $avgkrate = $data[2];
}

$statssth->execute();

my $statsth = $dbh->prepare($statsquery);
while (@data = $statssth->fetchrow_array()) {
    my $uid = $data[0];
    my $isop = $data[1];
    my $bbrate = $data[2];
    my $woba = $data[3];
    my $krate = $data[4];
    my $league = $data[5];
    my $year = $data[6]; 

    $leaguesth->execute($league, $year);
    my $lgavgisop, $lgavgwoba, $lgavgkrate = 1;
    while (@ldata = $leaguesth->fetchrow_array()) {
      $lgavgisop = $ldata[0];
      $lgavgwoba = $ldata[1];
      $lgavgkrate = $ldata[2]; 
    }
 
    my $wobamult = 1 / ($lgavgwoba / $avgwoba);
    my $isopmult = 1 / ($lgavgisop / $avgisop);
 
    $adjstatsth->execute($uid,
                ($isop * $isopmult),
		$bbrate, 
                ($woba * $wobamult),
                $krate);
}
