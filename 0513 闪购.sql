--data check from postgreSQL
drop table falshsales0513;
create table falshsales0513
	as(select created_at, store_key, cust_key, ch_key, count as counts, price, goods_name, order_status, campaign from metro_order.release_order_orders 
		where campaign = '会员闪购' and created_at between '2020-05-11' and '2020-05-15');

--teradata temp table 
drop table chnccp_msi_z.falshsales0513;
create table chnccp_msi_z.falshsales0513
	(created_at date, 
	store_key INTEGER, 
	cust_key INTEGER, 
	ch_key INTEGER, 
	counts INTEGER,
	price float(48),
	goods_name VARCHAR(48),
	order_status INTEGER,
	campaign VARCHAR(48)
		);

-----------------------------------------------------------------------0513闪购----------------------------------------------------------------
--闪购3张表
--first_channel_userinfo
--metro_order.release_order_orders
--liveshow_userinfo_all
---------------------------首次进入渠道-------------------------
/*drop table first_channel_userinfo_0513;
create table first_channel_userinfo_0513
	as(select * from first_channel_userinfo where campaign_type = '5.13');
字段：
fromat
channel
storekey
custkey
cardholderkey
unionid
campaign_type*/

---------------------------直播用户名单-------------------------
/*drop table liveshow_userinfo_all_0513;
create table liveshow_userinfo_all_0513
	as(select * from liveshow_userinfo_all where campaign_type = '5.13');
字段：
storekey
custkey
cardholderkey
unionid
campaign_type*/


------------------------------------------------------------------0513report-------------------------------------------------------------------
------------------------------------------
---------------------1--------------------
--mikg_art_no
select art_name, art_name_tl, mikg_art_no from chnccp_dwh.dw_art_var_tu
where mikg_art_no in (225289, 232399, 118457, 225558, 209535,231680,233084,233012);
--

select count(distinct home_store_id||cust_no||auth_person_id) as buyer, count(distinct home_store_id||cust_no||auth_person_id) as orders, sum(qty) as qty, sum(qty* price) as sales from chnccp_crm.evolve_flash_sale 
where qty <> 0 and order_status = 1;

select deliver_type, count(distinct home_store_id||cust_no||auth_person_id) as buyer, count(distinct home_store_id||cust_no||auth_person_id) as orders, sum(qty) as qty, sum(qty* price) as sales from chnccp_crm.evolve_flash_sale 
where qty <> 0 and order_status = 1
group by deliver_type;

-------------------------------------------
--------------------2----------------------
--take the example of one group of products
select count(distinct store_key||cust_key||ch_key) as buyer, count(store_key||cust_key||ch_key) as orders, sum(counts) as qty, sum(counts* price) as sales from chnccp_msi_z.falshsales0513
where counts<> 0 and order_status = 1 and goods_name in('确美同水宝宝纯净防晒乳237ml','美旅22寸万向轮哑光银拉杆箱','小米休闲运动双肩包');

--uv
select count(distinct cust_no||home_store_id||auth_person_id) from chnccp_crm.evolve_flash_sale ;
--buyer
select count(distinct cust_no||home_store_id||auth_person_id) from chnccp_crm.evolve_flash_sale where order_status = 1 and qty <> 0;

------------------------------------------
--------------------3---------------------
drop table chnccp_msi_z.profile_0513;
create table chnccp_msi_z.profile_0513
	as(select auth_person_id, home_store_id, cust_no, deliver_type from chnccp_crm.evolve_flash_sale
		where qty <>0 and order_status = 1
		group by auth_person_id, home_store_id, cust_no, deliver_type
		)with data;

------------------------------------------
--age and gender
--missing data here is marked as unknown
drop table chnccp_msi_z.ganyu_temp_ageandgender;
create table chnccp_msi_z.ganyu_temp_ageandgender
	as( select a.home_store_id, a.auth_person_id, a.cust_no, a.deliver_type,
		CASE WHEN REGEXP_SIMILAR(left (right(b.identification_id,2),1), '[0-9]{1}','c')  = 1 then left (right(b.identification_id,2),1) 
		ELSE NULL end as gender,
		case when REGEXP_SIMILAR(right (left(b.identification_id,10),4), '[0-9]{4}','c')  = 1 then 2020-right (left(b.identification_id,10),4) 
		ELSE NULL end as age
		from chnccp_msi_z.profile_0513 a 
		left join chnccp_dwh.dw_cust_auth_person b 
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id)with data;

------------------------------------------
--age 
--missing data here is marked as unknown
drop table chnccp_msi_z.ganyu_temp_age;
create table chnccp_msi_z.ganyu_temp_age
	as( select deliver_type, home_store_id, auth_person_id, cust_no,
		CASE WHEN age < 18 THEN '<18'
		     WHEN age between 18 and 24 THEN '18-24'
		     WHEN age between 25 and 29 THEN '25-29'
		     WHEN age between 30 and 39 THEN '30-39'
		     WHEN age between 40 and 49 THEN '40-49'
		     WHEN age >= 50 THEN '>=50'
		     ELSE NULL END AS age_group from chnccp_msi_z.ganyu_temp_ageandgender )with data;

select deliver_type, age_group, count(distinct home_store_id||auth_person_id||cust_no) from chnccp_msi_z.ganyu_temp_age
group by 1,2
order by 1,2;

select age_group,count(distinct home_store_id||auth_person_id||cust_no) as total from chnccp_msi_z.ganyu_temp_age
group by 1
order by 1;

-----------------------------------------
--gender
drop table chnccp_msi_z.ganyu_temp_gender;
create table chnccp_msi_z.ganyu_temp_gender
	as( select deliver_type, home_store_id, auth_person_id, cust_no,
		CASE WHEN gender in (0,2,4,6,8) THEN '女'
		     WHEN gender in (1,3,5,7,9) THEN '男'
		     ELSE '未知' END AS gender_group from chnccp_msi_z.ganyu_temp_ageandgender )with data;

select deliver_type, gender_group, count(distinct home_store_id||auth_person_id||cust_no) as buyer from chnccp_msi_z.ganyu_temp_gender
group by 1,2
order by 1,2;
select gender_group, count(distinct home_store_id||auth_person_id||cust_no) as buyer from chnccp_msi_z.ganyu_temp_gender
group by 1;

----------------------------------------
--UMC+
select a.deliver_type, b.member_type, count(distinct a.auth_person_id||a.home_store_id||a.cust_no) as buyer from chnccp_msi_z.profile_0513 a 
left join chnccp_msi_z.mem_ref_umc_tag_act b 
on a.auth_person_id = b.auth_person_id and a.home_store_id = b.home_store_id and a.cust_no = b.cust_no
group by 1,2
order by 1,2;
select b.member_type, count(distinct a.auth_person_id||a.home_store_id||a.cust_no) as buyer from chnccp_msi_z.profile_0513 a 
left join chnccp_msi_z.mem_ref_umc_tag_act b
on a.auth_person_id = b.auth_person_id and a.home_store_id = b.home_store_id and a.cust_no = b.cust_no
group by 1;

-----------------------------------------
--fan
select a.deliver_type, b.fan_ind, count(distinct a.auth_person_id||a.home_store_id||a.cust_no) as buyer from chnccp_msi_z.profile_0513 a 
left join chnccp_msi_z.mem_ref_umc_tag_act b 
on a.auth_person_id = b.auth_person_id and a.home_store_id = b.home_store_id and a.cust_no = b.cust_no
group by 1,2
order by 1,2;
select b.fan_ind,count(distinct a.auth_person_id||a.home_store_id||a.cust_no) as buyer from chnccp_msi_z.profile_0513 a 
left join chnccp_msi_z.mem_ref_umc_tag_act b
on a.auth_person_id = b.auth_person_id and a.home_store_id = b.home_store_id and a.cust_no = b.cust_no
group by 1;

-----------------------------------------
--lifecycle
--以5.12为活动日期--
--new
drop table chnccp_msi_z.ganyu_temp_lifecycle_new;
create table chnccp_msi_z.ganyu_temp_lifecycle_new
	as(select a.deliver_type, a.home_store_id , a.cust_no, a.auth_person_id, 'new' as lifecycle
		from chnccp_msi_z.profile_0513 a 
		join chnccp_dwh.dw_cust_invoice b 
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		group by a.deliver_type, a.home_store_id , a.cust_no, a.auth_person_id
		having min(b.date_of_day)>='2020-05-12'	)with data;

select deliver_type, lifecycle, count(distinct auth_person_id||home_store_id||cust_no) from chnccp_msi_z.ganyu_temp_lifecycle_new
group by deliver_type,lifecycle;

--activation and reactivation
drop table chnccp_msi_z.ganyu_temp_lifecycle_activation;
create table chnccp_msi_z.ganyu_temp_lifecycle_activation
	as(select t1.deliver_type, t1.home_store_id , t1.cust_no, t1.auth_person_id,
		CASE WHEN max(b.date_of_day)between '2020-02-13' and '2020-05-11' THEN 'Regualr'
		     ELSE 'reactivation' END AS lifecycle
		from (select a.* from chnccp_msi_z.profile_0513 a left join chnccp_msi_z.ganyu_temp_lifecycle_new b on b.auth_person_id = a.auth_person_id and b.cust_no = a.cust_no and b.home_store_id = a.home_store_id where b.cust_no is NULL) t1
		left join chnccp_dwh.dw_cust_invoice b 
		on t1.home_store_id = b.home_store_id and t1.cust_no = b.cust_no and t1.auth_person_id = b.auth_person_id
		where b.date_of_day <='2020-05-11'
		group by t1.deliver_type, t1.home_store_id, t1.cust_no, t1.auth_person_id
		)with data;


select deliver_type, lifecycle, count(distinct auth_person_id||home_store_id||cust_no) from chnccp_msi_z.ganyu_temp_lifecycle_activation
group by 1,2;
select lifecycle, count(distinct auth_person_id||home_store_id||cust_no) from chnccp_msi_z.ganyu_temp_lifecycle_activation
group by 1;

--total 
select count(distinct auth_person_id||home_store_id||cust_no) from chnccp_msi_z.ganyu_temp_lifecycle_new;
select lifecycle, count(distinct auth_person_id||home_store_id||cust_no) from chnccp_msi_z.ganyu_temp_lifecycle_activation
group by lifecycle;

-----------------------------------------
---------------------4-------------------
drop table chnccp_msi_z.channel_0513;
create table chnccp_msi_z.channel_0513
	as(select home_store_id, cust_no, auth_person_id,channel_ts, order_ts,
		CASE WHEN channel in ('20051301A01WPY000', '20051312A01WPY000') THEN 'Posting'
		     WHEN channel in ('20051303A01MPY000', '20051304A01MPY000') THEN 'Pop-up'
		     WHEN channel in ('20051314A01LSY000', '20051315A01LSY000') THEN 'Liveshow'
		     WHEN channel = '20042901A05MCY000' THEN 'Share'
		     ELSE 'Other' END AS tag, art_name, qty, price, order_status, liveshow, deliver_type from chnccp_crm.evolve_flash_sale 
		where campaign_type = '5.13')with data;

select tag, count(distinct auth_person_id||home_store_id||cust_no),sum(qty) as qty, sum(qty*price) as sales from chnccp_msi_z.channel_0513
where order_status = 1 and qty <>0
group by tag;

select tag, count(distinct auth_person_id||home_store_id||cust_no) from chnccp_msi_z.channel_0513
group by tag;

----------------------------------------
-------------------5--------------------
--sales
select liveshow, count(distinct auth_person_id||home_store_id||cust_no) as buyer, count(auth_person_id||home_store_id||cust_no) as orders, sum(qty) as qty, sum(qty*price) as sales from chnccp_crm.evolve_flash_sale
where order_status = 1 and qty <>0
group by 1;

--uv
select liveshow, count(distinct auth_person_id||home_store_id||cust_no) from chnccp_crm.evolve_flash_sale
group by 1;


