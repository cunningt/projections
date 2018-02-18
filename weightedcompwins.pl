#!/usr/local/Cellar/perl/5.22.0/bin/perl

use DBI;
use DBD::mysql;
use Math::Complex;

my $curdir = `pwd`;
chomp $curdir;
my $dbh = DBI->connect("DBI:mysql:mysql_read_default_file=$curdir/dbi.conf;mysql_read_default_group=history", undef, undef, {});

my $playerquery = "select distinct uid from adjustedcomps";

my $compquery = "select c.compuid, c.euclidean, b.nameurl, n.brid, ifnull(w.runs_replacement,0), ifnull(w.runs_above_rep,0), ifnull(w.runs_above_avg,0), ifnull(w.runs_above_avg_off,0), ifnull(w.war,0), ifnull(w.war_def,0), ifnull(w.war_off,0), ifnull(w.war_rep,0) from adjustedcomps c, batters b, nameurl n left join summedwins w on n.brid = w.nameurl where c.compuid = b.uid and b.year <= 2008 and b.nameurl = n.brminorid and c.uid = ? and c.compuid != ? order by euclidean asc limit 15";

my $insertquery = "insert into weightedcompwins(uid, runs_replacement, runs_above_rep, runs_above_avg, runs_above_avg_off, war, war_def, war_off, war_rep) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

my $playersth = $dbh->prepare($playerquery);
my $compsth = $dbh->prepare($compquery);
my $insertsth = $dbh->prepare($insertquery);


$playersth->execute();
while (@data = $playersth->fetchrow_array()) {
    my $compuid = $data[0];
    print "UID [$compuid]\n";
    my ($euc, $runs_replacement, $runs_above_rep, $runs_above_avg, $runs_above_avg_off, $war, $war_def, $war_off, $war_rep) = (0) x 9;

    $compsth->execute($compuid, $compuid);
    $counter = 0;
    while (@wdata = $compsth->fetchrow_array()) {
	my $euclidean = $wdata[1];
        my $inveuc = 1 / $euclidean;  

        $runs_replacement += $wdata[4] * $inveuc;
	$runs_above_rep += $wdata[5] * $inveuc;
        $runs_above_avg += $wdata[6] * $inveuc;
        $runs_above_avg_off += $wdata[7] * $inveuc;
        $war += $wdata[8] * $inveuc;
        $war_def += $wdata[9] * $inveuc;
        $war_off += $wdata[10] * $inveuc;
        $war_rep += $wdata[11] * $inveuc;

	$euc += $inveuc;
        $counter++;
    }

    $insertsth->execute($compuid, ($runs_replacement/$euc), ($runs_above_rep/$euc), ($runs_above_avg/$euc), ($runs_above_avg_off/$euc), ($war/$euc), ($war_def/$euc), ($war_off/$euc), ($war_rep/$euc)); 
}

