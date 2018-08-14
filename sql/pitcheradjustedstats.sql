CREATE TABLE `pitcheradjustedstats` (
  uid int not null primary key,
  `bbpercent` float NOT NULL,
  `hrpercent` float NOT NULL,
  `kpercent` float NOT NULL,
  `ksquared` float NOT NULL,
  constraint team_unique UNIQUE(uid)
) ENGINE=InnoDB;
alter table pitcheradjustedstats add index (uid);
