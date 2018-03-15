"非唯一但是很接近"
select count(operation_batch_id), count(distinct operation_batch_id) from  t_operation_batch;
select substr(create_date,1,10),operation_batch_id,guid from t_operation_batch where license_plate ='陕EB1898';
aa25f17186794beeb06a896fa3a406b2
select distinct(city_guid) from t_operation_bike_status where operation_guid
 in('aa25f17186794beeb06a896fa3a406b2','6a3220f0a5694f1eaa72e20c8ba96efe');


CREATE EXTERNAL TABLE t_NOVPAD (deliver_date string,plate string)
ROW format delimited fields terminated BY '\t' Stored AS textfile;

load data local inpath '/home/deploy/liaojia/Logistic/NovemberPlateAndDate.txt' into table t_NOVPAD;



select create_date,operation_batch_id,factory_name from t_operation_batch
where create_date >='2017-11-15' and create_date <'2017-11-16'
and license_plate = '苏AN6768'
group by operation_batch_id,create_date,factory_name


select create_date,guid from t_operation_batch
where license_plate = '苏AC7890'
and create_date >='2017-11-10' and create_date <'2017-11-12'
group by guid,create_date

select operation_time from t_operation_bike_status where operation_guid 
in ('069868fbfd0c4ea787ab0e2b8b34caa8') limit 10;




----- 有记录的
presto --server localhost:8080 --catalog hive --schema default --execute "
select batch.create_date,batch.factory_name,status.operation_bike_no QRCode,batch.license_plate plate,batch.operation_batch_id picihao
from bike.t_NOVPAD Nov left join 
(select guid,license_plate,substr(create_date,1,10) create_date, operation_batch_id,factory_name from bike.t_operation_batch 
where create_date > '2017-11-01 00:00:00'
and create_date < '2017-12-01 00:00:00'
group by guid,operation_batch_id, license_plate,substr(create_date,1,10),factory_name) batch

on Nov.plate = batch.license_plate 
and Nov.deliver_date = batch.create_date

left join 
(select operation_guid,operation_bike_no,substr(operation_time,1,10) from bike.t_operation_bike_status
where operation_time > '2017-11-01 00:00:00'
and operation_time < '2017-12-01 00:00:00'
and operation_status = 1
group by operation_guid,operation_bike_no,substr(operation_time,1,10) ) status 
on batch.guid = status.operation_guid

where batch.guid is not null and status.operation_guid is not null

" --output-format CSV > /data1/data_group/liaojia/logistic/20171227_Dec_Logistic.csv  


--------------------- 查找哪个批次不在batch库里

presto --server localhost:8080 --catalog hive --schema default --execute "

select Nov.deliver_date,Nov.plate
from bike.t_NOVPAD Nov
left join 
(select guid,license_plate,substr(create_date,1,10) create_date,substr(create_date,1,16) create_hour,operation_batch_id from bike.t_operation_batch 
where create_date > '2017-10-01 00:00:00'
and create_date < '2017-11-01 00:00:00'
group by guid,operation_batch_id, license_plate,substr(create_date,1,10), substr(create_date,1,16)) batch

on Nov.plate = batch.license_plate and Nov.deliver_date = batch.create_date
where batch.guid is null " --output-format CSV > /data1/data_group/liaojia/logistic/20171227_Oct_NotInBatch.csv


--------------------- 查找哪个批次 在batch库里但不在status里

presto --server localhost:8080 --catalog hive --schema default --execute "

select Nov.deliver_date,Nov.plate,batch.create_hour,batch.operation_batch_id,batch.guid
from bike.t_NOVPAD Nov
left join 
(select guid,license_plate,substr(create_date,1,10) create_date, factory_name,substr(create_date,1,16) create_hour,operation_batch_id from bike.t_operation_batch 
where create_date > '2017-10-01 00:00:00'
and create_date < '2017-11-01 00:00:00'
group by guid,operation_batch_id, license_plate,substr(create_date,1,10), substr(create_date,1,16), factory_name) batch

on Nov.plate = batch.license_plate and Nov.deliver_date = batch.create_date

left join 
(select operation_guid,operation_bike_no,substr(operation_time,1,10) from bike.t_operation_bike_status
where operation_time > '2017-10-01 00:00:00'
and operation_time < '2017-11-01 00:00:00'
and operation_status = 1
group by operation_guid,operation_bike_no,substr(operation_time,1,10) ) status 

on batch.guid = status.operation_guid
where batch.guid is not null and status.operation_guid is null 


" --output-format CSV > /data1/data_group/liaojia/logistic/20171227_Oct_InBatchButNotStatus.csv


	