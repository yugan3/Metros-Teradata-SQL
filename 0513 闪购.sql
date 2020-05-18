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

select count(distinct home_store_id||cust_no||auth_person_id) as buyer, count(distinct home_store_id||cust_no||auth_person_id) as orders, sum(qty) as qty, sum(qty* price) as sales from chnccp_crm.evolve_flash_sale 
where qty <> 0 and order_status = 1;

select deliver_type, count(distinct home_store_id||cust_no||auth_person_id) as buyer, count(distinct home_store_id||cust_no||auth_person_id) as orders, sum(qty) as qty, sum(qty* price) as sales from chnccp_crm.evolve_flash_sale 
where qty <> 0 and order_status = 1
group by deliver_type;

--cross basket
drop table chnccp_msi_z.pickup_namelist;
create table chnccp_msi_z.pickup_namelist
	as(select home_store_id, cust_no, auth_person_id from chnccp_crm.evolve_flash_sale
		where qty <> 0 and order_status = 1 and deliver_type = 2
		group by home_store_id, cust_no, auth_person_id
		)with data;

select a.home_store_id, a.cust_no, a.auth_person_id, b.date_of_day, b.sell_qty_colli, b.sell_val_gsp, c.art_name, c.mikg_art_no from chnccp_msi_z.pickup_namelist a 
join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj  b 
on a.cust_no = b.cust_no and a.home_store_id = b.home_store_id and a.auth_person_id = b.auth_person_id
join chnccp_dwh.dw_art_var_tu c 
on c.art_no = b.art_no and c.var_tu_key = b.var_tu_key
where b.date_of_day between '2020-05-16' and '2020-05-17'
and c.mikg_art_no not in (225289,232399,118457,225558,209535,209535);

--qty for picking and delivery
--610
select b.mikg_art_no,b.art_name,b.art_name_tl
,sum(a.sell_qty_colli) qty
,sum(sell_val_gsp) as gross_sales
,count(distinct a.invoice_id) as orders
,count(distinct a.home_store_id || a.cust_no|| a.auth_person_id)  as buyer
,sum(sell_val_nsp) as net_sales
from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj  a
inner join chnccp_dwh.dw_art_var_tu b
	on a.art_no = b.art_no and a.var_tu_key = b.var_tu_Key
where a.date_of_day between '2020-05-12' and  '2020-05-19'  --对应发货的时间
and b.mikg_art_no = 233012 --大仓610发货的商品
and a.store_id = 610
and a.deli_ind = 'Y'
group by 1,2,3
order by 1;

--10
select c.mikg_art_no,c.art_name,c.art_name_tl
,sum(a.sell_qty_colli) qty
,sum(a.sell_val_gsp) as gross_sales
,count(distinct a.invoice_id) as orders
,count(distinct a.home_store_id || a.cust_no|| a.auth_person_id)  as buyer
,sum(a.sell_val_nsp) as net_sales
 from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj  a
 inner join (
	-- order 
	select a.invoice_id,a.home_store_id,a.cust_no,a.auth_person_id
	,sum(sell_val_gsp) as gross_sales
	,sum(sell_val_nsp) as net_sales
	from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj  a
	where a.date_of_day between '2020-05-12' and  '2020-05-19'  --对应发货的时间
	and a.art_no = 213223 --负商品编号
	and a.store_id = 10
	and a.deli_ind = 'Y'
	group by 1,2,3,4
) b
on a.invoice_id = b.invoice_id 
inner join chnccp_dwh.dw_art_var_tu c
	on a.art_no =c.art_no and a.var_tu_key = c.var_tu_Key
where  c.mikg_art_no in (231680, 233084) --门店发货的商品编号
group by 1,2,3
order by 1

--pick-up
--else then KIWI
SELECT b.mikg_art_no, b.art_name, b.art_name_tl
,sum(a.sell_qty_colli) as qty
,sum(a.sell_val_gsp) as gross_sales
,count(distinct a.invoice_id) as orders
,count(distinct a.home_store_id || a.cust_no|| a.auth_person_id)  as buyer
,sum(a.sell_val_nsp) as net_sales
FROM chnccp_fls.view_frank_auth_person_invoice_line a
INNER JOIN chnccp_dwh.dw_art_var_tu b
	ON a.art_no =b.art_no 
	AND a.var_tu_key = b.var_tu_Key
WHERE a.date_of_day BETWEEN '2020-05-12' and  '2020-05-19' --对应发货的时间
	AND b.mikg_art_no IN (225289, 232399, 118457, 209535) --自提的商品编号
	AND
a.cupr_action_id * 1000 + a.cupr_action_sequence_id IN (205035366, 205035367, 205035368, 205035490, 205035491)
GROUP BY 1,2,3
order by 1;

--for KIWI
SELECT b.mikg_art_no, b.art_name, b.art_name_tl
,sum(a.sell_qty_colli) as qty
,sum(a.sell_val_gsp) as gross_sales
,count(distinct a.invoice_id) as orders
,count(distinct a.home_store_id || a.cust_no|| a.auth_person_id)  as buyer
,sum(a.sell_val_nsp) as net_sales
FROM chnccp_fls.view_frank_auth_person_invoice_line a
INNER JOIN chnccp_dwh.dw_art_var_tu b
	ON a.art_no =b.art_no 
	AND a.var_tu_key = b.var_tu_Key
WHERE a.date_of_day BETWEEN '2020-05-12' and  '2020-05-19' --对应发货的时间
	AND b.mikg_art_no = 225558 --自提的商品编号
	AND a.cupr_action_id * 1000 + a.cupr_action_sequence_id = 205035486
	and a.store_id in (10,12,17,44,50,139,173,198,229,11,40,41,54,60,62,66,76,105,67,179,14,38,55,68,72,164,130,141,127,163,13,42,74,125,70,142)
GROUP BY 1,2,3
order by 1;


--fullfilment pick-up customer: 12157
select count(distinct t1.auth_person_id||t1.home_store_id||t1.auth_person_id) from
((select a.cust_no, a.home_store_id, a.auth_person_id from chnccp_fls.view_frank_auth_person_invoice_line a
INNER JOIN chnccp_dwh.dw_art_var_tu b
	ON a.art_no =b.art_no 
	AND a.var_tu_key = b.var_tu_Key
WHERE a.date_of_day BETWEEN '2020-05-12' and  '2020-05-19' --对应发货的时间
	AND b.mikg_art_no = 225558 --自提的商品编号
	AND a.cupr_action_id * 1000 + a.cupr_action_sequence_id = 205035486
	and a.store_id in (10,12,17,44,50,139,173,198,229,11,40,41,54,60,62,66,76,105,67,179,14,38,55,68,72,164,130,141,127,163,13,42,74,125,70,142)
 ) Union 
(select a.cust_no, a.home_store_id, a.auth_person_id 
	FROM chnccp_fls.view_frank_auth_person_invoice_line a
INNER JOIN chnccp_dwh.dw_art_var_tu b
	ON a.art_no =b.art_no 
	AND a.var_tu_key = b.var_tu_Key
WHERE a.date_of_day BETWEEN '2020-05-12' and  '2020-05-19' --对应发货的时间
	AND b.mikg_art_no IN (225289, 232399, 118457, 209535) --自提的商品编号
	AND
a.cupr_action_id * 1000 + a.cupr_action_sequence_id IN (205035366, 205035367, 205035368, 205035490, 205035491)
)) t1;



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

--------------------------------------
------------channel check-------------
create table userinfo_0513 
	as(select storekey as home_store_id, custkey as cust_no, cardholderkey as auth_person_id, channel,
		CASE WHEN channel in ('20051301A01WPY000', '20051312A01WPY000') THEN 'Posting'
		     WHEN channel in ('20051303A01MPY000', '20051304A01MPY000') THEN 'Pop-up'
		     WHEN channel in ('20051314A01LSY000', '20051315A01LSY000') THEN 'Liveshow'
		     WHEN channel = '20042901A05MCY000' THEN 'Share'
		     ELSE 'Other' END AS tag
		     from first_channel_userinfo where campaign_type = '5.13');

select tag, count(distinct home_store_id|cust_no|auth_person_id) from userinfo_0513
group by tag;




------------------------------------------
----------address temp table--------------
drop table chnccp_msi_z.flashsales_address_order;
create table chnccp_msi_z.flashsales_address_order
	(home_store_id INTEGER,
	cust_no INTEGER,
	auth_person_id INTEGER
	province VARCHAR(36),
	city VARCHAR(36), 
	district VARCHAR(36),
	detailed_address VARCHAR(36));

--------temp table into final table-------
update chnccp_msi_z.address set detailed_address = '' where home_store_id =  and cust_no =  and auth_person_id = ;
insert into chnccp_msi_z.address select '0513' as flashsales, home_store_id, cust_no, auth_person_id, province, city, district, detailed_address from chnccp_msi_z.flashsales_address_order;

select art_name, count(store_no||cust_no||auth_person_id) as orders, sum(qty) as quantity from chnccp_msi_z.ganyu_temp
where order_status = 1 and qty <> 0
group by art_name;

------------------------------------------
select gcn_np, count(auth_person_id||home_store_id||cust_no) as people from chnccp_dwh.dw_gcn_campaign_event
where gcn_no in(6947890911839,6947890911846,6947890911853,6947890912034,6947890912096,6947890912102) and gcn_disposition = 'redeemed';
