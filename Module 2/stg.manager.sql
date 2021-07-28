DROP TABLE IF EXISTS stg.manager;
CREATE TABLE stg.manager(
   Person VARCHAR(17) NOT NULL PRIMARY KEY
  ,Region VARCHAR(7) NOT NULL
);
INSERT INTO stg.manager(Person,Region) VALUES ('Anna Andreadi','West');
INSERT INTO stg.manager(Person,Region) VALUES ('Chuck Magee','East');
INSERT INTO stg.manager(Person,Region) VALUES ('Kelly Williams','Central');
INSERT INTO stg.manager(Person,Region) VALUES ('Cassandra Brandow','South');
