#!/usr/local/Cellar/perl/5.26.0/bin/perl

use Date::Calc qw/Delta_Days/;
use LWP::Simple;
use HTML::TableExtract qw(tree);
use DBI;
use DBD::mysql;
use Data::Dumper;

my $curdir = `pwd`;
chomp $curdir;
my $dbh = DBI->connect("DBI:mysql:mysql_read_default_file=$curdir/dbi.conf;mysql_read_default_group=history", undef, undef, {});

my $year = defined($ARGV[0]) ? shift(@ARGV) : "2018";
my $team = defined($ARGV[0]) ? shift(@ARGV) : "";

my $qualifier = "";
if ($year != "") {
  if (length($team) > 0) {
    $qualifier = "and l.year = $year and t.team = '$team'";
  } else {
    $qualifier = "and l.year = $year";
  }
} else {
  if (length($team) > 0) {
    $qualifier = "and t.team = '$team'";
  } 
}

my $query = "insert into pitchers(nameurl, name, year, age, team, league, level, g, gs, bf, ip, h, r, er, bb, so, hbp, hr) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
my $isth = $dbh->prepare($query);

my $birthdatequery = "select birthdate from birthdate where nameurl = ?";
my $birthsth = $dbh->prepare($birthdatequery);

my $birthinsertquery = "insert into birthdate(nameurl, name, birthdate) VALUES (?, ?, ?)";
my $birthinsertsth = $dbh->prepare($birthinsertquery);

my $leaguesquery = "select t.team, t.league, l.level, t.teamhash, t.year from teams t, leagues l where t.league = l.league and t.year = l.year and t.year >= 1960 $qualifier";
my $leaguesth = $dbh->prepare($leaguesquery);

my $birthinsertquery = "insert into birthdate(nameurl, name, birthdate) VALUES (?, ?, ?)";
my $birthinsertsth = $dbh->prepare($birthinsertquery);

my $urltemplate = "https://www.baseball-reference.com/register/team.cgi?id=%arg%";

$leaguesth->execute;
while (@row = $leaguesth->fetchrow_array()) {
   my ($team, $league, $level, $teamhash, $year) = @row;
   my $url = $urltemplate;
   $url =~ s|%arg%|$teamhash|;

   print "$league ... fetching data ...\n";
   insertPitchers($url, $teamhash, $team, $league, $level, $year);
}

exit 0;

sub findAge {
    my ($url, $name, $statyear) = @_;

    $nameurl = $url;
    $nameurl =~ s|.*id=||;

    $birthsth->execute($nameurl);
    $resultsflag = false;
    if (@data = $birthsth->fetchrow_array()) {
        $resultsflag = true;
        my @date = split("-", $data[0]);
        $date[2] =~ s|^([0-9]+) .*|$1|;

        my($day, $month, $year)=(localtime)[3,4,5];
        my @today = ($statyear, 4, 1);

        my $dd = Delta_Days(@date, @today);
        return ($dd / 365 ) ;
    }

    # We can't find the birthdate in the db, need to query it from B-R.com
    $page = get("http://www.baseball-reference.com/". $url);
    if ($page =~ m|data-birth=\"([^\"]+)\"|g) {
        $age = $1;
        my @date = split("-", $age);
        print "DATE @date \n";

        # Insert the ID/birthdate into the database
        if ($resultsflag == false) {
            $birthinsertsth->execute($nameurl, $name, $age);
        }

        my($day, $month, $year)=(localtime)[3,4,5];
        my @today = ($statyear, 4, 1);

        my $dd = Delta_Days(@date, @today);

        return ($dd / 365 ) ;
    }
}

sub insertPitchers {
	my ($url, $teamhash, $team, $league, $level, $year) = @_;
	print "URL $url\n";
	my $page = get($url);
	my $te = new HTML::TableExtract( count => 1);
  $page =~ s|<!--||mg;
  $page =~ s|-->||mg;

	$te->parse($page);
 
  my $tablecount = 0;
	foreach my $ts ($te->tables) {
     $tablecount++;
     my $tree = $ts->tree();
     my $tablehtml = $tree->as_HTML;
     if ($tablehtml =~ m|id=\"team_pitching\"|) {
     } else {
       next;
     }

	   my $rowcount = 1;
	   foreach my $row ($ts->rows) {
		    $maxrow = $#{$ts->rows};
		    next if ($rowcount > $maxrow);
		    next if ($rowcount > 100);
		    my $cell = $tree->cell($rowcount,1)->as_HTML;

        $cell =~ s|.*href=\"||;
        $cell =~ s|\".*||;
        $nameurl = $cell;

        # Skip the last row which isn't a player but is a totals row
        if ($nameurl =~ m|register|) {
        } else {
          next;
        }

        $nameurl =~ s|.*id=||;
        $age = findAge($cell, $tree->cell($rowcount,1)->as_text, $year);

        $bf = $tree->cell($rowcount,24)->as_text;
        if ($bf =~ m|^$|) {
          $bf = 0;
        }

        my $player = {
          nameurl=>$nameurl,
          name=>$tree->cell($rowcount,1)->as_text,
          age=>$age,
          team=>$tree->cell($rowcount,3)->as_text,
          league=>$tree->cell($rowcount,4)->as_text,
          games=>$tree->cell($rowcount,7)->as_text,
          gs=>$tree->cell($rowcount,8)->as_text,
          bf=>$bf,
          ip=>$tree->cell($rowcount,13)->as_text,
          h=>$tree->cell($rowcount,14)->as_text,
          r=>$tree->cell($rowcount,14)->as_text,
          er=>$tree->cell($rowcount,16)->as_text,
          hr=>$tree->cell($rowcount,17)->as_text,
          bb=>$tree->cell($rowcount,18)->as_text,
          so=>$tree->cell($rowcount,20)->as_text,
          hbp=>$tree->cell($rowcount,21)->as_text
        };

        print "PLAYER " . Dumper(\$player) . "\n";

        $isth->execute($nameurl,
                   $tree->cell($rowcount,1)->as_text, #name
                   $year, #year
                   $age, #age
                   $team, #team
                   $league, #league
                   $level, #level
                   $tree->cell($rowcount,7)->as_text, #g
                   $tree->cell($rowcount,8)->as_text, #gs
                   $bf, #bf
                   $tree->cell($rowcount,13)->as_text, #ip
                   $tree->cell($rowcount,14)->as_text, #h
                   $tree->cell($rowcount,15)->as_text, #r
                   $tree->cell($rowcount,16)->as_text, #er
                   $tree->cell($rowcount,18)->as_text, #bb
                   $tree->cell($rowcount,20)->as_text, #so
                   $tree->cell($rowcount,21)->as_text, #hbp
                   $tree->cell($rowcount,17)->as_text); #hr
                   $rowcount++;

	   }
	} 
}
