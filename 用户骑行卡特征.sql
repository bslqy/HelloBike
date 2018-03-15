create table tmp_20171207(user_guid string)
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t';

insert into table tmp_20171207
select 
  t1.guid
from t_bike_user t1 
left join 
  (select distinct user_guid from t_free_deposit_tmp) t2 
on t1.guid=t2.user_guid 
where (t1.account_status in (0,-2,1) or t2.user_guid is not null)
limit 2000000


insert into table tmp_201712lize
select 
  t1.*,
  aaa.create_date, 
  aaa.leixing,
  aaa.add_days,
  bbb.zongshuliang,
  bbb.zhifubaoshuliang,
  bbb.quanpingtaikashuliang,
  bbb.zhifubaomianfei,
  bbb.quanpingtaimianfei,
  bbb.zhifubaogoumai,
  bbb.quanpingtaigoumai,
  ccc.zhifubaoshengyutianshu,
  ddd.quanpingtaitianshu,
  eee.zhifubaoqixingcishu,
  fff.appqixingcishu,
  ggg.chongzhizonge,
  hhh.charge_account,
  hhh.return_account,
  hhh.account_balance
from tmp_2017120701 t1 
left join
  (select 
    aa.user_guid,
    aa.create_date,
    aa.leixing,
    aa.add_days
  from 
  (select 
    t2.user_guid,
    t2.create_date,
    case when t2.platform=1 then '支付宝卡'
       when t2.platform='' then '其他'
       else '非支付宝卡' end leixing,
    t2.add_days,
    row_number() over(partition by t2.user_guid order by t2.create_date desc)num
   from t_user_ride_card_change_record t2 
   where t2.event_type in (1,3,4))aa
  where aa.num=1)aaa 
on t1.user_guid=aaa.user_guid 

left join 
  (select 
    t1.user_guid,
    count(t1.user_guid)zongshuliang,
    count(case when t1.platform=1 then t1.user_guid end)zhifubaoshuliang, 
    count(case when t1.platform=0 then t1.user_guid end)quanpingtaikashuliang,
    sum(case when t1.platform=1 and t1.event_type=1 then t1.add_days end ) zhifubaomianfei,
    sum(case when t1.platform=0 and t1.event_type=1 then t1.add_days end)quanpingtaimianfei,
    sum(case when t1.platform=1 and t1.event_type=3 then t1.add_days end) zhifubaogoumai,
    sum(case when t1.platform=0 and t1.event_type=3 then t1.add_days end)quanpingtaigoumai
  from  t_user_ride_card_change_record t1 
  where t1.event_type in (1,3,4)
  group by t1.user_guid)bbb 
on t1.user_guid=bbb.user_guid 
left join 
  (select 
    aa.user_guid,
    aa.days1 zhifubaoshengyutianshu
  from 
  (select 
    t1.user_guid,
    datediff(current_date,t1.expire_date) days1,
    row_number() over(partition by t1.user_guid order by t1.create_date desc)num 
  from t_user_ride_card_change_record t1 
  where t1.event_type in (1,3,4) and t1.platform=1)aa
  where aa.num=1)ccc 
on t1.user_guid=ccc.user_guid 
left join 
  (select 
    aa.user_guid,
    aa.days1 quanpingtaitianshu 
  from 
  (select 
    t1.user_guid,
    datediff(current_date,t1.expire_date) days1,
    row_number() over(partition by t1.user_guid order by t1.create_date desc)num 
  from t_user_ride_card_change_record t1 
  where t1.event_type in (1,3,4) and t1.platform=0)aa
  where aa.num=1)ddd
on t1.user_guid=ddd.user_guid 
left join 
(select 
  t1.user_guid,
  count(t1.user_guid) zhifubaoqixingcishu
from t_tmp_ride t1 
where t1.account_type<>-1 
    and t1.account_type<>3 
    and t1.ride_status in (1,2)
    and ((t1.platform=3 and t1.system_code='63') or (t1.system_code='65'))
group by t1.user_guid )eee 
on t1.user_guid=eee.user_guid 
left join 
(select 
  t1.user_guid,
  count(t1.user_guid) appqixingcishu
from t_tmp_ride t1 
where t1.account_type<>-1 
    and t1.account_type<>3 
    and t1.ride_status in (1,2)
    and (t1.system_code='61' or t1.system_code='62')
group by t1.user_guid )fff
on t1.user_guid=fff.user_guid 
left join 
  (select 
    t1.user_guid,
    sum(t1.charge_money)chongzhizonge
  from t_charge_info t1 
  where t1.charge_type=1 and t1.charge_status=1 and t1.account_type<>-1 and t1.account_type<>3
  group by t1.user_guid)ggg 
on t1.user_guid=ggg.user_guid 
left join 
  t_bike_user hhh 
on t1.user_guid=hhh.guid 



create table tmp_2017120701(user_guid string,mobile_phone string,zhucecity_name string,qixingcity_name string,zhuangtai string)
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t';
insert into table tmp_2017120701
select  
  t1.user_guid,
  t2.mobile_phone,
  t2.city_name,
  b.city_name,
  case when t2.account_status=0 then '激活'
     when t2.account_status=-2 and bbb1.mianyatype is not null then bbb1.mianyatype
     when t2.account_status=-2 and bbb1.mianyatype is null then '退款'
     when t2.account_status=-1 then '未激活'
     when t2.account_status=1 then '已充值'
     else '其他'
  end 
from tmp_20171207 t1 
left join t_bike_user t2 
on t1.user_guid=t2.guid
left join 
  (select 
    aa.user_guid,
    aa.city_name
  from 
  (select 
    t1.user_guid,
    t1.city_name,
    row_number() over(partition by t1.user_guid order by t1.create_time asc) num 
  from t_tmp_ride t1 
  where t1.account_type<>-1 
        and t1.account_type<>3 
        and t1.ride_status in (0,1))aa 
  where aa.num=1)b
on t1.user_guid=b.user_guid 
left join 
(select 
  bb1.user_guid,
  case when bb1.free_deposit_type=4 then '芝麻免押'
     when bb1.free_deposit_type=5 then '大学生免押'
     when bb1.free_deposit_type=1 then '普通免押'
  end mianyatype
from 
  (select 
    t1.user_guid,
    t1.free_deposit_type,
    row_number() over(partition by t1.user_guid order by t1.free_deposit_start_date desc) num 
  from t_free_deposit_tmp t1 
  where current_timestamp>=t1.free_deposit_start_date and t1.free_deposit_shixiao_date>current_timestamp
      and (t1.free_deposit_shixiao_date>=current_date or t1.free_deposit_shixiao_date<>''))bb1)bbb1 
on t1.user_guid=bbb1.user_guid 


