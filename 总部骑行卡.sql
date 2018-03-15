"从开卡之日起截止到12.17日，PV,UV,领卡人数，领卡时已激活人数，交押金人数，谢谢~"

select Min(create_date) from t_user_ride_card_change_record 
where channel_guid in
('faa0a3b640e546fa8d9a33c39d975232',
'd45575b06d1a40daaf3822c88c70700c',
'f49e730f0b6746b3a2b01a911069f587',
'7a9d9bea1dad4bff8daf598f5d5e63e8',
'8cda6377d28c48e2b2fa36b7df012a01',
'e45e4233a0824881a8f7dae7e8ec3e6a',
'3a28de7bca494536b156039dbcb90b0e',
'09f6c4809c4e44c9b522bdc77590f5e9',
'f8a21b585b884dc598d06e544255c648',
'0521f4d8718340849222a969c562ccbb',
'18a03a55f2ba4349b2b6a5d6187336da',
'df757c7a7a27447a9ac51399967ec69c');

-- 2017-09-19 17:18:41.516

'data1/apps/presto/presto-server-0.185/bin'
'data1/data_group/liaojia'
presto --server localhost:8080 --catalog hive --schema default --execute "

select
case when card_record.channel_guid ='faa0a3b640e546fa8d9a33c39d975232'then 'card_1'
when card_record.channel_guid ='d45575b06d1a40daaf3822c88c70700c'then 'card_02'
when card_record.channel_guid ='f49e730f0b6746b3a2b01a911069f587'then 'card_03'
when card_record.channel_guid ='7a9d9bea1dad4bff8daf598f5d5e63e8'then 'card_04'
when card_record.channel_guid ='8cda6377d28c48e2b2fa36b7df012a01'then 'card_05'
when card_record.channel_guid ='e45e4233a0824881a8f7dae7e8ec3e6a'then 'card_06'
when card_record.channel_guid ='3a28de7bca494536b156039dbcb90b0e'then 'card_07'
when card_record.channel_guid ='09f6c4809c4e44c9b522bdc77590f5e9'then 'card_08'
when card_record.channel_guid ='f8a21b585b884dc598d06e544255c648'then 'card_09'
when card_record.channel_guid ='0521f4d8718340849222a969c562ccbb'then 'card_10'
when card_record.channel_guid ='18a03a55f2ba4349b2b6a5d6187336da'then 'card_11'
when card_record.channel_guid ='df757c7a7a27447a9ac51399967ec69c'then 'card_12'
end card_type,
count(distinct user_guid) got_card,
count(distinct lingqushijihuo.guid) was_activated_before_got_card,
count(distinct lingkahouchongya.lkguid) charge_after_getting_card

from bike.t_user_ride_card_change_record card_record
left join
-- -- 11/31 前取卡当天激活了的人

(Select b.user_guid guid
from
(select user_guid
,max(create_date) date1
from bike.t_charge_info
where create_date<'2017-09-19 17:18:41.516'
and charge_type=0
and charge_status=1
group by user_guid) b

left join 
(select user_guid,max(create_date) date2 
from bike.t_charge_info
where create_date<'2017-09-19 17:18:41.516'
and charge_type=2
and charge_status=-2
group by user_guid) t1

on b.user_guid=t1.user_guid
-- 充押晚于退押 或者 没退押 （取最新状态）
where b.date1>t1.date2 or t1.date2 is null or t1.date2='') lingqushijihuo

on card_record.user_guid = lingqushijihuo.guid

left join
(select user_guid lkguid,min(create_date)
from bike.t_charge_info 
where create_date>='2017-09-19 17:18:41.516' 
and create_date<'2017-12-18 00:00:00'
and charge_type=0
and charge_status=1
group by user_guid) lingkahouchongya
on lingkahouchongya.lkguid = card_record.user_guid

where card_record.channel_guid IN
('faa0a3b640e546fa8d9a33c39d975232',		
'd45575b06d1a40daaf3822c88c70700c',		
'f49e730f0b6746b3a2b01a911069f587',		
'7a9d9bea1dad4bff8daf598f5d5e63e8',		
'8cda6377d28c48e2b2fa36b7df012a01',		
'e45e4233a0824881a8f7dae7e8ec3e6a',		
'3a28de7bca494536b156039dbcb90b0e',		
'09f6c4809c4e44c9b522bdc77590f5e9',		
'f8a21b585b884dc598d06e544255c648',		
'0521f4d8718340849222a969c562ccbb',		
'18a03a55f2ba4349b2b6a5d6187336da',		
'df757c7a7a27447a9ac51399967ec69c')

and create_date>='2017-09-19 17:18:41.516'
and create_date<'2017-12-18 00:00:00' 
group by 
case when card_record.channel_guid ='faa0a3b640e546fa8d9a33c39d975232'then 'card_01'
when card_record.channel_guid ='d45575b06d1a40daaf3822c88c70700c'then 'card_02'
when card_record.channel_guid ='f49e730f0b6746b3a2b01a911069f587'then 'card_03'
when card_record.channel_guid ='7a9d9bea1dad4bff8daf598f5d5e63e8'then 'card_04'
when card_record.channel_guid ='8cda6377d28c48e2b2fa36b7df012a01'then 'card_05'
when card_record.channel_guid ='e45e4233a0824881a8f7dae7e8ec3e6a'then 'card_06'
when card_record.channel_guid ='3a28de7bca494536b156039dbcb90b0e'then 'card_07'
when card_record.channel_guid ='09f6c4809c4e44c9b522bdc77590f5e9'then 'card_08'
when card_record.channel_guid ='f8a21b585b884dc598d06e544255c648'then 'card_09'
when card_record.channel_guid ='0521f4d8718340849222a969c562ccbb'then 'card_10'
when card_record.channel_guid ='18a03a55f2ba4349b2b6a5d6187336da'then 'card_11'
when card_record.channel_guid ='df757c7a7a27447a9ac51399967ec69c'then 'card_12'
end;" --output-format CSV > /data1/data_group/liaojia/20171219_HeadQuater.csv