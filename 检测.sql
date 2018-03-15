select max(expire_date) from t_user_ride_card_change_record
where user_guid in
('66309645c107430fbedf051c105bf7fc',
'2e932cb42ea64e2dabb4aa18521718f8',
'50fedf5088f14a669a855c9af8b567c3')
group by user_guid;




select user_guid,max(expire_date) from bike.t_user_ride_card_change_record
where user_guid in
('66309645c107430fbedf051c105bf7fc',
'2e932cb42ea64e2dabb4aa18521718f8',
'50fedf5088f14a669a855c9af8b567c3')
group by user_guid;



select max(expire_date) from bike.t_user_ride_card_change_record
where user_guid in
('66309645c107430fbedf051c105bf7fc')
group by user_guid;



select 
 user_guid,
 remainingDays
 
 -- date table
 -- 判断是支付宝卡还是全平台卡比较晚过期？以最晚过期的为准 
from 
(select user_guid,
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
from  t_month_card
where user_guid in ('66309645c107430fbedf051c105bf7fc',
'2e932cb42ea64e2dabb4aa18521718f8',
'50fedf5088f14a669a855c9af8b567c3')
) dates

group by user_guid,remainingDays;

select user_guid,create_date,expire_info from t_month_card where user_guid  
in ('66309645c107430fbedf051c105bf7fc',
'2e932cb42ea64e2dabb4aa18521718f8',
'50fedf5088f14a669a855c9af8b567c3')
group by user_guid,create_date,expire_info;


50fedf5088f14a669a855c9af8b567c3        2017-09-02 16:01:26.721 [{"platform": 0, "expireDate": "2018-03-15", "aliCouponSN": "da6d21784dd14236846616d9c27e87fa", "freeCardStartDate": "2017-09-02T16:01:26.721", "freeCardExpireDate": "2017-10-16", "noFreeCardStartDate": "2017-10-17 00:00:00", "noFreeCardExpireDate": "2018-03-15"}]
66309645c107430fbedf051c105bf7fc        2017-12-16 16:40:11.67  [{"platform": 0, "expireDate": "2018-03-15", "aliCouponSN": "73a8f9e91f844eb0b971ca718eba3989", "freeCardStartDate": "2017-12-16T16:40:11.670", "freeCardExpireDate": "2018-03-15"}]
2e932cb42ea64e2dabb4aa18521718f8        2017-12-06 19:44:56.469 [{"platform": 0, "expireDate": "2018-03-15", "aliCouponSN": "b2b60bfc9b9745bc87321b013f859db9", "freeCardStartDate": "2017-12-06T19:44:56.469", "freeCardExpireDate": "2018-03-05", "noFreeCardStartDate": "2018-03-06 00:00:00", "noFreeCardExpireDate": "2018-03-15"}]


select user_guid,create_date,expire_date from t_user_ride_card_change_record where user_guid  
in ('66309645c107430fbedf051c105bf7fc',
'2e932cb42ea64e2dabb4aa18521718f8',
'50fedf5088f14a669a855c9af8b567c3')
group by user_guid,create_date,expire_date;




50fedf5088f14a669a855c9af8b567c3        2017-09-02 16:01:26.721 2017-10-16 00:00:00.0
66309645c107430fbedf051c105bf7fc        2017-12-17 16:31:01.718 2018-06-14 00:00:00.0
2e932cb42ea64e2dabb4aa18521718f8        2017-12-16 20:35:02.358 2018-07-13 00:00:00.0

2e932cb42ea64e2dabb4aa18521718f8        2017-12-06 20:11:17.834 2018-03-05 00:00:00.0
66309645c107430fbedf051c105bf7fc        2017-12-16 16:40:11.67  2018-01-29 00:00:00.0
2e932cb42ea64e2dabb4aa18521718f8        2017-12-06 19:44:56.469 2018-01-19 00:00:00.0
2e932cb42ea64e2dabb4aa18521718f8        2017-12-16 20:34:09.971 2018-01-14 00:00:00.0
2e932cb42ea64e2dabb4aa18521718f8        2017-12-06 20:38:04.645 2018-03-15 00:00:00.0


select user_guid,create_date,expire_date from t_user_ride_card_change_record where user_guid  
in ('2e932cb42ea64e2dabb4aa18521718f8')
group by user_guid,create_date,expire_date
order by create_date ASC;

2e932cb42ea64e2dabb4aa18521718f8        2017-12-06 19:44:56.469 2018-01-19 00:00:00.0
2e932cb42ea64e2dabb4aa18521718f8        2017-12-06 20:11:17.834 2018-03-05 00:00:00.0
2e932cb42ea64e2dabb4aa18521718f8        2017-12-06 20:38:04.645 2018-03-15 00:00:00.0
2e932cb42ea64e2dabb4aa18521718f8        2017-12-16 20:34:09.971 2018-01-14 00:00:00.0
2e932cb42ea64e2dabb4aa18521718f8        2017-12-16 20:35:02.358 2018-07-13 00:00:00.0


select user_guid,free_deposit_type from t_free_deposit_tmp where user_guid  
in ('66309645c107430fbedf051c105bf7fc',
'2e932cb42ea64e2dabb4aa18521718f8',
'50fedf5088f14a669a855c9af8b567c3')
group by user_guid,free_deposit_type

select * from t_free_deposit_tmp where user_guid  
in ('50fedf5088f14a669a855c9af8b567c3')



-- 用户1 三号免押
-- change record
50fedf5088f14a669a855c9af8b567c3        2017-09-02 16:01:26.721 '2017-10-16' 00:00:00.0

--t_month
50fedf5088f14a669a855c9af8b567c3        2017-09-02 16:01:26.721 [{"platform": 0, "expireDate": "2018-03-15", "aliCouponSN": "da6d21784dd14236846616d9c27e87fa", "freeCardStartDate": "2017-09-02T16:01:26.721", "freeCardExpireDate": "2017-10-16", "noFreeCardStartDate": "2017-10-17 00:00:00", "noFreeCardExpireDate": "2018-03-15"}]


-- 用户2  双免

-- change record
2e932cb42ea64e2dabb4aa18521718f8        2017-12-16 20:35:02.358 '2018-07-13' 00:00:00.0 'max,未被记录在月卡里'
2e932cb42ea64e2dabb4aa18521718f8        2017-12-16 20:34:09.971 2018-01-14 00:00:00.0
2e932cb42ea64e2dabb4aa18521718f8        2017-12-06 20:38:04.645 2018-03-15 00:00:00.0
2e932cb42ea64e2dabb4aa18521718f8        2017-12-06 20:11:17.834 2018-03-05 00:00:00.0
2e932cb42ea64e2dabb4aa18521718f8        2017-12-06 19:44:56.469 2018-01-19 00:00:00.0


--t_month
2e932cb42ea64e2dabb4aa18521718f8        2017-12-06 19:44:56.469 [{"platform": 0, "expireDate": "2018-03-15", "aliCouponSN": "b2b60bfc9b9745bc87321b013f859db9", "freeCardStartDate": "2017-12-06T19:44:56.469", "freeCardExpireDate": "2018-03-05", "noFreeCardStartDate": "2018-03-06 00:00:00", "noFreeCardExpireDate": "2018-03-15"}]



--用户3 双免

 '?????????'
66309645c107430fbedf051c105bf7fc        2017-12-16 16:40:11.67  '2018-01-29' 00:00:00.0 '不存在于任何月卡记录中'
66309645c107430fbedf051c105bf7fc        2017-12-17 16:31:01.718 2018-06-14 00:00:00.0

66309645c107430fbedf051c105bf7fc        2017-12-16 16:40:11.67  [{"platform": 0, "expireDate": "2018-03-15", "aliCouponSN": "73a8f9e91f844eb0b971ca718eba3989", "freeCardStartDate": "2017-12-16T16:40:11.670", "freeCardExpireDate": "2018-03-15"}]
