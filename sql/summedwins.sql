create table summedwins(
  nameurl varchar(64) not null unique,
  runs_replacement float,
  runs_above_rep float,
  runs_above_avg float,
  runs_above_avg_off float,
  war float,
  war_def float,
  war_off float,
  war_rep float
);
