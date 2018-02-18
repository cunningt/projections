#!/usr/local/Cellar/perl/5.22.0/bin/perl

use DBI;
use DBD::mysql;
use Math::Complex;

my $curdir = `pwd`;
chomp $curdir;
my $dbh = DBI->connect("DBI:mysql:mysql_read_default_file=$curdir/dbi.conf;mysql_read_default_group=history", undef, undef, {});

my $leaguequery = "select distinct league, year from batters";
my $playerquery = "select ab, pa, h, bb, doubles, triples, hr, league, so from batters where league=? and year=? and age < 28";
my $isopquery = "select sum(ab) as ab, sum(doubles) as doubles, sum(triples) as triples, sum(hr) as hr, sum(pa) as pa, sum(so) as so from batters where league=? and year=? and age < 28 group by league";
my $wobaquery = "select sum(pa) as pa, sum(h) as h, sum(bb) as bb, sum(doubles) as doubles, sum(triples) as triples, sum(hr) as hr from batters where league=? and year=? and age < 28 group by league";
my $agequery = "insert into leaguestats (league, year, isop, isopstddev, woba, wobastddev, krate, kratestddev) VALUES (?,?,?,?,?,?,?,?)";

my $isth = $dbh->prepare($query);

my $leaguesth = $dbh->prepare($leaguequery);
my $isopsth = $dbh->prepare($isopquery);
my $wobasth = $dbh->prepare($wobaquery);
my $playersth = $dbh->prepare($playerquery);
my $agesth = $dbh->prepare($agequery);
$leaguesth->execute();

while (@data = $leaguesth->fetchrow_array()) {
    my $lg = $data[0];
    my $year = $data[1];
 
    $isopsth->execute($lg, $year);
    while (@data = $isopsth->fetchrow_array()) {
        my $ab = $data[0];
        my $doubles = $data[1];
        my $triples = $data[2];
        my $hr = $data[3];
        my $pa = $data[4];
        my $so = $data[5];

        if ($ab != 0) {
            my $isop = ($doubles + ($triples * 2) + ($hr * 3)) / $ab;
            $lgisop = $isop;
            $lgkrate = ($so / $pa);
        } else {
            $lgisop = 0;
            $lgkrate = 0;
        }
    }

    $wobasth->execute($lg, $year);
    while (@data = $wobasth->fetchrow_array()) {
        my $pa = $data[0];
        my $h = $data[1];
        my $bb = $data[2];
        my $doubles = $data[3];
        my $triples = $data[4];
        my $hr = $data[5];
        my $singles = $h - $doubles - $triples - $hr;
        
        if ($pa != 0) {
            my $woba = ((0.72 * $bb) + (0.9 * $singles) + (1.24 * $doubles)
                + (1.56 * $triples) + (1.95 * $hr)) / $pa;
            $lgwoba = $woba;
        } else {
            $lgwoba = 0;
        }
    }

    $playercount = 0;
    $pacount = 0;
    $isopcount = 0;
    $wobacount = 0;
    $kratecount = 0;

    $playersth->execute($lg, $year);
    while (@data = $playersth->fetchrow_array()) {
       my $st = 0;
       my $ab = $data[$st++];
       my $pa = $data[$st++];
       my $h = $data[$st++];
       my $bb = $data[$st++];
       my $doubles = $data[$st++];
       my $triples = $data[$st++];
       my $hr = $data[$st++];
       my $league = $data[$st++];
       my $k = $data[$st++];
       my $singles = $h - $doubles - $triples - $hr;

       my $isop = ($doubles + ($triples * 2) + ($hr * 3)) / $ab;
       my $woba = ((0.72 * $bb) + (0.9 * $singles) + (1.24 * $doubles)
                + (1.56 * $triples) + (1.95 * $hr)) / $pa;
       my $krate = ($k / $pa);
       
       $isopvariance = ($isop - $lgisop) * ($isop - $lgisop);
       $wobavariance = ($woba - $lgwoba) * ($woba - $lgwoba);
       $kratevariance = ($krate - $lgkrate) * ($krate - $lgkrate);
       
       $isopcount = $isopcount + $isopvariance;
       $wobacount = $wobacount + $wobavariance;
       $kratecount = $kratecount + $kratevariance;
 
       $playercount++;
   }

       my $wobastddev = sqrt($wobacount / $playercount);
       my $isopstddev = sqrt($isopcount / $playercount);
       my $kratestddev = sqrt($kratecount / $playercount);
       print "$lg $year wobastddev[$wobastddev] isopsttdev[$isopstddev] kratestddev[$kratestddev]\n";
       $agesth->execute($lg, $year, $lgisop, $isopstddev,
            $lgwoba, $wobastddev, $lgkrate, $kratestddev);
}
