#!/usr/local/Cellar/perl/5.22.0/bin/perl

use DBI;
use DBD::mysql;
use Math::Complex;

my $curdir = `pwd`;
my $pamin = 50;

chomp $curdir;
my $dbh = DBI->connect("DBI:mysql:mysql_read_default_file=$curdir/dbi.conf;mysql_read_default_group=history", undef, undef, {});

my $year = defined($ARGV[0]) ? shift(@ARGV) : "2017";

my $rankingsquery = "select b.uid, b.nameurl, b.name, b.level, b.league, b.team, b.age, c.war_off, c.runs_above_avg_off from batters b, weightedcompwins c where b.year = ? and b.uid = c.uid and b.pa > ? order by c.runs_above_avg_off desc";

my $compquery = "select c.compuid, c.euclidean, c.mahalanobis, b.name, b.nameurl, b.age, b.year, b.level, n.brid, ifnull(w.runs_replacement,0), ifnull(w.runs_above_rep,0), ifnull(w.runs_above_avg,0), ifnull(w.runs_above_avg_off,0), ifnull(w.war,0), ifnull(w.war_def,0), ifnull(w.war_off,0), ifnull(w.war_rep,0) from adjustedcomps c, batters b, nameurl n left join summedwins w on n.brid = w.nameurl where c.compuid = b.uid and b.year <= ? and b.nameurl = n.brminorid and c.uid = ? order by mahalanobis asc limit 15";

my $statsquery = "select s.isop, s.bbrate, s.woba, s.krate, ast.isop, ast.woba from stats s, adjustedstats ast where ast.uid = s.uid and s.uid = ?";

my $rankingsth = $dbh->prepare($rankingsquery);
my $compsth = $dbh->prepare($compquery);
my $statsth = $dbh->prepare($statsquery);

my $dir = "html";
mkdir $dir;
open (FH, ">", "$dir/rankings.html");
print FH "<html>\n<head>\n";
print FH "<link rel=\"stylesheet\" href=\"https://unpkg.com/purecss\@1.0.0/build/pure-min.css\" integrity=\"sha384-nn4HPE8lTHyVtfCBi5yW9d20FjT8BJwUXyWZT9InLYax14RDjBj46LmSztkmNP9w\" crossorigin=\"anonymous\">\n\n";
print FH "</head>\n<body>\n";
print FH "<table class=\"pure-table pure-table-horizontal\">\n";
print FH "<thead>\n";
print FH "<tr>\n";
print FH "<th>Rank</th><th>Name</th><th>Age</th><th>Level</th><th>ISO</th><th>wOBA</th><th>BB%</th><th>K%</th><th>RAA</th><th>Comp</th>\n";
print FH "</tr>\n";
print FH "</thead>\n";

$rankingsth->execute($year, $pamin);
my $rankcounter = 1;
while (@data = $rankingsth->fetchrow_array()) {
    my $counter = 0;
    my $uid = $data[$counter++];
    my $nameurl = $data[$counter++];
    my $name = $data[$counter++];
    my $level = $data[$counter++];
    my $league = $data[$counter++];
    my $team = $data[$counter++];
    my $age = $data[$counter++];
    my $war_off = $data[$counter++];
    my $rar_off = $data[$counter++];

    $statsth->execute($uid);
    my @rdata = $statsth->fetchrow_array() and $statsth->finish;
    
    $compsth->execute(($year-9), $uid);
    my @cdata = $compsth->fetchrow_array() and $compsth->finish;

    print FH "<tr>\n";
    print FH "<td>" . $rankcounter++ . "</td>";
    print FH "<td><b>$name</b>, <a href=\"https://www.baseball-reference.com/register/player.fcgi?id=$nameurl#standard_batting::none\">BR</a>, <a href=\"$uid.html\">comps</a></td>";
    print FH "<td>$age</td>";
    print FH "<td>$level</td>";
    printf FH "<td>.%03d</td>", ($rdata[0] * 1000);
    printf FH "<td>.%03d</td>", ($rdata[2] * 1000);
    printf FH "<td>%.1f</td>", ($rdata[1] * 100);
    printf FH "<td>%.1f</td>", ($rdata[3] * 100);
    print FH "<td>$rar_off</td>\n";
    printf FH "<td>" . $cdata[3] . ", " . $cdata[6];
    if ($cdata[2] > 2 ) {
        printf FH "<b>***</b>\n";
    }
    printf FH "</td>\n";
    print FH "</tr>\n";
}

print FH "</table>\n";
print FH "</body></html>\n";
close (FH);
$rankingsth->finish;

print "Rankings finished...\n";

$rankingsth->execute();
while (@data = $rankingsth->fetchrow_array()) {
    my $counter = 0;
    my $uid = $data[$counter++];
    my $nameurl = $data[$counter++];
    my $name = $data[$counter++];
    my $level = $data[$counter++];
    my $league = $data[$counter++];
    my $team = $data[$counter++];
    my $age = $data[$counter++];
    my $war_off = $data[$counter++];
    my $rar_off = $data[$counter++];

    $statsth->execute($uid);
    my @rdata = $statsth->fetchrow_array();

    print "Comps for $nameurl...\n";

    open (CH, ">", "$dir/$uid.html");
    print CH "<html>\n<head>\n";
    print CH "<link rel=\"stylesheet\" href=\"https://unpkg.com/purecss\@1.0.0/build/pure-min.css\" integrity=\"sha384-nn4HPE8lTHyVtfCBi5yW9d20FjT8BJwUXyWZT9InLYax14RDjBj46LmSztkmNP9w\" crossorigin=\"anonymous\">\n";
    print CH "</head><body>\n";
    print CH "<table class=\"pure-table pure-table-horizontal\">\n";
    print CH "<thead>\n";
    print CH "<tr>\n";
    print CH "<th>Name</th><th>Age</th><th>Year</th><th>Level</th><th>Mahalanobis</th><th>ISO</th><th>wOBA</th><th>BB%</th><th>K%</th><th>WAR</th><th>RAR</th>\n";
    print CH "</tr>\n";
    print CH "</thead>\n";
    print CH "<tr>\n";
    print CH "<td><a href=\"https://www.baseball-reference.com/register/player.fcgi?id=$nameurl#standard_batting::none\"><b>$name</b></a></td>";
    print CH "<td>$age</td>";
    print CH "<td>$year</td>";
    print CH "<td>$level</td>";
    print CH "<td>0.0</td>";
    printf CH "<td>.%03d (.%03d)</td>", ($rdata[0] * 1000), ($rdata[4] * 1000);
    printf CH "<td>.%03d (.%03d)</td>", ($rdata[2] * 1000), ($rdata[5] * 1000);
    printf CH "<td>%.1f</td>", ($rdata[1] * 100);
    printf CH "<td>%.1f</td>", ($rdata[3] * 100);
    printf CH "<td>%.2f</td>", $war_off;
    printf CH "<td>%.2f</td>", $rar_off;
    print CH "</tr>\n";

    print CH "<thead>\n";
    print CH "<tr>\n";
    print CH "<th>Name</th><th>Age</th><th>Year</th><th>Level</th><th>Mahalanobis</th><th>ISO</th><th>wOBA</th><th>BB%</th><th>K%</th><th>WAR</th><th>RAR</th>\n";
    print CH "</tr>\n";
    print CH "</thead>\n"; 

    # List the player's comps
    $compsth->execute(($year-9), $uid);
    my $wartotal = 0;
    my $rartotal = 0;
    while (@cdata = $compsth->fetchrow_array()) {
       my $ccounter = 0; 
       my $compuid = $cdata[$ccounter++];
       my $euclidean = $cdata[$ccounter++];
       my $mahalanobis = $cdata[$ccounter++];
       my $cname = $cdata[$ccounter++];
       my $cnameurl = $cdata[$ccounter++];
       my $cage = $cdata[$ccounter++];
       my $cyear = $cdata[$ccounter++];
       my $clevel = $cdata[$ccounter++];
       my $brid = $cdata[$ccounter++];
       my $cruns_replacement = $cdata[$ccounter++];
       my $cruns_above_rep = $cdata[$ccounter++];
       my $cruns_above_avg = $cdata[$ccounter++]; 
       my $cruns_above_avg_off = $cdata[$ccounter++];
       my $cwar = $cdata[$ccounter]; 
       my $cwar_def = $cdata[$ccounter];
       my $cwar_off = $cdata[$ccounter];
       my $cwar_rep = $cdata[$ccounter];

       $statsth->execute($compuid);
       my @crdata = $statsth->fetchrow_array();
       print CH "<tr>\n";
       print CH "<td><a href=\"https://www.baseball-reference.com/register/player.fcgi?id=$cnameurl#standard_batting::none\"><b>$cname</b></a></td>";
       print CH "<td>$cage</td>";
       print CH "<td>$cyear</td>";
       print CH "<td>$clevel</td>";
       print CH "<td>$mahalanobis</td>";
       printf CH "<td>.%03d (.%03d)</td>", ($crdata[0] * 1000), ($crdata[4] * 1000);
       printf CH "<td>.%03d (.%03d)</td>", ($crdata[2] * 1000), ($crdata[5] * 1000);
       printf CH "<td>%.1f</td>", ($crdata[1] * 100);
       printf CH "<td>%.1f</td>", ($crdata[3] * 100);
       printf CH "<td>%.2f</td>", $cwar_off;
       printf CH "<td>%.2f</td>", $cruns_above_avg_off;
       print CH "</tr>\n";
       $wartotal += $cwar_off;
       $rartotal += $cruns_above_avg_off;
    }

    print CH "<tr><td><b>Totals</b></td>\n";
    for (my $i = 0; $i < 8; $i ++) {
        print CH "<td></td>\n"; 
    }
    printf CH "<td><b>%.2f</b></td>", $wartotal;
    printf CH "<td><b>%.2f</b></td>", $rartotal;
    print CH "</tr>\n";
    print CH "</table>\n";
    print CH "</body></table>\n";
    close (CH);

}

