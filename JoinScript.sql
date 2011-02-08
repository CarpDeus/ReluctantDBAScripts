create table table1 (ID int, Value char(20))
create table table2 (ID int, Value char(20))
create table table3 (ID1 int, ID2 int)
create table table4 (ID int, Value char(20))
create table table5 (ID1 int, ID2 int)
create table table6 (ID int, Value char(20))
create table table7 (ID1 int, ID2 int)


INSERT INTO table1 values(1, 'The')
INSERT INTO table1 values(2, 'Quick')
INSERT INTO table1 values(3, 'Brown')
INSERT INTO table1 values(4, 'Fox')

INSERT INTO table2 values(5, 'Jumped')
INSERT INTO table2 values(6, 'Over')
INSERT INTO table2 values(7, 'The')
INSERT INTO table2 values(8, 'Lazy')

INSERT INTO table6 values(9, 'Brown')
INSERT INTO table6 values(10, 'Fox')
INSERT INTO table6 values(11, 'Jumped')



insert into table3 values(1,5)
insert into table3 values(4,5)
insert into table3 values(3,6)
insert into table3 values(2,7)
insert into table3 values(1,8)
insert into table3 values(4,8)

insert into table5 values(5,9)
insert into table5 values(7,9)
insert into table5 values(5,10)
insert into table5 values(7,10)
insert into table5 values(5,11)
insert into table5 values(7,11)

insert into table7 values(1,9)
insert into table7 values(4,9)
insert into table7 values(1,10)

SELECT     a.ID AS aID, a.Value AS aValue, c.ID AS cID, c.Value AS cValue, 
	e.ID AS eID, e.Value AS eValue, g.ID AS gID, g.Value AS gValue
FROM         dbo.table1 AS a INNER JOIN dbo.table2 AS c INNER JOIN
	dbo.table3 AS b ON c.ID = b.ID2 ON b.ID1 = a.ID INNER JOIN
	dbo.table7 AS f INNER JOIN dbo.table6 AS g ON f.ID2 = g.ID 
	ON a.ID = f.ID1 LEFT OUTER JOIN dbo.table4 AS e INNER JOIN
	dbo.table5 AS d ON e.ID = d.ID2 ON c.ID = d.ID1
WHERE     (a.ID = 3)

--drop table table1
--drop table table2
--drop table table3
--drop table table4
--drop table table5
--drop table table6
--drop table table7

