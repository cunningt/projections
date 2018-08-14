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
my $league = defined($ARGV[0]) ? shift(@ARGV) : "";

my $qualifier = "";
if ($year != "") {
  if (length($league) > 0) {
    $qualifier = "and year = $year and league = '$league'";
  } else {
    $qualifier = "and year = $year";
  }
} else {
  if (length($league) > 0) {
    $qualifier = "and league = '$league'";
  } 
}

my $query = "insert into pitchers(nameurl, name, year, age, team, league, level, g, gs, bf, ip, h, r, er, bb, so, hbp, hr) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
my $isth = $dbh->prepare($query);

my $birthdatequery = "select birthdate from birthdate where nameurl = ?";
my $birthsth = $dbh->prepare($birthdatequery);

my $birthinsertquery = "insert into birthdate(nameurl, name, birthdate) VALUES (?, ?, ?)";
my $birthinsertsth = $dbh->prepare($birthinsertquery);

my $leaguesquery = "select league, level, leaguehash, year from leagues where year >= 1960 $qualifier";
print "LEAGUES [$leaguesquery]\n";
my $leaguesth = $dbh->prepare($leaguesquery);

my $birthinsertquery = "insert into birthdate(nameurl, name, birthdate) VALUES (?, ?, ?)";
my $birthinsertsth = $dbh->prepare($birthinsertquery);

my $urltemplate = "http://www.baseball-reference.com/minors/leader.cgi?type=pitch&id=%arg%&sort_by=so";

$leaguesth->execute;
while (@row = $leaguesth->fetchrow_array()) {
   my ($league, $level, $leaguehash, $year) = @row;
   my $url = $urltemplate;
   $url =~ s|%arg%|$leaguehash|;

   print "$league ... fetching data ...\n";
   insertPitchers($url, $leaguehash, $league, $level, $year);
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
	my ($url, $lg, $league, $level, $year) = @_;
	print "URL $url\n";
	my $page = get($url);
	my $te = new HTML::TableExtract( count => 0);
	$te->parse($page);

	foreach my $ts ($te->tables) {
       my $tree = $ts->tree();
	   my $rowcount = 1;
	   foreach my $row ($ts->rows) {
		$maxrow = $#{$ts->rows};
		next if ($rowcount > $maxrow);
		next if ($rowcount > 100);
		my $cell = $tree->cell($rowcount,1)->as_HTML;

        $cell =~ s|.*href=\"||;
        $cell =~ s|\".*||;
        $nameurl = $cell;
        $nameurl =~ s|.*id=||;
        $age = findAge($cell, $tree->cell($rowcount,1)->as_text, $year);

        $bf = $tree->cell($rowcount,28)->as_text;
        if ($bf =~ m|^$|) {
          $bf = 0;
        }

        my $player = {
          nameurl=>$nameurl,
          name=>$tree->cell($rowcount,1)->as_text,
          age=>$age,
          team=>$tree->cell($rowcount,3)->as_text,
          league=>$tree->cell($rowcount,4)->as_text,
          games=>$tree->cell($rowcount,11)->as_text,
          gs=>$tree->cell($rowcount,12)->as_text,
          bf=>$bf,
          ip=>$tree->cell($rowcount,17)->as_text,
          h=>$tree->cell($rowcount,18)->as_text,
          r=>$tree->cell($rowcount,19)->as_text,
          er=>$tree->cell($rowcount,20)->as_text,
          hr=>$tree->cell($rowcount,21)->as_text,
          bb=>$tree->cell($rowcount,22)->as_text,
          so=>$tree->cell($rowcount,24)->as_text,
          hbp=>$tree->cell($rowcount,25)->as_text
        };

        print "PLAYER " . Dumper(\$player) . "\n";

        $isth->execute($nameurl,
                   $tree->cell($rowcount,1)->as_text, #name
                   $year, #year
                   $age, #age
                   $tree->cell($rowcount,3)->as_text, #team
                   $league, #league
                   $tree->cell($rowcount,4)->as_text, #level
                   $tree->cell($rowcount,11)->as_text, #g
                   $tree->cell($rowcount,12)->as_text, #gs
                   $bf, #bf
                   $tree->cell($rowcount,17)->as_text, #ip
                   $tree->cell($rowcount,18)->as_text, #h
                   $tree->cell($rowcount,19)->as_text, #r
                   $tree->cell($rowcount,20)->as_text, #er
                   $tree->cell($rowcount,22)->as_text, #bb
                   $tree->cell($rowcount,24)->as_text, #so
                   $tree->cell($rowcount,25)->as_text, #hbp
                   $tree->cell($rowcount,21)->as_text); #hr
                   $rowcount++;

	   }
	} 
}
