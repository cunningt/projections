#!/usr/local/Cellar/perl/5.22.0/bin/perl

use DBI;
use DBD::mysql;
use Math::Complex;

my $curdir = `pwd`;
chomp $curdir;
my $dbh = DBI->connect("DBI:mysql:mysql_read_default_file=$curdir/dbi.conf;mysql_read_default_group=history", undef, undef, {});

my $year = defined($ARGV[0]) ? shift(@ARGV) : "2017";

my $playerquery = "select distinct uid from adjpitchercomps where year=?";

my $compquery = "select c.compuid, c.mahalanobis, b.nameurl, n.brid, ifnull(w.runs_above_avg,0), ifnull(w.runs_above_avg_adj,0), ifnull(w.runs_above_rep,0), ifnull(w.war,0) from adjpitchercomps c, pitchers b, nameurl n left join pitchingsummedwins w on n.brid = w.nameurl where c.compuid = b.uid and c.year = ? and b.year <= 2008 and b.nameurl = n.brminorid and c.uid = ? and c.compuid != ? order by mahalanobis asc limit 15";

my $insertquery = "insert into pitchingweightedcompwins(uid, runs_above_avg, runs_above_avg_adj, runs_above_rep, war) VALUES (?, ?, ?, ?, ?)";

my $playersth = $dbh->prepare($playerquery);
my $compsth = $dbh->prepare($compquery);
my $insertsth = $dbh->prepare($insertquery);


$playersth->execute($year);
while (@data = $playersth->fetchrow_array()) {
    my $compuid = $data[0];
    print "UID [$compuid]\n";
    my ($mah, $runs_above_avg, $runs_above_avg_adj, $runs_above_rep, $war) = (0) x 5;

    $compsth->execute($year, $compuid, $compuid);
    $counter = 0;
    while (@wdata = $compsth->fetchrow_array()) {
	my $mahalanobis = $wdata[1];
        next if ($mahalanobis == 0);

        my $inveuc = 1 / $mahalanobis;  

        $runs_above_avg += $wdata[4] * $inveuc;
    	$runs_above_avg_adj += $wdata[5] * $inveuc;
        $runs_above_rep += $wdata[6] * $inveuc;
        $war += $wdata[7] * $inveuc;

        $mah += $inveuc;
        $counter++;
    }

    if ($mah != 0) {
        $insertsth->execute($compuid, ($runs_above_avg/$mah), ($runs_above_avg_adj/$mah), ($runs_above_rep/$mah), ($war/$mah)); 
    }
}

