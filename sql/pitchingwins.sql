create table pitchingwins(
  age int not null,
  nameurl varchar(64) not null,
  runs_above_avg float,
  runs_above_avg_adj float,
  runs_above_rep float,
  war float  
);
alter table pitchingwins add index (nameurl); 
