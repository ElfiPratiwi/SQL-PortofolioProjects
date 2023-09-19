use porto;

create table booking (
	booking_id varchar (255),
    booking_date date,
    user_id varchar (255),
    line_of_business varchar (255)
);

insert into booking values
	('b1', '2022-03-23', 'u1', 'Flight'),
    ('b2', '2022-03-27', 'u2', 'Flight'),
    ('b3', '2022-03-28', 'u1', 'Hotel'),
    ('b4', '2022-03-31', 'u4', 'Flight'),
    ('b5', '2022-04-02', 'u1', 'Hotel'),
    ('b6', '2022-04-02', 'u2', 'Flight'),
    ('b7', '2022-04-06', 'u5', 'Flight'),
    ('b8', '2022-04-06', 'u6', 'Hotel'),
    ('b9', '2022-04-06', 'u2', 'Flight'),
    ('b10', '2022-04-10', 'u1', 'Flight'),
    ('b11', '2022-04-12', 'u4', 'Flight'),
    ('b12', '2022-04-16', 'u1', 'Flight'),
    ('b13', '2022-04-19', 'u2', 'Flight'),
    ('b14', '2022-04-20', 'u5', 'Hotel'),
    ('b15', '2022-04-22', 'u6', 'Flight'),
    ('b16', '2022-04-26', 'u4', 'Hotel'),
    ('b17', '2022-04-28', 'u2', 'Hotel'),
    ('b18', '2022-04-30', 'u1', 'Hotel'),
    ('b19', '2022-05-04', 'u4', 'Hotel'),
    ('b20', '2022-05-06', 'u1', 'Flight');
    

create table user(
	user_id varchar (255),
    segment varchar (255)
);

insert into user values
	('u1', 's1'),
    ('u2', 's1'),
    ('u3', 's1'),
    ('u4', 's2'),
    ('u5', 's2'),
    ('u6', 's3'),
    ('u7', 's3'),
    ('u8', 's3'),
    ('u9', 's3'),
    ('u10', 's3');
select * from booking;
select * from user;

-- case study :
-- 1. Write a SQL query that gives output
-- (segment, total user count, user who booked flight in april 2022)

select
	u.segment,
    count(distinct u.user_id) as user_count,
    count(distinct case when b.line_of_business = 'Flight' and booking_date between '2022-04-01' and '2022-04-30' then b.user_id end) as user_booked_flight_in_april2022
from
	user u
left join
	booking b
on
	u.user_id = b.user_id
group by
	u.segment;

-- 2. write a query to identify users whose first booking was hotel booking
with ranking as (
select *,
	rank() over(partition by user_id order by booking_date) as rn
from booking
order by user_id
)
select *
from ranking
where rn = 1 and line_of_business = 'Hotel';

-- 3. write a query to calculate the days between first and last booking of each user
select
	user_id,
    min(booking_date) as first_booking,
    max(booking_date) as last_booking,
	datediff(max(booking_date), min(booking_date)) as gap
from booking
group by user_id;

-- 4. write a query to count the number of flight and hotel booking in each of the user segments for the year 2022
select
	u.segment,
	sum(case when line_of_business = 'Flight' then 1 else 0 end) as Flight_flag,
    sum(case when line_of_business = 'Hotel' then 1 else 0 end) as Hotel_flag
from 
	booking b
inner join
	user u
on b.user_id = u.user_id
where extract(year from booking_date) = 2022
group by u.segment;



