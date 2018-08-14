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

my $query = "insert into teams(team, league, level, leaguehash, year) VALUES (?, ?, ?, ?, ?)";
my $isth = $dbh->prepare($query);

my $leaguesquery = "select league, level, leaguehash, year from leagues where year >= 1960";
my $leaguesth = $dbh->prepare($leaguesquery);

my $urltemplate = "http://www.baseball-reference.com/minors/leader.cgi?type=bat&id=%arg%&sort_by=slugging_perc";

$leaguesth->execute;
while (@row = $leaguesth->fetchrow_array()) {
    my ($league, $level, $leaguehash, $year) = @row;
    
    my $url = $urltemplate;
    $url =~ s|%arg%|$leaguehash|;

    insertBatters($url, $leaguehash, $league, $level, $year);    
}

exit 0;

sub insertBatters {
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
		print "ROW " . $cell . "\n";
		$cell =~ s|.*href=\"||;
		$cell =~ s|\".*||;
                $nameurl = $cell;
                $nameurl =~ s|.*id=||;
        
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

	    print "TEAM [" . $tree->cell($rowcount,3)->as_text . "] YEAR[$year]\n";
	    $isth->execute($tree->cell($rowcount,3)->as_text,
                        $league,
                        $tree->cell($rowcount,4)->as_text,
                        $lg,
                        $year
                        );           
            $rowcount++; 
	   }
	} 
}
