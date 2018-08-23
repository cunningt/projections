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

my $query = "insert into teams(team, teamhash, league, level, leaguehash, year) VALUES (?, ?, ?, ?, ?, ?)";
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
        
            my $teamid = "";
            my $html = $tree->cell($rowcount,3)->as_HTML;
		    print "HTML [$html]\n";
            if ($html =~ m|team.cgi\?id=([^\"]+)|) {
                $teamid = $1;
            }

	        print "TEAM [" . $tree->cell($rowcount,3)->as_text 
                . "] YEAR[$year] ID[$teamid]\n"; 
            $isth->execute($tree->cell($rowcount,3)->as_text,
			    $teamid, $league, $tree->cell($rowcount,4)->as_text,
                $lg, $year);           
            $rowcount++; 
	   }
	} 
}
