#!/usr/local/Cellar/perl/5.22.0/bin/perl

use DBI;
use DBD::mysql;
use Math::Complex;

my $curdir = `pwd`;
chomp $curdir;
my $dbh = DBI->connect("DBI:mysql:mysql_read_default_file=$curdir/dbi.conf;mysql_read_default_group=history", undef, undef, {});

my $year = defined($ARGV[0]) ? shift(@ARGV) : "2017";

my $playerquery = "select distinct uid from adjustedcomps where year=?";

my $compquery = "select compuid, mahalanobis from adjustedcomps where uid=? order by mahalanobis asc limit 15";

my $winsquery = "select b.nameurl, n.brid, w.runs_replacement, w.runs_above_rep, w.runs_above_avg, w.runs_above_avg_off, w.war, w.war_def, w.war_off, w.war_rep from batters b, nameurl n, summedwins w where n.brid = w.nameurl and b.uid=? and b.year <= 2008 and b.nameurl = n.brminorid";

my $insertquery = "insert into weightedcompwins(uid, runs_replacement, runs_above_rep, runs_above_avg, runs_above_avg_off, war, war_def, war_off, war_rep) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

my $playersth = $dbh->prepare($playerquery);
my $compsth = $dbh->prepare($compquery);
my $winsth = $dbh->prepare($winsquery);
my $insertsth = $dbh->prepare($insertquery);


$playersth->execute($year);
while (@data = $playersth->fetchrow_array()) {
    my $uid = $data[0];
    my ($mahc, $runs_replacement, $runs_above_rep, $runs_above_avg, $runs_above_avg_off, $war, $war_def, $war_off, $war_rep) = (0) x 9;

    my $compcounter = 0;
    my $mlbcounter = 0;

    $compsth->execute($uid);
    
    while (@cdata = $compsth->fetchrow_array()) {
      my $counter = 0;
      my $compuid = $cdata[$counter++];
      my $mah = $cdata[$counter++];
  
      $winsth->execute($compuid); 
      my @wdata = $winsth->fetchrow_array(); 
      #print "UID $uid COMP# $compcounter COMPUID $compuid MAH $mah @wdata\n";

      if (@wdata) {
        next if ($mah == 0);
        my $invmah = 1 / $mah;

        $runs_replacement += $wdata[2] * $invmah;
        $runs_above_rep += $wdata[3] * $invmah;
        $runs_above_avg += $wdata[4] * $invmah;
        $runs_above_avg_off += $wdata[5] * $invmah;
        $war += $wdata[6] * $invmah;
        $war_def += $wdata[7] * $invmah;
        $war_off += $wdata[8] * $invmah;
        $war_rep += $wdata[9] * $invmah;

        $mahc += $invmah;

        $mlbcounter++
      }

      $compcounter++; 
    }

    #print "$compcounter players $mlbcounter MLB $mahc MAH\n";
    if (($mahc != 0) && ($compcounter != 0)) {
      my $factor = ($mlbcounter / $compcounter) * ($mlbcounter / $compcounter) / $mahc;
      print "FACTOR $factor MAHC $mahc\n";
      $insertsth->execute($uid, ($runs_replacement * $factor), ($runs_above_rep * $factor), 
        ($runs_above_avg * $factor), ($runs_above_avg_off * $factor), ($war * $factor), 
        ($war_def * $factor), ($war_off * $factor), ($war_rep * $factor)); 
    } 
}

