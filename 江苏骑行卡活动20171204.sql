----------- (江苏） 从开卡之日起，截止到12月03日23：59的领卡人数，已激活人数，交押金人数 ---------------------

-- 要点，激活的话一定要有充押金，并且最后一个冲压动作要在退押之后
-- 各个 user_uid 必须 groupBY

Insert overwrite local directory '/home/deploy/liaojia/20171204_jiangsu'
row format delimited fields terminated by "\t" 
select t3.guid1--渠道
,t3.jishu1--领卡人数
,t4.jishu2--领卡后充押金人数
,t5.jishu3--已激活人数
from

-- 所有渠道 ， 12/1 前通过指定渠道拿卡的人第一次拿卡的日期，12/1 前各渠道 通过指定渠道 拿卡人的数量
(select
channel_guid guid1
,min(create_date)
,count(user_guid) jishu1
from t_user_ride_card_change_record
where channel_guid IN
("df1c66edac65471d8e77f5d995d3157c,"
"336192f71ea94b359ff7ef2abcaad928,"
"43fcc16d9b4f41c78d9e91f9b05b19d6,"
"429c98f2c20a4b55ac46b466f035e425,"
"11fd3ba78e344331bfd12485acd8d978,"
"2f1e3d53fa8f42799ca9fc1021e6e7ae,"
"f349cf54baed498a8c94155c821febdd,"
"86f5d5d233014fa99e9668d6d0c65642")
and create_date<'2017-12-04 00:00:00'
group by channel_guid) t3

left join

-- 渠道， 指定渠道拿卡的人 aka t4
(select
a.channel_guid guid2
,count(distinct(a.user_guid)) jishu2 from 

--12/1 前通过指定渠道拿卡的用户id，12/1 前通过指定渠道拿卡的用户数量
(select
user_guid,channel_guid,create_date
from t_user_ride_card_change_record 
where channel_guid IN
("df1c66edac65471d8e77f5d995d3157c,"
"336192f71ea94b359ff7ef2abcaad928,"
"43fcc16d9b4f41c78d9e91f9b05b19d6,"
"429c98f2c20a4b55ac46b466f035e425,"
"11fd3ba78e344331bfd12485acd8d978,"
"2f1e3d53fa8f42799ca9fc1021e6e7ae,"
"f349cf54baed498a8c94155c821febdd,"
"86f5d5d233014fa99e9668d6d0c65642")
and create_date<'2017-12-04 00:00:00') a

inner join -- 12／1 日前所有有卡，并且有充值

-- 12/1 日前充过押金的人， 12/1 前充过押金的人最晚的日期
(select 
user_guid
,max(create_date) date1
from t_charge_info
where create_date<'2017-12-04 00:00:00'
and charge_type=0
and charge_status=1
group by user_guid) b

on a.user_guid=b.user_guid

-- 充值比拿卡晚 （拿卡之后充值了）
where a.create_date<b.date1
group by a.channel_guid) t4

on t3.guid1=t4.guid2

left join

-- 12/1 前有卡的用户id，12/1 前有卡的用户数量，要和join 激活  aka t5
(select
a.channel_guid guid3
,count(distinct(a.user_guid)) jishu3
from 
	-- 指定渠道的用户 	aka a  		<=>				t2(激活的人)
	-- 												|	
	--						b (最新充押) <=> t1 （最新退押） where： b.date > t1.date						
(select
user_guid,channel_guid,create_date
from t_user_ride_card_change_record 
where channel_guid 
IN("df1c66edac65471d8e77f5d995d3157c,"
"336192f71ea94b359ff7ef2abcaad928,"
"43fcc16d9b4f41c78d9e91f9b05b19d6,"
"429c98f2c20a4b55ac46b466f035e425,"
"11fd3ba78e344331bfd12485acd8d978,"
"2f1e3d53fa8f42799ca9fc1021e6e7ae,"
"f349cf54baed498a8c94155c821febdd,"
"86f5d5d233014fa99e9668d6d0c65642")
and create_date<'2017-12-04 00:00:00') a

inner join -- 12／1 日前激活的人，并且有充值 aka t2


(select b.user_guid guid1
,b.date1 date3

from

-- 12/1 日前充押金的人， 12/1 前充押金的人最晚的日期 aka t1
(select user_guid
,max(create_date) date1
from t_charge_info
where create_date<'2017-12-04 00:00:00'
and charge_type=0
and charge_status=1
group by user_guid) b

left join 
-- 12/1 日前退押金的人 12/1 前每个人退押金最晚的时间
(select user_guid
,max(create_date) date2
from t_charge_info
where create_date<'2017-12-04 00:00:00'
and charge_type=2
and charge_status=-2
group by user_guid) t1
on b.user_guid=t1.user_guid
-- 充押晚于退押 或者 没退押 

where b.date1>t1.date2 or t1.date2 is null or t1.date2='') t2

on a.user_guid=t2.guid1

where a.create_date>t2.date3
group by a.channel_guid) t5

on t3.guid1=t5.guid3;