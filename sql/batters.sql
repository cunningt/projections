create table batters (
	uid int not null primary key auto_increment,
        nameurl varchar(64) not null,
	name varchar(64) not null,
        year float not null,
	age float not null,
	team varchar(32) not null,
	league varchar(32) not null,
	level varchar(32) not null,
	games smallint not null,
 	pa smallint not null,
        ab smallint not null,
        r smallint not null,
        h smallint not null,
        doubles smallint not null,
        triples smallint not null,
        hr smallint not null,
        rbi smallint not null,
        bb smallint not null,
	so smallint not null
);

alter table batters add index (uid);
alter table batters add index (uid, level, age);
alter table batters add index (uid, year, nameurl);


