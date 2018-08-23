create table backtestranking (
   uid int not null,
   nameurl varchar(32) not null,
   level varchar(6) not null,
   ranking int not null,
   year float not null,
   commithash varchar (64) not null,
   constraint comp_unique UNIQUE(nameurl,level,ranking)
);

