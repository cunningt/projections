CREATE TABLE `pitcherstats` (
  uid int not null primary key,
  `nameurl` varchar(64) NOT NULL, 
  `year` int not null,
  `level` varchar(8) NOT NULL,
  `bbpercent` float NOT NULL,
  `hrpercent` float NOT NULL,
  `kpercent` float NOT NULL,
  `ksquared` float NOT NULL,
  `gspercent` float NOT NULL,
  `fip` float NOT NULL
) ENGINE=InnoDB;

