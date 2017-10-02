-- Tests exercising different behaviour of the WITH RECURSIVE implementation in GPDB
-- GPDB's distributed nature requires thorough testing of many use cases in order to ensure correctness

-- Setup


-- WITH RECURSIVE ref in a sublink in the main query

create table foo(id int);
insert into foo values (1), (2), (100);

-- WITH RECURSIVE ref used with IN without correlation
with recursive r(i) as (
   select 1
   union all
   select i + 1 from r
)
select * from foo where foo.id IN (select * from r limit 10);

-- WITH RECURSIVE ref used with NOT IN without correlation

with recursive r(i) as (
   select 1
   union all
   select i + 1 from r
)
select * from foo where foo.id NOT IN (select * from r limit 10);

-- WITH RECURSIVE ref used with EXISTS without correlation

with recursive r(i) as (
   select 1
   union all
   select i + 1 from r
)
select * from foo where EXISTS (select * from r limit 10);

-- WITH RECURSIVE ref used with NOT EXISTS without correlation

with recursive r(i) as (
   select 1
   union all
   select i + 1 from r
)
select * from foo where NOT EXISTS (select * from r limit 10);

create table bar(id int);
insert into bar values (11) , (21), (31);

-- WITH RECURSIVE ref used with IN & correlation
with recursive r(i) as (
	select * from bar
	union all
	select r.i + 1 from r, bar where r.i = bar.id
)
select foo.id from foo, bar where foo.id IN (select * from r where r.i = bar.id);

-- WITH RECURSIVE ref used with NOT IN & correlation
with recursive r(i) as (
	select * from bar
	union all
	select r.i + 1 from r, bar where r.i = bar.id
)
select foo.id from foo, bar where foo.id NOT IN (select * from r where r.i = bar.id);

-- WITH RECURSIVE ref used with EXISTS & correlation
with recursive r(i) as (
	select * from bar
	union all
	select r.i + 1 from r, bar where r.i = bar.id
)
select foo.id from foo, bar where foo.id = bar.id and EXISTS (select * from r where r.i = bar.id);

-- WITH RECURSIVE ref used with NOT EXISTS & correlation
with recursive r(i) as (
	select * from bar
	union all
	select r.i + 1 from r, bar where r.i = bar.id
)
select foo.id from foo, bar where foo.id = bar.id and NOT EXISTS (select * from r where r.i = bar.id);

drop table foo;
drop table bar;
