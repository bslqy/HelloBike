select 
  aa.end_time,
  dd.city,
  count(distinct dd.user_guid),
  count(case when dd.leixing='单车转化新增用户' then 1 end),
  count(case when dd.leixing='纯电单车新增用户' then 1 end)
from
  (select 
    t1.daily_date start_time,
    date_add(t1.daily_date,6) end_time
  from t_daily_date t1 
  where t1.daily_date>='2017-09-19')aa
left join
  (select 
    bb.date1,
    bb.city city,
    bb.user_guid,
    case when cc.user_guid is null then '纯电单车新增用户'
        when cc.user_guid is not null then '单车转化新增用户' end leixing
  from 
    (select 
      aa.date1,
      aa.user_guid,
      aa.city,
    from 
      (select 
        substr(t1.start_time,1,10)date1,
        t1.user_guid,
        t1.city_name city,
        row_number() over(partition by t1.user_guid order by t1.start_time asc)num 
      from t_ev_ride_info t1 
      where t1.start_time>='2017-09-19 00:00:00'
          and t1.account_type<>-1 
          and t1.account_type<>3 
          and t1.ride_status in (1,2)
          and t1.city_name in ('淄博市','东营市','洛阳市','泉州市'))aa 
    where aa.num=1)bb
  left join 
    (select 
      distinct 
      t1.user_guid
    from t_tmp_ride t1 
    where t1.account_type<>-1 
        and t1.account_type<>3 
        and t1.ride_status in (1,2)
        and t1.city_name in ('淄博市','东营市','洛阳市','泉州市'))cc 
  on bb.user_guid=cc.user_guid)dd 
on 1=1 
where 
  dd.date1>=aa.start_time and dd.date1<=aa.end_time 
group by 
  aa.end_time,dd.city 