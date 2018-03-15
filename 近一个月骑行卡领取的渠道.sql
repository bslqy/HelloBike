
Select t2.title,count(t2.title) from
t_user_ride_card_change_record t1
where t1.create_date > '2017-11-04 00:00:00'
and t1.create_date <  '2017-11-04 00:00:00'

inner join
(select guid from t_ride_card) t2
on t1.channel_id = t2.guid

group by
t2.title;

