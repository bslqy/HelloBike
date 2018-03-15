-- 分开所有故障类型，并添加}到最后为json，在用get_json_object
set mapreduce.job.queuename=query_queue;
insert overwrite local directory '/home/deploy/liaojia/guzhang'
row format delimited fields terminated by "\t"

select info.bike_no,info.manage_status,b.assembly_plant_name,b.city_name,info.json,
substr(b.online_time,1,10) chuchangriqi,info.date1 guzhangriqi,
datediff(info.date1,b.online_time) 
from
(select concat(a.des,'}') json ,bike_no, date1,manage_status from 
(select des,bike_no,manage_status,substr(create_date,1,10) date1 from t_bike_manage_info 
lateral view explode(split(substr(bos_maintain_fault,2,length(bos_maintain_fault)-2),", ")) tb1 as des
where bos_maintain_fault<>'' and length(bos_maintain_fault)<> 0) a
where a.des like '{%'
) info

left join 
(select bike_no,assembly_plant_name,online_time,city_name from t_bike_info
where online_time >= '2017-11-01 00:00:00' and online_time < '2017-12-01 00:00:00') b
on info.bike_no = b.bike_no 
where b.bike_no is not null
group by info.bike_no,b.assembly_plant_name,b.city_name,info.json,
substr(b.online_time,1,10) ,info.date1,info.manage_status,
datediff(info.date1,b.online_time) 


-- 分开所有故障类型，并添加}到最后为json，在用get_json_object(不行，返回NULL)


select concat(a.des,'}'),bike_no from 
(select des,bike_no from t_bike_manage_info 
lateral view explode(split(substr(bos_maintain_fault,2,length(bos_maintain_fault)-2),", ")) tb1 as des
where bos_maintain_fault<>'' and length(bos_maintain_fault)<> 0 limit 20) a
where a.des like '{%';

presto --server localhost:8080 --catalog hive --schema default --execute "

set mapreduce.job.queuename=query_queue;
insert overwrite local directory '/home/deploy/liaojia/guzhang'
select count(bike_no),assembly_plant_name,city_name from bike.t_bike_info
where online_time >= '2017-11-01 00:00:00' and online_time < '2017-12-01 00:00:00'
group by  assembly_plant_name,city_name 


