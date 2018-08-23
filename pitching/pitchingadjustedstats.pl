#!/usr/local/Cellar/perl/5.22.0/bin/perl

use DBI;
use DBD::mysql;
use Math::Complex;

my $curdir = `pwd`;
chomp $curdir;
my $dbh = DBI->connect("DBI:mysql:mysql_read_default_file=$curdir/dbi.conf;mysql_read_default_group=history", undef, undef, {});

my $year = defined($ARGV[0]) ? shift(@ARGV) : "2017";

my $statsquery = "select s.uid, p.league, p.year, s.bbpercent, s.hrpercent, s.kpercent, s.ksquared from pitcherstats s, pitchers p where s.uid=p.uid";
my $leaguequery = "select bbpercent, hrpercent, kpercent, ksquared from pitchingleaguestats where league = ? and year = ?";
my $avgquery = "select avg(bbpercent), avg(hrpercent), avg(kpercent), avg(ksquared) from pitchingleaguestats";
my $adjstatsquery = "insert into pitcheradjustedstats(uid, bbpercent, hrpercent, kpercent, ksquared) VALUES (?, ?, ?, ?, ?)";

my $statssth = $dbh->prepare($statsquery);
my $leaguesth = $dbh->prepare($leaguequery);
my $avgsth = $dbh->prepare($avgquery);
my $adjstatsth = $dbh->prepare($adjstatsquery);

my $avgbbpercent, $avghrpercent, $avgkpercent, $avgksquared = 1;
$avgsth->execute();
while (@data = $avgsth->fetchrow_array()) { 
    my $count = 0;
    $avgbbpercent = $data[$count++];
    $avghrpercent = $data[$count++];
    $avgkpercent = $data[$count++];
    $avgksquared = $data[$count++];
}

$statssth->execute();

while (@data = $statssth->fetchrow_array()) {
    my $count = 0;
    my $uid = $data[$count++];
    my $league = $data[$count++];
    my $year = $data[$count++];
    my $bbpercent = $data[$count++];
    my $hrpercent = $data[$count++];
    my $kpercent = $data[$count++];
    my $ksq = $data[$count++];
   
    print "UID $uid, $bbpercent, $hrpercent, $kpercent, $ksq\n";
 
    $leaguesth->execute($league, $year);
    my ($lgbbpercent, $lghrpercent, $lgkpercent, $lgksquared) = 1;
    while (@ldata = $leaguesth->fetchrow_array()) {
      my $count = 0;
      $lgbbpercent = $ldata[$count++];
      $lghrpercent = $ldata[$count++];
      $lgkpercent = $ldata[$count++];
      $lgksquared = $ldata[$count++];
    }

    #print "LEAGUE $uid $league $lgbbpercent $avgbbpercent\n";
    #$r = <STDIN>;

    my $bbpercentmult = 1 / ($lgbbpercent / $avgbbpercent);
    my $hrpercentmult = 1 / ($lghrpercent / $avghrpercent);
    my $kpercentmult = 1 / ($lgkpercent / $avgkpercent);
    my $ksqmult = 1 / ($lgksquared / $avgksquared); 

    $adjstatsth->execute($uid,
                ($bbpercent * $bbpercentmult),
		($hrpercent * $hrpercentmult), 
                ($kpercent * $kpercentmult),
                ($ksq * $ksqmult));
}
