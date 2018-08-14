create table pitchingleaguestats (
league varchar(32) not null,
year float not null,
bbpercent float not null,
bbpercentagestddev float not null,
kpercent float not null,
kpercentagestddev float not null,
hrpercent float not null,
hrpcercentagestddev float not null,
ksquared float not null,
ksquaredstddev float not null,
constraint lgstats_unique UNIQUE(league,year)
);
alter table pitchingleaguestats add index(league, year);
alter table pitchingleaguestats add index(year);
