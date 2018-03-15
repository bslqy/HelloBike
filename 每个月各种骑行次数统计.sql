set mapreduce.job.queuename=query_queue;
insert overwrite local directory '/home/deploy/liaojia/guzhang'
select haha.frequency, count(haha.user_guid) from 
(select user_guid, count(user_guid) frequency from bike.t_tmp_ride 
where account_type <> -1 
and account_type <> 3
and ride_status in (1,2)
and substr(create_time,1,10) >= '2017-10-01'
and substr(create_time,1,10) < '2017-11-01'
group by user_guid) haha
group by haha.frequency
