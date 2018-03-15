-- 18 位
round(months_between('2017-12-24',concat(substr(personal_id,7,4),'-',substr(personal_id,11,2),'-',substr(personal_id,13,2)))/12,0)

round(date_diff('month',date(concat('19',substr(t.personal_id,7,4),'-',substr(t.personal_id,11,2),'-',substr(t.personal_id,13,2))),current_date)/12)


-- 15位
round(months_between('2017-12-24',concat('19',substr(t.personal_id,7,2),'-',substr(t.personal_id,9,2),'-',substr(t.personal_id,11,2)))/12,0)

round(date_diff('month',date(concat('19',substr(t.personal_id,7,2),'-',substr(t.personal_id,9,2),'-',substr(t.personal_id,11,2))),current_date)/12)
