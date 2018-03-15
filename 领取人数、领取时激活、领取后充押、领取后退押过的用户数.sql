--以下4个骑行卡截至	
select
case when card_record.channel_guid =  "449ea8b810d641b893d9ccb69fd80dc0" then "card_1"
when card_record.channel_guid =  "df757c7a7a27447a9ac51399967ec69c" then "card_2"
when card_record.channel_guid =  "156127762cf44be2818403bbee56316c" then "card_3"
when card_record.channel_guid =  "e322d453ac5d45589e18b77172a1e2fd" then "card_4" end card_type,
count(user_guid) got_card,
count(lingqushijihuo.guid) was_activated_before_got_card,
count(lingkahouchongya.lkguid) charge_after_getting_card,
count(xianzaituiya.guid) was_activated_but_exited
from t_user_ride_card_change_record card_record
left join
-- -- 12/12 日当天激活了的人

(Select b.user_guid guid
from
(select user_guid
,max(create_date) date1
from t_charge_info
where create_date<'2017-12-12 00:00:00'
and charge_type=0
and charge_status=1
group by user_guid) b

left join 
(select user_guid,max(create_date) date2 
from t_charge_info
where create_date<'2017-12-12 00:00:00'
and charge_type=2
and charge_status=-2
group by user_guid) t1
on b.user_guid=t1.user_guid

-- 充押晚于退押 或者 没退押 （取最新状态）
where b.date1>t1.date2 or t1.date2 is null or t1.date2='') lingqushijihuo

on card_record.user_guid = lingqushijihuo.guid

-- 现在为退押的人
left join 
(select guid 
from t_bike_user b
where b.account_status = -2
and b.account_type<>-1
and b.account_type<>3
and b.deposit<>0.01
)xianzaituiya

on xianzaituiya.guid = lingqushijihuo.guid

-- 整合为领取时是激活的 -> 现在不是激活的
left join
(select user_guid lkguid,max(create_date)
from t_charge_info 
where create_date>'2017-11-23 10:22:59.476' --min date
and create_date<'2017-12-12 00:00:00'
and charge_type=0
and charge_status=1
group by user_guid) lingkahouchongya

on lingkahouchongya.lkguid = card_record.user_guid

where card_record.channel_guid IN
("449ea8b810d641b893d9ccb69fd80dc0",
"df757c7a7a27447a9ac51399967ec69c",
"156127762cf44be2818403bbee56316c",
"e322d453ac5d45589e18b77172a1e2fd")
and create_date<'2017-12-12 00:00:00'
group by 
case when card_record.channel_guid =  "449ea8b810d641b893d9ccb69fd80dc0" then "card_1"
when card_record.channel_guid =  "df757c7a7a27447a9ac51399967ec69c" then "card_2"
when card_record.channel_guid =  "156127762cf44be2818403bbee56316c" then "card_3"
when card_record.channel_guid =  "e322d453ac5d45589e18b77172a1e2fd" then "card_4" end;


-- min date
select min(create_date),count(create_date) 
from t_user_ride_card_change_record t 
where t.channel_guid IN
("449ea8b810d641b893d9ccb69fd80dc0",
"df757c7a7a27447a9ac51399967ec69c",
"156127762cf44be2818403bbee56316c",
"e322d453ac5d45589e18b77172a1e2fd")




select count (*) 
from t_user_ride_card_change_record t 
where t.channel_guid IN
("449ea8b810d641b893d9ccb69fd80dc0",
"df757c7a7a27447a9ac51399967ec69c",
"156127762cf44be2818403bbee56316c",
"e322d453ac5d45589e18b77172a1e2fd")





