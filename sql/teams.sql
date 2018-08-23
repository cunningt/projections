create table teams (
team varchar(32) not null,
teamhash varchar(32) not null,
league varchar(32) not null,
level varchar(5) not null,
leaguehash varchar(32) not null,
year float not null,
constraint team_unique UNIQUE(team,year)
);
