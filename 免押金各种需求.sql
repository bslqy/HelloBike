
create table tmp_20171207(user_guid string)
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t';
 
insert into table card_user
	SELECT
		b.guid
	from t_bike_user b
	left join 
	(SELECT DISTINCT user_guid FROM t_free_deposit_temp) t2
	on b.guid = t2.user_guid
	WHERE (t1.account_status in (0,-2,1) or t2.user_guid is not null)
	LIMIT 2000000


insert into table card_info
SELECT
	card_user.*,
	card_info.create_date,
	card_info.type,
	card_info.TotalDays,
	card_spec.TotalCount,
	card_spec.AliCount,
	card_spec.ApCount,
	card_spec.AliFreeDays,
	card_spec.ApFreeDays
	card_spec.AliPurchasedDays,
	card_spec.ApPurchasedDays,
	leftOver1.Ali,
	leftOver2.Ap,
	rideCount1.Ali,
	rideCount2.Ap,
	ggg.ChargeTotal,
	balance.charge_account,
	balance.return_account,
	balance.account_balance
FROM card_user 

left join
(SELECT aa.user_guid,
		aa.create_date,
		aa.type,
		aa.TotalDays
 FROM
 	(SELECT 
 		t2.user_guid,
 		t2.create_date,
 		case when t2.platform = 1 then 'Alipay'
 		when t2.platform = '' then 'Other'
 		else 'None Alipay' end type,
 		t2.TotalDays,
 		row_number() OVER (Partition BY t2.user_guid order by t2.create_date DESC) num
 		from t_user_ride_card_change_recrod t2
 		where t2.event_type in (1,3,4))aa
 	where aa.num = 1) card_info
on card_user.user_guid = card_info.user_guid

left join
(
	SELECT
	t1.user_guid,
	count(t1.user_guid) TotalCount,
	count(case when t1.platform = 1 then t1.user_guid end) AliCount
	count(case when t1.platform = 0 then t1.user_guid end) ApCount
	sum(case when t1.platform=1 and t1.event_type=1 then t1.add_days end)AliFreeDays,
    sum(case when t1.platform=0 and t1.event_type=1 then t1.add_days end)ApFreeDays,
    sum(case when t1.platform=1 and t1.event_type=3 then t1.add_days end)AliPurchasedDays,
    sum(case when t1.platform=0 and t1.event_type=3 then t1.add_days end)ApPurchasedDays
  from  t_user_ride_card_change_record t1 
  where t1.event_type in (1,3,4) -- Have card and active
  group by t1.user_guid) card_spec 

on card_user.user_guid=card_spec.user_guid 

left join
(
	(SELECT t1.user_guid,
		datediff(current_date,t1.expire_date) days1,
		row_number() OVER (Partition BY t1.user_guid order by t1.create_date DESC)num
		from t_user_ride_card_change_record t1
		where t1.event_type in (1,3,4) and t1.platform = 1)aa
		where aa.num = 1
 
) leftOver1

on card_user.user_guid = leftOver1.user_guid

left join
(
	(SELECT t1.user_guid,
		datediff(current_date,t1.expire_date) days1,
		row_number() OVER (Partition BY t1.user_guid order by t1.create_date DESC)num
		from t_user_ride_card_change_record t1
		where t1.event_type in (1,3,4) and t1.platform = 1)aa
		where aa.num = 1

) leftOver2

on card_user.user_guid = leftOver2.user_guid

left join
(
	(SELECT t1.user_guid,
		COUNT(t1.user_guid)
		-- user_guid is not unique , so need to group by the COUNT()
		from temp_t_ride_info t1
		where t1.account_type<>-1 
    	and t1.account_type<>3 
	    and t1.ride_status in (1,2)
	    and ((t1.platform=3 and t1.system_code='63') or (t1.system_code='65'))
		group by t1.user_guid)
 
) rideCount1

on card_user.user_guid = rideCount1.user_guid

left join
(
	(SELECT t1.user_guid,
		COUNT(t1.user_guid)
		-- user_guid is not unique , so need to group by the COUNT()
		from temp_t_ride_info t1
		where t1.account_type<>-1 
    	and t1.account_type<>3 
	    and t1.ride_status in (1,2)
	    and ((t1.platform=3 and t1.system_code='63') or (t1.system_code='65'))
		group by t1.user_guid)
 
) rideCount2

on card_user.user_guid = rideCount2.user_guid


create table tmp_2017120701 (user_guid string,mobile_phone string,zhucecity_name string,qixingcity_name string,zhuangtai string)
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t';
insert into table tmp_2017120701
select  
  t1.user_guid,
  t2.mobile_phone,
  t2.city_name, -- register city
  b.city_name,  -- first ride city
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
  -- No test account
  where t1.account_type<>-1 
        and t1.account_type<>3 
        and t1.ride_status in (0,1))aa 
  where aa.num=1
  )b

on t1.user_guid=b.user_guid 

left join 
-- Aka bb1, Chinese translation of 
(select 
  bb1.user_guid,
  case when bb1.free_deposit_type=4 then '芝麻免押'
     when bb1.free_deposit_type=5 then '大学生免押'
     when bb1.free_deposit_type=1 then '普通免押'
  end mianyatype
from 
	-- All the user whose free deposit period has not expired. Aka. bb1
  (select 
    t1.user_guid,
    -- the free_deposit_type from here
    t1.free_deposit_type,
    row_number() over(partition by t1.user_guid order by t1.free_deposit_start_date desc) num 
  from t_free_deposit_tmp t1 
  where current_timestamp>=t1.free_deposit_start_date and t1.free_deposit_shixiao_date>current_timestamp
      and (t1.free_deposit_shixiao_date>=current_date or t1.free_deposit_shixiao_date<>'')
    )bb1

  )bbb1 
on t1.user_guid=bbb1.user_guid 



(select 
  t1.user_guid,
    case when t1.free_deposit_type=4 then '芝麻免押'
       when t1.free_deposit_type=5 then '大学生免押'
       when t1.free_deposit_type=1 then '普通免押'
    end mianyatype
  from t_free_deposit_tmp t1
   where current_timestamp>=t1.free_deposit_start_date and t1.free_deposit_shixiao_date>current_timestamp
        and (t1.free_deposit_shixiao_date>=current_date or t1.free_deposit_shixiao_date<>'') 
on t1.user_guid=bbb1.user_guid
) bbb1





Insert overwrite local directory '/home/deploy/liaojia'
row format delimited fields terminated by "\t"

SELECT t1.user_guid AS Card,COUNT(t2.guid) AS Activation ,COUNT(t3.guid) AS Deposit
FROM t_user_ride_card_change_record t1
left join (SELECT b.guid FROM t_bike_user b WHERE b.account_status = 0) t2
ON t2.guid = t1.user_guid

left join 
(SELECT c.user_guid from t_charge_info c 
WHERE c.charge_type = 0 
AND c.charge_status = 1
AND c.create_date >= '2017-09-12 10:56:00.669'  
AND c.create_date <= '2017-12-11 00:00:00') t3
ON t3.user_guid = t1.user_guid
WHERE t1.channel_guid 
IN("1b70b33bd96c401aba91bb45cc85f544",
"bd99d02589b24f4890130e3809d28765",
"faa0a3b640e546fa8d9a33c39d975232",
"e329fb9b4a0d4ed4a9eee4574140ae7d",
"d45575b06d1a40daaf3822c88c70700c",
"fa801cefb96f4c89b948a54c587b13ef",
"b3a46f2ef45b4c05a1d63aa7b284a270",
"9b99707488a34cbbbaa6a7696796485d",
"d5736a479bf747f29979f678f7f63e42",
"f745604f49cd4dab818d7d1fa6caa20f",
"43d512dee8424dbdb8f71472208ef67e",
"f49e730f0b6746b3a2b01a911069f587",
"7a9d9bea1dad4bff8daf598f5d5e63e8",
"8cda6377d28c48e2b2fa36b7df012a01",
"845eef4a7bfa4609b7410c757c43fc06",
"e45e4233a0824881a8f7dae7e8ec3e6a",
"7c5d8b805206402dbeec9e85809a9a39",
"3a28de7bca494536b156039dbcb90b0e",
"09f6c4809c4e44c9b522bdc77590f5e9",
"f8a21b585b884dc598d06e544255c648",
"0521f4d8718340849222a969c562ccbb",
"50ec228f09224e8993349210cc511c93",
"17f994229f314e8e92f5a940f510e439");


-- Min Time
SELECT MIN(get_time) FROM t_user_ride_card_change_record 
WHERE channel_guid 
IN("1b70b33bd96c401aba91bb45cc85f544",
"bd99d02589b24f4890130e3809d28765",
"faa0a3b640e546fa8d9a33c39d975232",
"e329fb9b4a0d4ed4a9eee4574140ae7d",
"d45575b06d1a40daaf3822c88c70700c",
"fa801cefb96f4c89b948a54c587b13ef",
"b3a46f2ef45b4c05a1d63aa7b284a270",
"9b99707488a34cbbbaa6a7696796485d",
"d5736a479bf747f29979f678f7f63e42",
"f745604f49cd4dab818d7d1fa6caa20f",
"43d512dee8424dbdb8f71472208ef67e",
"f49e730f0b6746b3a2b01a911069f587",
"7a9d9bea1dad4bff8daf598f5d5e63e8",
"8cda6377d28c48e2b2fa36b7df012a01",
"845eef4a7bfa4609b7410c757c43fc06",
"e45e4233a0824881a8f7dae7e8ec3e6a",
"7c5d8b805206402dbeec9e85809a9a39",
"3a28de7bca494536b156039dbcb90b0e",
"09f6c4809c4e44c9b522bdc77590f5e9",
"f8a21b585b884dc598d06e544255c648",
"0521f4d8718340849222a969c562ccbb",
"50ec228f09224e8993349210cc511c93",
"17f994229f314e8e92f5a940f510e439");


