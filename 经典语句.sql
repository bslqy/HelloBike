-- 写入服务器
set mapreduce.job.queuename=query_queue;
insert overwrite local directory '/home/deploy/liaojia/guzhang'
row format delimited fields terminated by "\t"

-- 本地文件上传之后建表
CREATE EXTERNAL TABLE t_kevin_10 (license_plate string,create_date string) 
ROW format delimited fields terminated BY '\t' Stored AS textfile;
load data local inpath '/home/deploy/liuhaochen/numcar10.txt' into table t_kevin_10;

-- presto
cd /
data1/apps/presto/presto-server-0.185/bin
data1/data_group/liaojia

presto --server localhost:8080 --catalog hive --schema default --execute "
select * from bike.t_ride_info limit 5;" --output-format CSV > /data1/data_group/liaojia/2017112310.csv  "


-- Cross Apply
select des,guid from t_refund_audit 
lateral view explode(split(substr(reason_info,2,length(reason_info)-2),", ")) tb1 as des
where reason_info<>''
limit 10;


