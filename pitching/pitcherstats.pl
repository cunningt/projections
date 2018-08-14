#!/usr/local/Cellar/perl/5.22.0/bin/perl

use DBI;
use DBD::mysql;
use Math::Complex;

my $curdir = `pwd`;
chomp $curdir;
my $dbh = DBI->connect("DBI:mysql:mysql_read_default_file=$curdir/dbi.conf;mysql_read_default_group=history", undef, undef, {});

#my $agesquery = "select age, stddev, league from pitcherages"; 
my $playerquery = "select uid, nameurl, year, league, age, g, gs, bf, ip, h, r, er, bb, so, hbp, hr from pitchers";
my $statsquery = "insert into pitcherstats(uid, nameurl, year, level, bbpercent, hrpercent, kpercent, ksquared, gspercent, fip) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

my $playersth = $dbh->prepare($query);

my %avgagehash = ();
my %stddevhash = ();

my $playersth = $dbh->prepare($playerquery);
my $statsth = $dbh->prepare($statsquery);
$playersth->execute;
while (@data = $playersth->fetchrow_array()) {
    my $count = 0;
    my $uid = $data[$count++];
    my $nameurl = $data[$count++];
    my $year = $data[$count++];
    my $league = $data[$count++];
    my $age = $data[$count++];
    my $g = $data[$count++];
    my $gs = $data[$count++];
    my $bf = $data[$count++];
    my $ip = $data[$count++];
    my $h = $data[$count++];
    my $r = $data[$count++];
    my $er = $data[$count++];
    my $bb = $data[$count++];
    my $so = $data[$count++];
    my $hbp = $data[$count++];
    my $hr = $data[$count++];

    if ($bf == 0) {
      $bf = $bb + $hbp + $h + $ip + $ip + $ip;
    }

    if (($g > 0) && ($ip > 0) && ($bf > 0) ) {
	
        my $kminusbb = ($so / $bf)  - ($bb / $bf);
        my $kminusbbip = ($so - $h - (.72 * $bb)) / $ip;

        my $kip = ($so / $bf) * 100;
        my $hrip = ($hr / $bf) * 100;
        my $bbip = ($bb / $bf) * 100;	
        my $ksquared = ($so / $bf) * ($so / $bf);
        my $gspercent = $gs / $g * 100;

        my $fip = (((13 * $hr) + (3 * $bb) - (2 * $so)) / $ip) + 3.2;
        print "$uid=UID $year=YEAR $league=level $bbip=bbip $hrip=hrip $kip=kip\n";
        $statsth->execute($uid, $nameurl, $year, $league, $bbip, $hrip, $kip, $ksquared, $gspercent, $fip);
    }
}
