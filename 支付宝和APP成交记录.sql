Insert overwrite local directory '/home/deploy/liaojia/zibo'
row format delimited fields terminated by "\t"



Select 
	jihuo.guid,
	jihuo.mobile_phone,
	bikeCount.zhifubao,
	bikeCount.app,
	ev.zhifubao,
	ev.app,
	charge.total_charge,
	charge.total_time
from t_bike_user jihuo
left join

(select t1.user_guid,
count(case when t1.platform=3 then 1 end) zhifubao,
count(case when t1.platform is null or t1.platform='' then 1 end)app
from t_tmp_ride t1
where t1.account_type<>-1
and t1.account_type<>3 
and t1.ride_status in (1,2)
group by t1.user_guid)bikeCount

on jihuo.guid = bikeCount.user_guid

left join
(select t1.user_guid,
count(case when t1.platform=3 then 1 end) zhifubao,
count(case when t1.platform is null or t1.platform='' then 1 end)app

from t_ev_ride_info t1
where t1.account_type<>-1
and t1.account_type<>3 
and t1.ride_status in (1,2)
group by t1.user_guid)evCount

on jihuo.guid = b.user_guid

left join

(select 
    t1.user_guid,
    count(t1.user_guid)total_time,
    sum(t1.charge_money)total_charge
  from t_charge_info t1 
  where t1.charge_type=1
      and t1.charge_status=1
      and t1.account_type<>-1
      and t1.account_type<>3
  group by t1.user_guid)charge 

on jihuo.guid=c.user_guid 

where jihuo.city_name='淄博市'
and jihuo.account_status=0








