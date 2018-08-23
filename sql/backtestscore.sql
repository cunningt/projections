create table backtestscore (
   year float not null,
   score float not null,
   commithash varchar(256) not null,
   descr text not null,
   constraint comp_unique UNIQUE(year,commithash)
);

