DROP TABLE IF EXISTS grp_lab;
CREATE TABLE grp_lab (
     name varchar(255) not null,
     label varchar(255) not null,
     priority float not null,
     PRIMARY KEY(name)
);
 INSERT grp_lab VALUES("lab", "Brainard tracks", 0.5);
