[Projections](http://github.com/cunningt/projections)
======

A minor league comp system.

What is this?
------
This is a bunch of script I'm using to produce minor league comps and scoring.    I'm not sure they'll be at all useful to anyone else, but I'm putting them up because I need to back them up somewhere.

How do I use this thing?
------

You sure you want to use this?  Okay, well this isn't going to be really well documented because I'm only trying to keep this documented enough so that I know how to run it a month from now, but...

1. There's a bunch of sql scripts in [sql](sql).   Feed them into a mysql database.

2. Update batters with new year of stats.   See [parseleaderboards.pl](parseleaderboards.pl).

3. Run [stats.pl](./stats.pl) to update the stats: [stats.pl](stats.pl) derives ISO, WOBA, BB%, and K% from the parsed stats.

4. Run [averageleague.pl](averageleague.pl) to provide league averages.

5. Run [adjustedstats.pl](adjustedstats.pl) to provide adjusted stats for league.

6. Run [computedistance.py](computedistance.py) to compute the distance for age/league cohorts for each player for the current year.   Example, for 2017, we would look for all players within 6 months of Ronald Acuna's age who played AAA for Ronald Acuna's AAA stats.

7. Run [adjcomputedistance.py](adjcomputedistance.py) to compute the distance for age/league cohorts for each player for the current year.   The difference between this script and computedistance.py is that it works off of the results of [adjustedstats.pl](adjustedstats.pl), which include the adjustments to ISO/WOBA for league effects.

8. Run [compwins.pl](compwins.pl) and [weightedcompwins.pl](weightedcompwins.pl).   [compwins.pl](compwins.pl) generates scores from the comps based on MLB accumulated war_off and rar_off.   [weightedcompwins.pl](weightedcompwins.pl) does something similar, but factors in the distance between the comps and applies inverse distance weighting - so the closest comp would be weighed a lot more.

9. You now should be ready to run [rankings/generaterankings.pl](rankings/generaterankings.pl), which generates a top 100 leaderboard and comps page for each player in the top 100.


## Other scripts

A number of the other scripts here are used to generate the historical data.   [fixyears.pl](fixyears.pl) calculates what I consider "opening day age" for a season, which is the age we will use in the comps.

[summedwins.pl](summedwins.pl) figures out war_off and rar_off for each historical player, up until their age 32 season.


