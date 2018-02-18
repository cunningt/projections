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

my $query = "insert into batters(nameurl, name, year, age, team, league, level, games, pa, ab, r, h, doubles, triples, hr, rbi, bb, so) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
my $isth = $dbh->prepare($query);

my $birthdatequery = "select birthdate from birthdate where nameurl = ?";
my $birthsth = $dbh->prepare($birthdatequery);

my $leaguesquery = "select league, level, leaguehash, year from leagues where year >= 1960";
my $leaguesth = $dbh->prepare($leaguesquery);

my $birthinsertquery = "insert into birthdate(nameurl, name, birthdate) VALUES (?, ?, ?)";
my $birthinsertsth = $dbh->prepare($birthinsertquery);

my $urltemplate = "http://www.baseball-reference.com/minors/leader.cgi?type=bat&id=%arg%&sort_by=slugging_perc";

$leaguesth->execute;
while (@row = $leaguesth->fetchrow_array()) {
    my ($league, $level, $leaguehash, $year) = @row;
    
    my $url = $urltemplate;
    $url =~ s|%arg%|$leaguehash|;

    insertBatters($url, $leaguehash, $league, $level, $year);    
}

exit 0;

sub findAge {
    my ($url, $name) = @_;
    
    $nameurl = $url;
    $nameurl =~ s|.*id=||;
    
    $birthsth->execute($nameurl);
    $resultsflag = false;
    if (@data = $birthsth->fetchrow_array()) {
        $resultsflag = true;
        my @date = split("-", $data[0]);
        $date[2] =~ s|^([0-9]+) .*|$1|;
        
        my($day, $month, $year)=(localtime)[3,4,5];
        my @today = (1900 + $year, 1 + $month, $day);
        
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
        my @today = (1900 + $year, 1 + $month, $day);
        
        my $dd = Delta_Days(@date, @today);
        
        return ($dd / 365 ) ;
    }
}

sub insertBatters {
	my ($url, $lg, $league, $level, $year) = @_;
	print "URL $url\n";
	my $page = get($url);
	print "PAGE [$page]\n";
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
		print "ROW " . $cell . "\n";
		$cell =~ s|.*href=\"||;
		$cell =~ s|\".*||;
                $nameurl = $cell;
                $nameurl =~ s|.*id=||;
        
		$age = findAge($cell, $tree->cell($rowcount,1)->as_text);
	
		my $player = {
                        nameurl=>$nameurl,
			name=>$tree->cell($rowcount,1)->as_text,
                        year=>$year,
			age=>$age,
			team=>$tree->cell($rowcount,3)->as_text,
                        league=>$league,
			level=>$tree->cell($rowcount,4)->as_text,
			games=>$tree->cell($rowcount,6)->as_text,
			pa=>$tree->cell($rowcount,7)->as_text,
			ab=>$tree->cell($rowcount,8)->as_text,
			r=>$tree->cell($rowcount,9)->as_text,
			h=>$tree->cell($rowcount,10)->as_text,
                        doubles=>$tree->cell($rowcount,11)->as_text,
			triples=>$tree->cell($rowcount,12)->as_text,
			hr=>$tree->cell($rowcount,13)->as_text,
			rbi=>$tree->cell($rowcount,14)->as_text,
			bb=>$tree->cell($rowcount,17)->as_text,
			k=>$tree->cell($rowcount,18)->as_text
			};

        print "PLAYER " . Dumper(\$player) . "\n";

	    $isth->execute($nameurl,
                        $tree->cell($rowcount,1)->as_text,
                        $year,
                        $age,
                        $tree->cell($rowcount,3)->as_text,
                        $league,
                        $tree->cell($rowcount,4)->as_text,
                        $tree->cell($rowcount,6)->as_text,
                        $tree->cell($rowcount,7)->as_text,
                        $tree->cell($rowcount,8)->as_text,
                        $tree->cell($rowcount,9)->as_text,
                        $tree->cell($rowcount,10)->as_text, # h
                        $tree->cell($rowcount,11)->as_text,
                        $tree->cell($rowcount,12)->as_text,
                        $tree->cell($rowcount,13)->as_text,
                        $tree->cell($rowcount,14)->as_text,
                        $tree->cell($rowcount,17)->as_text,
                        $tree->cell($rowcount,18)->as_text
                        );           
           
		#$isth->execute(@$row[1], @$row[2] + ".0", @$row[3], @$row[4], @$row[6], @$row[7], @$row[8], @$row[9], @$row[10], @$row[11], @$row[12], @$row[13], @$row[14], @$row[17]);
		$rowcount++;
	   }
	} 
}
