#!/usr/local/Cellar/perl/5.22.0/bin/perl

use DBI;
use DBD::mysql;
use Math::Complex;

my $curdir = `pwd`;
chomp $curdir;
my $dbh = DBI->connect("DBI:mysql:mysql_read_default_file=$curdir/dbi.conf;mysql_read_default_group=history", undef, undef, {});

my $playerquery = "select distinct compuid from adjustedcomps";

my $winsquery = "select b.uid, w.nameurl, sum(runs_replacement), sum(runs_above_rep), sum(runs_above_avg), sum(runs_above_avg_off), sum(w.war), sum(w.war_def), sum(w.war_off), sum(w.war_rep) from wins w, nameurl n, batters b where w.nameurl = n.brid and b.nameurl = n.brminorid and b.uid=? and w.age <=32 group by w.nameurl";

my $insertquery = "insert into summedwins(nameurl, runs_replacement, runs_above_rep, runs_above_avg, runs_above_avg_off, war, war_def, war_off, war_rep) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

my $playersth = $dbh->prepare($playerquery);
my $winsth = $dbh->prepare($winsquery);
my $insertsth = $dbh->prepare($insertquery);


$playersth->execute();
while (@data = $playersth->fetchrow_array()) {
    my $compuid = $data[0];

    $winsth->execute($compuid);
    while (@wdata = $winsth->fetchrow_array()) {
        $insertsth->execute($wdata[1], $wdata[2], $wdata[3], $wdata[4], $wdata[5], $wdata[6], $wdata[7], $wdata[8], $wdata[9]); 
    } 
}

