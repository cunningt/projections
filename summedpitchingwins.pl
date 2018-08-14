#!/usr/local/Cellar/perl/5.22.0/bin/perl

use DBI;
use DBD::mysql;
use Math::Complex;

my $curdir = `pwd`;
chomp $curdir;
my $dbh = DBI->connect("DBI:mysql:mysql_read_default_file=$curdir/dbi.conf;mysql_read_default_group=history", undef, undef, {});

my $playerquery = "select distinct compuid from pitchercomps order by compuid asc";

my $winsquery = "select b.uid, w.nameurl, sum(runs_above_avg), sum(runs_above_avg_adj), sum(runs_above_rep), sum(w.war) from pitchingwins w, nameurl n, pitchers b where w.nameurl = n.brid and b.nameurl = n.brminorid and b.uid=? and w.age <=32 group by w.nameurl";

my $insertquery = "insert into pitchingsummedwins(nameurl, runs_above_avg, runs_above_avg_adj, runs_above_rep, war) VALUES (?, ?, ?, ?, ?)";

my $playersth = $dbh->prepare($playerquery);
my $winsth = $dbh->prepare($winsquery);
my $insertsth = $dbh->prepare($insertquery);


$playersth->execute();
while (@data = $playersth->fetchrow_array()) {
    my $compuid = $data[0];

    $winsth->execute($compuid);
    my @wdata = ();
    while (@wdata = $winsth->fetchrow_array()) {
        $insertsth->execute($wdata[1], $wdata[2], $wdata[3], $wdata[4], $wdata[5]); 
    } 
}

