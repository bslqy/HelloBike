Insert overwrite local directory '/home/deploy/liaojia/jiangsu'
row format delimited fields terminated by "\t"

select case when 
 t2.days >=100 THEN '>100'
 when  
 t2.days >90 and t2.days <100 THEN '91-99'
 when  
 t2.days >60 and t2.days <=90 THEN '61-90'
 when  
 t2.days >45 and t2.days <=60 THEN '46-60'
 when  
 t2.days >30 and t2.days <=45 THEN '31-45'
 when  
 t2.days >0 and t2.days <=30 THEN '1-30'
 when
 t2.days  = 0 THEN '0'
END remainingDays

,count(t1.guid) as total_hangzhou_user
,count(t2.t2id)/count(t1.guid) as Percentage
from t_bike_user t1  
left join

(Select b.user_guid active_user  
from
(select user_guid
,max(create_date) date1
from t_charge_info
where create_date<'2017-12-06 00:00:00'
and charge_type=0
and charge_status=1
group by user_guid) b

left join 
-- 12/1 日前退押金的人 12/1 前每个人退押金最晚的时间
(select user_guid 
,max(create_date) date2
from t_charge_info
where create_date<'2017-12-06 00:00:00'
and charge_type=2
and charge_status=-2
group by user_guid) t1

on b.user_guid=t1.user_guid

-- 充押晚于退押 或者 没退押 
where b.date1>t1.date2 or t1.date2 is null or t1.date2='') t3


on t1.guid = t3.active_user

left join
(
select 
 dates.user_guid t2id,
 datediff('2017-12-06 00:00:00',dates.remainingDays) days
 
 -- date table
 -- 判断是支付宝卡还是全平台卡比较晚过期？以最晚过期的为准 
from 
(select user_guid
,
case when instr(expire_info,'"platform": 0, "expireDate": ')<>0 and instr(expire_info,'"platform": 1, "expireDate": ')<>0
and to_date(substr(expire_info,instr(expire_info,'"platform": 0, "expireDate": "')+30,10))>to_date(substr(expire_info,instr(expire_info,'"platform": 1, "expireDate": "')+30,10)) 
then 
to_date(substr(expire_info,instr(expire_info,'"platform": 0, "expireDate": "')+30,10))

when instr(expire_info,'"platform": 0, "expireDate": ')<>0 and instr(expire_info,'"platform": 1, "expireDate": ')<>0
and to_date(substr(expire_info,instr(expire_info,'"platform": 0, "expireDate": "')+30,10))<=to_date(substr(expire_info,instr(expire_info,'"platform": 1, "expireDate": "')+30,10)) 
then 
to_date(substr(expire_info,instr(expire_info,'"platform": 1, "expireDate": "')+30,10))

when instr(expire_info,'"platform": 0, "expireDate": ')<>0 and instr(expire_info,'"platform": 1, "expireDate": ')=0
then 
to_date(substr(expire_info,instr(expire_info,'"platform": 0, "expireDate": "')+30,10))

when instr(expire_info,'"platform": 1, "expireDate": ')<>0 and instr(expire_info,'"platform": 0, "expireDate": ')=0
then 
to_date(substr(expire_info,instr(expire_info,'"platform": 1, "expireDate": "')+30,10))
else null end remainingDays
from 
t_month_card) dates) t2 
on t1.guid=t2.t2id



where t1.city_name='杭州市'
and t1.account_type<>-1
and t1.account_type<>3
and t1.deposit<>0.01
and t3.active_user is not NULL
group by case when 
 t2.days >=100 THEN '>100'
 when  
 t2.days >90 and t2.days <100 THEN '91-99'
 when  
 t2.days >60 and t2.days <=90 THEN '61-90'
 when  
 t2.days >45 and t2.days <=60 THEN '46-60'
 when  
 t2.days >30 and t2.days <=45 THEN '31-45'
 when  
 t2.days >0 and t2.days <=30 THEN '1-30'
 when
 t2.days  = 0 THEN '0'
END;