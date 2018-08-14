CREATE TABLE `pitchers` (
  `uid` int(11) NOT NULL AUTO_INCREMENT,
  `nameurl` varchar(64) NOT NULL, 
  `name` varchar(192) NOT NULL, 
  `year` float NOT NULL,
  `age` float NOT NULL, 
  `team` varchar(12) NOT NULL, 
  `league` varchar(12) NOT NULL, 
  `level` varchar(12) NOT NULL,
  `g` smallint(6) NOT NULL,
  `gs` smallint(6) NOT NULL, 
  `bf` smallint(6) NOT NULL, 
  `ip` float NOT NULL, 
  `h` smallint(6) NOT NULL, 
  `r` smallint(6) NOT NULL, 
  `er` smallint(6) NOT NULL, 
  `bb` smallint(6) NOT NULL, 
  `so` smallint(6) NOT NULL, 
  `hbp` smallint(6) NOT NULL, 
  `hr` smallint(6) NOT NULL, 
  constraint pitcher_unique UNIQUE(nameurl,year,league),
PRIMARY KEY `PRIMARY` (`uid`)
) ENGINE=InnoDB;

alter table pitchers add index (uid);
alter table pitchers add index (uid, level, age);
alter table pitchers add index (uid, year, nameurl);
