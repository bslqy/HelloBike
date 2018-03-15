-- 杭州、温州2个城市截至12月7日24点和13日24点的大学生双免人数
Select count(t2.user_guid),
case when t2.c2 = '杭州市' then '杭州市'
when t2.c2 = '温州市' then '温州市' end city

from t_student_award_record_plus t1
left join
(select b.guid user_guid ,b.city_name c2 from t_bike_user b
where b.city_name In('杭州市','温州市')
) t2
on t1.user_guid = t2.user_guid

where t1.award_type = 0
and t1.create_date < '2017-12-08 00:00:00' 

group by 
case when t2.c2 = '杭州市' then '杭州市'
when t2.c2 = '温州市' then '温州市' end;


Select count(t2.user_guid),
case when t2.c2 = '杭州市' then '杭州市'
when t2.c2 = '温州市' then '温州市' end city

from t_student_award_record_plus t1
left join
(select b.guid user_guid ,b.city_name c2 from t_bike_user b
where b.city_name In('杭州市','温州市')
) t2
on t1.user_guid = t2.user_guid

where t1.award_type = 0
and t1.create_date < '2017-12-14 00:00:00' 

group by 
case when t2.c2 = '杭州市' then '杭州市'
when t2.c2 = '温州市' then '温州市' end;


-- 新城开城活动需要对三城新用户进行促动，现需要拉取青岛、韶光、绵阳地区注册未激活的用户名单，提供手机号即可。
-- account_status =-1  包括了免押金的

Insert overwrite local directory '/home/deploy/liaojia/3_city'
row format delimited fields terminated by "\t" 
select mobile_phone,city_name
from t_bike_user t
left join 
(select d.user_guid id from t_user_free_deposit d) haha
on haha.id = t.guid

where t.city_name in ('青岛市','韶关市','绵阳市')
and t.account_type <> -1
and t.account_type <> 3
and t.deposit <> 0.01
and t.account_status = -1
and haha.id is NULL; -- 免押对得上的不要





