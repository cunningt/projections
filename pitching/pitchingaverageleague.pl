#!/usr/local/Cellar/perl/5.22.0/bin/perl

use DBI;
use DBD::mysql;
use Math::Complex;

my $curdir = `pwd`;
chomp $curdir;
my $dbh = DBI->connect("DBI:mysql:mysql_read_default_file=$curdir/dbi.conf;mysql_read_default_group=history", undef, undef, {});

my $leaguequery = "select distinct league, year from pitchers";
my $playerquery = "select ip, bf, h, r, er, bb, so, hbp, hr from pitchers where league=? and year=? and ip>20";
my $statsquery = "select sum(ip) as ip, sum(bf) as bf, sum(h) as h, sum(r) as r, sum(er) as er, sum(bb) as bb, "
                 . "sum(so) as so, sum(hbp) as hbp, sum(hr) as hr from pitchers where league=? "
                 . "and year=? group by league";
my $insertquery = "insert into pitchingleaguestats (league, year, bbpercent, bbpercentagestddev, "
               . "kpercent, kpercentagestddev, hrpercent, hrpcercentagestddev, ksquared, ksquaredstddev) "
               . "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";


my $leaguesth = $dbh->prepare($leaguequery);
my $playersth = $dbh->prepare($playerquery);
my $statsth = $dbh->prepare($statsquery);
my $insertsth = $dbh->prepare($insertquery);
$leaguesth->execute();

while (@data = $leaguesth->fetchrow_array()) {
    my $lgcounter = 0;
    my $lg = $data[$lgcounter++];
    my $year = $data[$lgcounter++];
 
    my $lgkip = 0;
    my $lghrip = 0;
    my $lgbbip = 0;
    my $lgksq = 0;

    $statsth->execute($lg, $year);
    while (@data = $statsth->fetchrow_array()) {
        my $counter = 0;
        my $ip = $data[$counter++];
        my $bf = $data[$counter++];
        my $h = $data[$counter++];
        my $r = $data[$counter++];
        my $er = $data[$counter++];
        my $bb = $data[$counter++];
        my $so = $data[$counter++];
        my $hbp = $data[$counter++];
        my $hr = $data[$counter++];

        if ($bf == 0) {
            $bf = $bb + $hbp + $h + $ip + $ip +$ip;
        }

        if ($ip != 0) {
            $lgkip = ($so / $bf) * 100;
            $lghrip = ($hr / $bf) * 100;
            $lgbbip = ($bb / $bf) * 100;
            $lgksq = ($so / $bf) * ($so / $bf);
        }
    }
    
    print "league k[$lgkip] hr[$lghrip] bb[$lgbbip] ksq[$lgksq]\n";

    $playercount = 0;
    $pacount = 0;
    $isopcount = 0;
    $wobacount = 0;
    $kratecount = 0;


    $playersth->execute($lg, $year);
    while (@data = $playersth->fetchrow_array()) {
        my $counter = 0;
        my $ip = $data[$counter++];
        my $bf = $data[$counter++];
        my $h = $data[$counter++];
        my $r = $data[$counter++];
        my $er = $data[$counter++];
        my $bb = $data[$counter++];
        my $so = $data[$counter++];
        my $hbp = $data[$counter++];
        my $hr = $data[$counter++];

        if ($bf == 0) {
            $bf = $bb + $hbp + $h + $ip + $ip +$ip;
        } 

        my $pkip = 0;
        my $phrip = 0;
        my $pbbip = 0;
        my $pksq = 0;
        if ($ip != 0) {
            $pkip = ($so / $bf) * 100;
            $phrip = ($hr / $bf) * 100;
            $pbbip = ($bb / $bf) * 100;
            $pksq = ($so / $bf) * ($so / $bf);

            $kvariance = ($pkip - $lgkip) * ($pkip - $lgisop);
            $hrvariance = ($phrip - $lghrip) * ($phrip - $lghrip);
            $bbvariance = ($pbbip - $lgbbip) * ($pbbip - $lgbbip);
            $ksqvariance = ($pksq - $lgksq) * ($pksq - $lgksq);

            $kcount = $kcount + $kvariance;
            $hrcount = $hrcount + $hrvariance;
            $bbcount = $bbcount + $bbvariance;
            $ksqcount = $ksqcount + $ksqvariance;

            $playercount++;
        } else {
            next;
        }
   }

   my $kstddev = sqrt($kcount / $playercount);
   my $bbstddev = sqrt($bbcount / $playercount);
   my $hrstddev = sqrt($hrcount / $playercount);
   my $ksqstddev = sqrt($ksqcount / $playercount);
   print "$lg $year kstddev[$kstddev] bbsttdev[$bbstddev] hrstddev[$hrstddev] ksqstddev[$ksqstddev]\n";
   $insertsth->execute($lg, $year, $lgbbip, $bbstddev, $lgkip, $kstddev,
            $lghrip, $hrstddev, $lgksq, $ksqstddev);
}
