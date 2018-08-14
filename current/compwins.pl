#!/usr/local/Cellar/perl/5.22.0/bin/perl

use DBI;
use DBD::mysql;
use Math::Complex;

my $curdir = `pwd`;
chomp $curdir;
my $dbh = DBI->connect("DBI:mysql:mysql_read_default_file=$curdir/dbi.conf;mysql_read_default_group=history", undef, undef, {});

my $playerquery = "select distinct uid from adjustedcomps";

my $compquery = "select c.compuid, c.euclidean, b.nameurl, n.brid, ifnull(w.runs_replacement,0), ifnull(w.runs_above_rep,0), ifnull(w.runs_above_avg,0), ifnull(w.runs_above_avg_off,0), ifnull(w.war,0), ifnull(w.war_def,0), ifnull(w.war_off,0), ifnull(w.war_rep,0) from adjustedcomps c, batters b, nameurl n left join summedwins w on n.brid = w.nameurl where c.compuid = b.uid and b.nameurl = n.brminorid and c.uid = ? and c.compuid != ? order by euclidean asc limit 15";

my $insertquery = "insert into compwins(uid, runs_replacement, runs_above_rep, runs_above_avg, runs_above_avg_off, war, war_def, war_off, war_rep) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

my $playersth = $dbh->prepare($playerquery);
my $compsth = $dbh->prepare($compquery);
my $insertsth = $dbh->prepare($insertquery);


$playersth->execute();
while (@data = $playersth->fetchrow_array()) {
    my $compuid = $data[0];
    print "UID [$compuid]\n";
    my ($runs_replacement, $runs_above_rep, $runs_above_avg, $runs_above_avg_off, $war, $war_def, $war_off, $war_rep) = (0) x 8;

    $compsth->execute($compuid, $compuid);
    $counter = 0;
    while (@wdata = $compsth->fetchrow_array()) {
        $runs_replacement += $wdata[4];
	$runs_above_rep += $wdata[5];
        $runs_above_avg += $wdata[6];
        $runs_above_avg_off += $wdata[7];
        $war += $wdata[8];
        $war_def += $wdata[9];
        $war_off += $wdata[10];
        $war_rep += $wdata[11];
        $counter++;
    }

    $insertsth->execute($compuid, ($runs_replacement/$counter), ($runs_above_rep/$counter), ($runs_above_avg/$counter), ($runs_above_avg_off/$counter), ($war/$counter), ($war_def/$counter), ($war_off/$counter), ($war_rep/$counter)); 
}

