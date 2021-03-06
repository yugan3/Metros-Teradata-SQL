------------------------------------------------------------------闪购报告---------------------------------------------------
-------------------------------------------------
----------------------report---------------------
----------------------sales---------------------
chnccp_msi_z.ganyu_temp

select count(distinct store_no||auth_person_id||cust_no) as people from chnccp_msi_z.ganyu_temp where art_name in ('越南越飞来香脆鱼皮','安热沙小金瓶清爽防晒乳','蔚优Valio无乳糖全脂奶粉','花王妙而舒婴儿纸尿裤箱装','惠氏铂臻幼儿配方奶粉3段');
select count(distinct store_no||auth_person_id||cust_no) as people from chnccp_msi_z.ganyu_temp where art_name in ('贝克曼博士刷式衣领袖去渍剂250ml*2','金歌斯达特级初榨橄榄油250ML','皮龙酒庄多福红葡萄酒750ml');

select art_name, sum(qty*count) as sales, sum(count) as orders,  count(distinct store_no||auth_person_id||cust_no) as buyer from chnccp_msi_z.ganyu_temp 
where art_name in ('贝克曼博士刷式衣领袖去渍剂250ml*2','金歌斯达特级初榨橄榄油250ML','皮龙酒庄多福红葡萄酒750ml')
group by 1;
select art_name, sum(qty*price) as sales, sum(qty) as orders,  count(distinct store_no||auth_person_id||cust_no) as buyer from chnccp_msi_z.ganyu_temp 
where art_name in ('越南越飞来香脆鱼皮','安热沙小金瓶清爽防晒乳','蔚优Valio无乳糖全脂奶粉','花王妙而舒婴儿纸尿裤箱装','惠氏铂臻幼儿配方奶粉3段')
group by 1;


drop table chnccp_msi_z.ganyu_temp_namelist;
create table chnccp_msi_z.ganyu_temp_namelist
	as (select distinct store_no, auth_person_id, cust_no,
		CASE WHEN art_name in ('贝克曼博士刷式衣领袖去渍剂250ml*2','金歌斯达特级初榨橄榄油250ML','皮龙酒庄多福红葡萄酒750ml') THEN 'pick_up'
		     WHEN art_name in ('越南越飞来香脆鱼皮','安热沙小金瓶清爽防晒乳','蔚优Valio无乳糖全脂奶粉','花王妙而舒婴儿纸尿裤箱装','惠氏铂臻幼儿配方奶粉3段') THEN 'home_delivery' END AS delivery 
		from chnccp_msi_z.ganyu_temp where order_status = 1 and qty <>0 and art_name is not NULL ) with data;


select count(*) from chnccp_msi_z.ganyu_temp_namelist;

-------------------------------------------------------
---------------------life cycle------------------------
-------------------以4.28为活动日期----------------------
--new
drop table chnccp_msi_z.ganyu_temp_lifecycle_new;
create table chnccp_msi_z.ganyu_temp_lifecycle_new
	as(select a.delivery, a.store_no, a.cust_no, a.auth_person_id, 'new' as lifecycle
		from chnccp_msi_z.ganyu_temp_namelist a 
		join chnccp_dwh.dw_cust_invoice b 
		on a.store_no = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		group by a.delivery, a.store_no, a.cust_no, a.auth_person_id
		having min(b.date_of_day)>='2020-04-28'	)with data;

select delivery, lifecycle, count(distinct auth_person_id||store_no||cust_no) from chnccp_msi_z.ganyu_temp_lifecycle_new
group by delivery,lifecycle;

--activation and reactivation
drop table chnccp_msi_z.ganyu_temp_lifecycle_activation;
create table chnccp_msi_z.ganyu_temp_lifecycle_activation
	as(select t1.delivery, t1.store_no, t1.cust_no, t1.auth_person_id, 
		CASE WHEN max(b.date_of_day)between '2020-01-29' and '2020-04-27' THEN 'Regualr'
		     ELSE 'reactivation' END AS lifecycle
		from (select a.* from chnccp_msi_z.ganyu_temp_namelist a left join chnccp_msi_z.ganyu_temp_lifecycle_new b on b.auth_person_id = a.auth_person_id and b.cust_no = a.cust_no and b.store_no = a.store_no where b.cust_no is NULL) t1
		left join chnccp_dwh.dw_cust_invoice b 
		on t1.store_no = b.home_store_id and t1.cust_no = b.cust_no and t1.auth_person_id = b.auth_person_id
		where b.date_of_day <='2020-04-27'
		group by t1.delivery, t1.store_no, t1.cust_no, t1.auth_person_id
		)with data;

select delivery, lifecycle, count(distinct auth_person_id||store_no||cust_no) from chnccp_msi_z.ganyu_temp_lifecycle_activation
group by 1,2;
select lifecycle, count(distinct auth_person_id||store_no||cust_no) from chnccp_msi_z.ganyu_temp_lifecycle_activation
group by 1;
--total 
select count(distinct auth_person_id||store_no||cust_no) from chnccp_msi_z.ganyu_temp_lifecycle_new;
select lifecycle, count(distinct auth_person_id||store_no||cust_no) from chnccp_msi_z.ganyu_temp_lifecycle_activation
group by lifecycle;

--basket
select a.delivery, sum(b.sell_val_gsp)/count(a.auth_person_id||a.store_no||a.cust_no) as basket from chnccp_msi_z.ganyu_temp_namelist a 
join chnccp_dwh.dw_cust_invoice b 
on a.store_no = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
where b.date_of_day between '2019-10-29' and '2020-04-27'
group by a.delivery;

select sum(b.sell_val_gsp)/count(a.auth_person_id||a.store_no||a.cust_no) as basket from chnccp_msi_z.ganyu_temp_namelist a 
join chnccp_dwh.dw_cust_invoice b 
on a.store_no = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
where b.date_of_day between '2019-10-29' and '2020-04-27';

--------------------------------------------------------
-----------------------cust profile---------------------
-----------------------age and gender-------------------
drop table chnccp_msi_z.ganyu_temp_ageandgender;
create table chnccp_msi_z.ganyu_temp_ageandgender
	as( select a.store_no, a.auth_person_id, a.cust_no, a.delivery,
		CASE WHEN REGEXP_SIMILAR(left (right(b.identification_id,2),1), '[0-9]{1}','c')  = 1 then left (right(b.identification_id,2),1) 
		ELSE NULL end as gender,
		case when REGEXP_SIMILAR(right (left(b.identification_id,10),4), '[0-9]{4}','c')  = 1 then 2020-right (left(b.identification_id,10),4) 
		ELSE NULL end as age
		from chnccp_msi_z.ganyu_temp_namelist a 
		left join chnccp_dwh.dw_cust_auth_person b 
		on a.store_no = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id)with data;

--------------------------------------------------------
-----------null identification_id check-----------------
----------------------supplyment------------------------
drop table chnccp_msi_z.ganyu_temp_ageandgender_null;
create table chnccp_msi_z.ganyu_temp_ageandgender_null
	as(
select a.home_store_id, a.auth_person_id, a.cust_no, a.identification_id, e.cust_assort_section_id, d2.branch_id,
case    
    when e.cust_assort_section_id = 1 then '1) HoReCa'
    when e.cust_assort_section_id = 3 then '1) Trader'
    when e.cust_assort_section_id in (5,7) and d2.branch_id in (982) then '3) SCO - daypass'
    when e.cust_assort_section_id in (5,7) and d2.branch_id in (401,492,488,971,972) then '3) SCO - FoM'
    when e.cust_assort_section_id in (5,7) and d2.branch_id not in (401,492,493,488,971,972,973,982) then '3) SCO - w/o FoM'
    else '4) Undefined'
end as hts_info
 from (select * from chnccp_msi_z.ganyu_temp_ageandgender where (age is NULL or gender is null) ) b 
left join chnccp_dwh.dw_cust_auth_person a 
on a.home_store_id = b.store_no and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
left join chnccp_dwh.dw_customer d2
on a.cust_no = d2.cust_no and a.home_store_id = d2.home_store_id
left join chnccp_dwh.dw_cust_branch e 
on e.branch_id = d2.branch_id) with data;


drop table chnccp_msi_z.ganyu_temp_ageandgender_null_1;
create table chnccp_msi_z.ganyu_temp_ageandgender_null_1 as (
	select a.home_store_id, a.auth_person_id, a.cust_no, a.identification_id, a.branch_id, b.date_created, EXTRACT(year FROM b.date_created) as year1 from chnccp_msi_z.ganyu_temp_ageandgender_null a
	left join chnccp_dwh.dw_cust_auth_person b 
	on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id) with data;

select year1, count(year1) from chnccp_msi_z.ganyu_temp_ageandgender_null_1
group by year1
order by year1;

select hts_info, branch_id, count(*) from chnccp_msi_z.ganyu_temp_ageandgender_null
group by hts_info, branch_id
order by hts_info, branch_id;

------------------------------------------------------

------------------------------------------------------
--------------------------age-------------------------
drop table chnccp_msi_z.ganyu_temp_age;
create table chnccp_msi_z.ganyu_temp_age
	as( select delivery, auth_person_id, store_no, cust_no, 
		CASE WHEN age < 18 THEN '<18'
		     WHEN age between 18 and 24 THEN '18-24'
		     WHEN age between 25 and 29 THEN '25-29'
		     WHEN age between 30 and 39 THEN '30-39'
		     WHEN age between 40 and 49 THEN '40-49'
		     WHEN age >= 50 THEN '>=50'
		     ELSE NULL END AS age_group from chnccp_msi_z.ganyu_temp_ageandgender )with data;

select delivery, age_group, count(distinct auth_person_id||store_no||cust_no) from chnccp_msi_z.ganyu_temp_age
group by 1,2
order by 1,2;

select age_group,count(distinct auth_person_id||store_no||cust_no) as total from chnccp_msi_z.ganyu_temp_age
group by 1
order by 1;

select count(distinct auth_person_id||store_no||cust_no) from chnccp_msi_z.ganyu_temp_age where age_group is NULL;

select delivery, auth_person_id, store_no, cust_no,  age  from chnccp_msi_z.ganyu_temp_ageandgender where age is not null;

--median age：年龄选择中位数而不是平均数
--delivery
select delivery, avg(age) as avgage from chnccp_msi_z.ganyu_temp_ageandgender
where age between 0 and 100
group by delivery;
--total
select avg(age) as avgage from chnccp_msi_z.ganyu_temp_ageandgender
where age between 0 and 100;
--------

select avg
--------------------------gender-------------------------
drop table chnccp_msi_z.ganyu_temp_gender;
create table chnccp_msi_z.ganyu_temp_gender
	as( select delivery, auth_person_id, store_no, cust_no, 
		CASE WHEN gender in (0,2,4,6,8) THEN '女'
		     WHEN gender in (1,3,5,7,9) THEN '男'
		     ELSE '未知' END AS gender_group from chnccp_msi_z.ganyu_temp_ageandgender )with data;

select delivery, gender_group, count(distinct auth_person_id||store_no||cust_no) as buyer from chnccp_msi_z.ganyu_temp_gender
group by 1,2
order by 1,2;
select gender_group, count(distinct auth_person_id||store_no||cust_no) as buyer from chnccp_msi_z.ganyu_temp_gender
group by 1;
-----------------------UMC+------------------------------
select a.delivery, b.member_type, count(distinct a.auth_person_id||a.store_no||a.cust_no) as buyer from chnccp_msi_z.ganyu_temp_namelist a 
left join chnccp_msi_z.mem_ref_umc_tag_act b 
on a.auth_person_id = b.auth_person_id and a.store_no = b.home_store_id and a.cust_no = b.cust_no
group by 1,2;
select a.member_type,count(distinct a.auth_person_id||a.store_no||a.cust_no) as buyer from  chnccp_msi_z.ganyu_temp_namelist a 
left join chnccp_msi_z.mem_ref_umc_tag_act b
on a.auth_person_id = b.auth_person_id and a.store_no = b.home_store_id and a.cust_no = b.cust_no
group by 1;
------------------------fan------------------------------
select a.delivery, b.fan_ind, count(distinct a.auth_person_id||a.store_no||a.cust_no) as buyer from chnccp_msi_z.ganyu_temp_namelist a 
left join chnccp_msi_z.mem_ref_umc_tag_act b 
on a.auth_person_id = b.auth_person_id and a.store_no = b.home_store_id and a.cust_no = b.cust_no
group by 1,2;
select b.fan_ind,count(distinct a.auth_person_id||a.store_no||a.cust_no) as buyer from  chnccp_msi_z.ganyu_temp_namelist a 
left join chnccp_msi_z.mem_ref_umc_tag_act b
on a.auth_person_id = b.auth_person_id and a.store_no = b.home_store_id and a.cust_no = b.cust_no
group by 1;

-----------------------------------------------------------
------------------------liveshow---------------------------
--直播的名单
chnccp_msi_z.liveshow_newuser 
storekey
custkey
cardholderkey
--订单明细
chnccp_msi_z.ganyu_temp
dt
campaign_type
channel
store_no
cust_no
auth_person_id
order_type
art_name
qty
price
channel_name
channel_category
order_status
liveshow

drop table chnccp_msi_z.liveshow_newuser_watched; --5390
create table chnccp_msi_z.liveshow_newuser_watched
	as(select a.storekey as home_store_id, a.custkey as cust_no, a.cardholderkey as auth_person_id from (select distinct storekey, custkey, cardholderkey from chnccp_msi_z.liveshow_newuser where storekey <> 0) a 
		join (select distinct store_no, cust_no, auth_person_id from chnccp_msi_z.ganyu_temp) b 
		on a.storekey = b.store_no and a.custkey = b.cust_no and a.cardholderkey = b.auth_person_id
		)with data;

drop table chnccp_msi_z.liveshow_newuser_watched_not; --138944
create table chnccp_msi_z.liveshow_newuser_watched_not 
	as(select distinct b.store_no, b.cust_no, b.auth_person_id from (select distinct store_no, cust_no, auth_person_id from chnccp_msi_z.ganyu_temp) b
		left join chnccp_msi_z.liveshow_newuser_watched a
		on a.home_store_id = b.store_no and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		where a.cust_no is NULL) with data;


drop table chnccp_msi_z.liveshow_newuser_watched_UMCfan;
create table chnccp_msi_z.liveshow_newuser_watched_UMCfan
	as(select a.*, 
		CASE WHEN b.member_type IS NOT NULL THEN b.member_type
		     ELSE 'other' END AS member_type, 
		CASE WHEN b.fan_ind IS NOT NULL THEN b.fan_ind
		     ELSE 'N' END AS fan_ind from chnccp_msi_z.liveshow_newuser_watched a 
		left join chnccp_msi_z.mem_ref_umc_tag_act b
		on a.store_no = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		)with data;

select fan_ind, member_type, count(*) as people from chnccp_msi_z.liveshow_newuser_watched_UMCfan
group by fan_ind, member_type;

drop table chnccp_msi_z.liveshow_newuser_watched_UMCfan_basket;
create table chnccp_msi_z.liveshow_newuser_watched_UMCfan_basket
	as( select a.member_type, a.fan_ind, a.home_store_id, a.cust_no, a.auth_person_id, sum(b.sell_val_gsp)as sales, count (distinct b.date_of_day) as visits from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b
        join chnccp_msi_z.liveshow_newuser_watched_UMCfan a 
        on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
        where b.date_of_day between '2019-04-29' and '2020-04-28'
        group by a.member_type, a.fan_ind, a.home_store_id, a.cust_no, a.auth_person_id)with data;

select member_type, fan_ind, sum(sales)/sum(visits) as basket, avg(visits) as frequency from chnccp_msi_z.liveshow_newuser_watched_UMCfan_basket
group by member_type, fan_ind;

--basket for 2 groups of liveshow and non for comparison
drop table chnccp_msi_z.liveshow_newuser_watched_not_UMCfan;
create table chnccp_msi_z.liveshow_newuser_watched_not_UMCfan
	as(select a.*, 
		CASE WHEN b.member_type IS NOT NULL THEN b.member_type
		     ELSE 'other' END AS member_type, 
		CASE WHEN b.fan_ind IS NOT NULL THEN b.fan_ind
		     ELSE 'N' END AS fan_ind from chnccp_msi_z.liveshow_newuser_watched_not a 
		left join chnccp_msi_z.mem_ref_umc_tag_act b
		on a.store_no = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		)with data;

select fan_ind, member_type, count(*) as people from chnccp_msi_z.liveshow_newuser_watched_not_UMCfan
group by fan_ind, member_type;

drop table chnccp_msi_z.liveshow_newuser_watched_not_UMCfan_basket;
create table chnccp_msi_z.liveshow_newuser_watched_not_UMCfan_basket
	as( select a.member_type, a.fan_ind, a.store_no, a.cust_no, a.auth_person_id, sum(b.sell_val_gsp)as sales, count (distinct b.date_of_day) as visits from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b
        join chnccp_msi_z.liveshow_newuser_watched_not_UMCfan a 
        on a.store_no = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
        where b.date_of_day between '2019-04-29' and '2020-04-28'
        group by a.member_type, a.fan_ind, a.store_no, a.cust_no, a.auth_person_id)with data;

select member_type, fan_ind, sum(sales)/sum(visits) as basket, avg(visits) as frequency from chnccp_msi_z.liveshow_newuser_watched_not_UMCfan_basket
group by member_type, fan_ind;
