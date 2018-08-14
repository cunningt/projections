create table adjpitchercomps (
   uid int not null,
   year float not null,
   compuid int not null,
   mahalanobis float not null,
   euclidean float not null,
   constraint comp_unique UNIQUE(uid,year,compuid)
);
alter table adjpitchercomps add index(compuid,year);
alter table adjpitchercomps add index(uid,year);
