-- 新的备用组3即过去参加过闪购的人群
-- 这次没有使用
/*drop table chnccp_msi_z.flash_sales;
create table chnccp_msi_z.flash_sales
as (
	SELECT DISTINCT home_store_id,cust_no,auth_person_id FROM chnccp_fls.view_frank_auth_person_invoice_line_channel_adj
	WHERE cupr_action_id * 1000 + cupr_action_sequence_id IN (185029660,185029661,185030132,185030113,185030184,185030187,185030363,185030364,185030413,185030412,185030482,185030486,185030487,185030605,185030607,185030803,185030804,185030805,195030928,195030929,195031119,195031068,195031069,195031255,195031256,195031257,195031439,195031440,195031539,195031540,195031541,195031622,195031628,195031629,195031685,195031686,195031687,195031783,195031784,195031785,195031865,195031867,195031868,195031994,195031993,195032015,195032135,195032138,195032139,195032165,195032166,195032168,195032385,195032386,195032387,195032626,195032627,195032628,195032629,195032630,195032631,195032632,195032633,195032634,195032592,195032593,195032594,195032736,195032786,195032741,195033001,195032884,195032886,195033031,195033032,195033033,195033189,195033190,195033191,195033481,195033297,195033298,195033474,195033476,195033478,195033479,195033480,195033631,195033616,195033617,195033618,186345,186345,205126,204637,192680,195033723,195033724,195033765,195033722,195033916,195033917,195033918,195033919,195033967,195033968,195033969,195033971,195033975,195034000,195033977,195033990,195033994,195033993,195033996,195033997,205034351,205034353,205034354,205034355,205034357,205034359,205034360,205034366,205034367,205035081,205035086,205035087,205035088,205035089)) with data; 

drop table chnccp_msi_z.flash_sale_1;
create table chnccp_msi_z.flash_sale_1
	as
	(select a.* from chnccp_msi_z.flash_sales a
		left join chnccp_msi_z.abby_sending b
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		where b.cust_no is NULL
		)with data;

drop table chnccp_msi_z.flash_sale_2;
create table chnccp_msi_z.flash_sale_2
	as
	(select a.* from chnccp_msi_z.flash_sale_1 a
		left join chnccp_msi_z.ganyu_temp_sending b
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		where b.cust_no is NULL
		)with data;

drop table chnccp_msi_z.flash_sale_final;
create table chnccp_msi_z.flash_sale_final
	as (select a.home_store_id, a.cust_no, a.auth_person_id, b.mobile_phone_no from chnccp_msi_z.flash_sale_2 a 
	left join chnccp_dwh.dw_cust_address b
	on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
	where length( b.mobile_phone_no ) = 11) with data; */

------------------------------------------------------------------------SMS user----------------------------------------------------------------
--匹配SMS User：通过订单（首次）渠道表和sending_list的三段码来匹配,匹配成功则归属到SMS渠道中
---------------------------------------------------------
chnccp_msi_z.ganyu_temp
--订单和首次进入渠道情况表（已经合并渠道和订单）
--字段包括cust_no, store_no, auth_person_id, qty, price
--需要从postgres上下载
----------------------------------------------------------

drop table chnccp_msi_z.sending;--total sending list for SMS (including wave1 & wave2)
create table chnccp_msi_z.sending
	as
	(select a.* from 
	((select home_store_id, cust_no, auth_person_id from chnccp_msi_z.ganyu_temp_sending where seg_id in ('seg1', 'seg2', 'seg4', 'seg6','seg7'))--有两组人没有发送
	Union select home_store_id, cust_no, auth_person_id from chnccp_msi_z.abby_sending ) a )with data;

--因为首次进入渠道表中有的type字段OTHERS包括SMS和一些以前遗留下来的渠道码，所以选择时间在12点以后即短信发送时间之后
drop table chnccp_msi_z.ganyu_temp_sms;
create table chnccp_msi_z.ganyu_temp_sms
	as (select a.* from chnccp_msi_z.ganyu_temp a 
		join chnccp_msi_z.sending b
		on a.store_no = b.home_store_id and a.auth_person_id = b.auth_person_id and a.cust_no = b.cust_no
		where a.channel_category = 'Others' and a.dt >= '2020-04-29 12:00:00'
		)with data;
---------------------------------------
--相应输出指标：uv/order/buyer/quantity/sales
select count(distinct cust_no||auth_person_id||store_no) as uv from chnccp_msi_z.ganyu_temp_sms;
select count(*) as order from chnccp_msi_z.ganyu_temp_sms where qty <> 0 and order_status = 1;
select count(distinct cust_no||auth_person_id||store_no) as buyer from  chnccp_msi_z.ganyu_temp_sms where qty <> 0 and order_status = 1;
select sum(qty*price) as sales from chnccp_msi_z.ganyu_temp_sms where qty <> 0 and order_status = 1;
select sum(qty) as quantity from chnccp_msi_z.ganyu_temp_sms where qty <> 0 and order_status = 1;

---------------------------------------
--new participants in flash sales: 7000多
select count(a.auth_person_id||a.home_store_id||a.cust_no) as newusers from chnccp_msi_z.ganyu_temp b 
join chnccp_dwh.dw_cust_auth_person a 
on a.auth_person_id = b.auth_person_id and a.cust_no = b.cust_no and a.home_store_id = b.store_no
where a.create_date = '2020-04-29';

----------------------------------------
--SMS的2个wave输出sending和control组指标
--SMS sending group
--wave1
select b.seg_id, count(distinct a.cust_no||a.auth_person_id||a.store_no) as uv from chnccp_msi_z.ganyu_temp_sms a
join chnccp_msi_z.abby_sending b
on a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id and a.store_no = b.home_store_id
group by b.seg_id
order by b.seg_id;

select b.seg_id, count(a.cust_no) as orders, count(distinct a.cust_no||a.auth_person_id||a.store_no) as buyer, sum(a.qty*a.price) as sales, sum(a.qty) as quantity from chnccp_msi_z.ganyu_temp_sms a
join chnccp_msi_z.abby_sending b
on b.home_store_id = a.store_no and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
where a.qty <> 0 and a.order_status = 1
group by b.seg_id
order by b.seg_id;

--wave2
select b.seg_id, count(distinct a.cust_no||a.auth_person_id||a.store_no) as uv from chnccp_msi_z.ganyu_temp_sms a
join chnccp_msi_z.ganyu_temp_sending b
on a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id and a.store_no = b.home_store_id
where b.seg_id in ('seg1', 'seg2', 'seg4', 'seg6','seg7')
group by b.seg_id
order by b.seg_id;

select b.seg_id, count(a.cust_no) as orders, count(distinct a.cust_no||a.auth_person_id||a.store_no) as buyer, sum(a.qty*a.price) as sales, sum(a.qty) as quantity from chnccp_msi_z.ganyu_temp_sms a
join chnccp_msi_z.ganyu_temp_sending b
on b.home_store_id = a.store_no and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
where a.qty <> 0 and a.order_status = 1 and b.seg_id in ('seg1', 'seg2', 'seg4', 'seg6','seg7')
group by b.seg_id
order by b.seg_id;

-----------------------------------------
--SMS control group
--wave1
select b.seg_id, count(distinct a.cust_no||a.auth_person_id||a.store_no) as uv from chnccp_msi_z.ganyu_temp a
join chnccp_msi_z.abby_control b
on a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id and a.store_no = b.home_store_id
where a.channel_category = 'Others' and a.dt >= '2020-04-29 12:00:00'
group by b.seg_id
order by b.seg_id;

select b.seg_id, count(a.cust_no) as orders, count(distinct a.cust_no||a.auth_person_id||a.store_no) as buyer, sum(a.qty*a.price) as sales, sum(a.qty) as quantity from chnccp_msi_z.ganyu_temp a
join chnccp_msi_z.abby_control b
on a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id and a.store_no = b.home_store_id
where a.channel_category = 'Others' and a.dt >= '2020-04-29 12:00:00' and a.qty <> 0 and a.order_status = 1
group by b.seg_id
order by b.seg_id;

--wave2
select b.seg_id, count(distinct a.cust_no||a.auth_person_id||a.store_no) as uv from chnccp_msi_z.ganyu_temp a
join chnccp_msi_z.ganyu_temp_control b
on a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id and a.store_no = b.home_store_id
where a.channel_category = 'Others' and a.dt >= '2020-04-29 12:00:00'
group by b.seg_id
order by b.seg_id;

select b.seg_id, count(a.cust_no) as orders, count(distinct a.cust_no||a.auth_person_id||a.store_no) as buyer, sum(a.qty*a.price) as sales, sum(a.qty) as quantity from chnccp_msi_z.ganyu_temp a
join chnccp_msi_z.ganyu_temp_control b
on a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id and a.store_no = b.home_store_id
where a.channel_category = 'Others' and a.dt >= '2020-04-29 12:00:00' and a.qty <> 0 and a.order_status = 1
group by b.seg_id
order by b.seg_id;

----------------------------------------------------------------UV统计----------------------------------------------------------------------

chnccp_msi_z.sending --total SMS sending
chnccp_msi_z.ganyu_lighting_deals --短信点击页面的情况

------------------------------------------
--total SMS sending(Wave1 and Wave2)UV
select count(distinct a.storekey||a.custkey||a.cardholderkey) as totaluv from chnccp_msi_z.sending b 
join chnccp_msi_z.ganyu_lighting_deals a 
on a.storekey = b.home_store_id and a.custkey = b.cust_no and a.cardholderkey = b.auth_person_id;

--total SMS control
--table for control group 
drop table chnccp_msi_z.control;
create table chnccp_msi_z.control
	as
	(select a.* from 
	((select home_store_id, cust_no, auth_person_id from chnccp_msi_z.ganyu_temp_control)
	Union 
	(select home_store_id, cust_no, auth_person_id from chnccp_msi_z.abby_control ))a
	)with data;

-------------------------------------------
--total SMS control(Wave1 and Wave2)UV
select count(distinct a.storekey||a.custkey||a.cardholderkey) as totaluv from chnccp_msi_z.control b 
join chnccp_msi_z.ganyu_lighting_deals a 
on a.storekey = b.home_store_id and a.custkey = b.cust_no and a.cardholderkey = b.auth_person_id;

--------------------------------------------
--total sending buyer
select count(distinct a.home_store_id||a.auth_person_id||a.cust_no) as ttlbuyer from chnccp_msi_z.sending a
join (select * from chnccp_msi_z.ganyu_temp where qty <> 0) b
on a.home_store_id = b.store_no and a.auth_person_id = b.auth_person_id and b.cust_no = a.cust_no;

--total control buyer
select count(distinct a.home_store_id||a.auth_person_id||a.cust_no) as ttlbuyer from chnccp_msi_z.control a
join (select * from chnccp_msi_z.ganyu_temp where qty <> 0) b
on a.home_store_id = b.store_no and a.auth_person_id = b.auth_person_id and b.cust_no = a.cust_no;

---------------------------------------------------
--------------------wave1 sending------------------
-----------------------reviewed--------------------
-- sending base
select seg_id, count(*) from chnccp_msi_z.abby_sending group by seg_id;

--all UV
select count(distinct a.storekey||a.custkey||a.cardholderkey) as alluv from chnccp_msi_z.abby_sending b
join chnccp_msi_z.ganyu_lighting_deals a
on a.storekey = b.home_store_id and a.custkey = b.cust_no and a.cardholderkey = b.auth_person_id;

--page UV(fill in art_name for seg_id)
select count(distinct a.storekey||a.custkey||a.cardholderkey) as uv from chnccp_msi_z.abby_sending b
join chnccp_msi_z.ganyu_lighting_deals a
on a.storekey = b.home_store_id and a.custkey = b.cust_no and a.cardholderkey = b.auth_person_id
where b.seg_id = 'seg_' and a.prod_name = '';

--ttl buyer, sales, quantity
select a.seg_id, count(distinct a.home_store_id||a.auth_person_id||a.cust_no) as ttlbuyer, sum(b.qty) as quantity, sum(b.qty* b.price) as sales from chnccp_msi_z.abby_sending a
join (select * from chnccp_msi_z.ganyu_temp where qty <> 0) b
on a.home_store_id = b.store_no and a.auth_person_id = b.auth_person_id and b.cust_no = a.cust_no
group by a.seg_id;

--named buyer with seg_id
--fill in art_name
drop table chnccp_msi_z.ganyu_seg1;
create table chnccp_msi_z.ganyu_seg1
	as (select distinct a.home_store_id, a.cust_no, a.auth_person_id, b.art_name from chnccp_msi_z.abby_sending a
		join chnccp_msi_z.ganyu_temp b
		on a.home_store_id = b.store_no and a.auth_person_id = b.auth_person_id and b.cust_no = a.cust_no
		where b.qty <> 0 and b.art_name = '' and a.seg_id = 'seg_'
		) with data;

select count(distinct a.home_store_id||a.auth_person_id||a.cust_no) as segbuyer, sum(b.qty) as segqty, sum(b.qty* b.price) as segsales from chnccp_msi_z.ganyu_seg1 a
join (select * from chnccp_msi_z.ganyu_temp where qty <> 0 and order_status = 1) b
on a.home_store_id = b.store_no and a.auth_person_id = b.auth_person_id and b.cust_no = a.cust_no;

---------------------------------------------------
-------------------wave2 sending-------------------
---------------------not reviewed------------------
-----------fill in seg_id and art_name--------------
-- sending base
select seg_id, count(*) from chnccp_msi_z.ganyu_temp_sending group by seg_id;

--all UV
select count(distinct a.storekey||a.custkey||a.cardholderkey) as alluv from chnccp_msi_z.ganyu_temp_sending b
join chnccp_msi_z.ganyu_lighting_deals a
on a.storekey = b.home_store_id and a.custkey = b.cust_no and a.cardholderkey = b.auth_person_id
where b.seg_id = 'seg';

--page UV with seg_id
select count(distinct a.storekey||a.custkey||a.cardholderkey) as uv from chnccp_msi_z.ganyu_temp_sending b
join chnccp_msi_z.ganyu_lighting_deals a
on a.storekey = b.home_store_id and a.custkey = b.cust_no and a.cardholderkey = b.auth_person_id
where b.seg_id = 'seg' and a.prod_name = '';

--total buyer, sales, quantity
select count(distinct a.home_store_id||a.auth_person_id||a.cust_no) as ttlbuyer, sum(b.qty) as quantity, sum(b.qty* b.price) as sales from chnccp_msi_z.ganyu_temp_sending a
join (select * from chnccp_msi_z.ganyu_temp where qty <> 0) b
on a.home_store_id = b.store_no and a.auth_person_id = b.auth_person_id and b.cust_no = a.cust_no
where a.seg_id = 'seg';

--named buyer with seg_id
drop table chnccp_msi_z.ganyu_seg1;
create table chnccp_msi_z.ganyu_seg1
	as (select distinct a.home_store_id, a.cust_no, a.auth_person_id, b.art_name from chnccp_msi_z.ganyu_temp_sending a
		join chnccp_msi_z.ganyu_temp b
		on a.home_store_id = b.store_no and a.auth_person_id = b.auth_person_id and b.cust_no = a.cust_no
		where b.qty <> 0 and b.art_name = ' ' and a.seg_id = 'seg'
		) with data;

select count(distinct a.home_store_id||a.auth_person_id||a.cust_no) as segbuyer, sum(b.qty) as segqty, sum(b.qty* b.price) as segsales from chnccp_msi_z.ganyu_seg1 a
join (select * from chnccp_msi_z.ganyu_temp where qty <> 0) b
on a.home_store_id = b.store_no and a.auth_person_id = b.auth_person_id and b.cust_no = a.cust_no;

---------------------------------------------------
-------------------wave1 control-------------------
---------------------not reviewed------------------
-----------fill in seg_id and art_name-------------

--all UV
select count(distinct a.storekey||a.custkey||a.cardholderkey) as alluv from chnccp_msi_z.abby_control b
join chnccp_msi_z.ganyu_lighting_deals a
on a.storekey = b.home_store_id and a.custkey = b.cust_no and a.cardholderkey = b.auth_person_id
where b.seg_id = 'seg_';

--page UV with seg_id
select count(distinct a.storekey||a.custkey||a.cardholderkey) as uv from chnccp_msi_z.abby_control b
join chnccp_msi_z.ganyu_lighting_deals a
on a.storekey = b.home_store_id and a.custkey = b.cust_no and a.cardholderkey = b.auth_person_id
where b.seg_id = 'seg_' and a.prod_name = '';

--ttl buyer, sales, quantity
select count(distinct a.home_store_id||a.auth_person_id||a.cust_no) as ttlbuyer, sum(b.qty) as quantity, sum(b.qty* b.price) as sales from chnccp_msi_z.abby_control a
join (select * from chnccp_msi_z.ganyu_temp where qty <> 0) b
on a.home_store_id = b.store_no and a.auth_person_id = b.auth_person_id and b.cust_no = a.cust_no
where a.seg_id = 'seg_';

--named buyer with seg_id
drop table chnccp_msi_z.ganyu_seg1;
create table chnccp_msi_z.ganyu_seg1
	as (select distinct a.home_store_id, a.cust_no, a.auth_person_id, b.art_name from chnccp_msi_z.abby_control a
		join chnccp_msi_z.ganyu_temp b
		on a.home_store_id = b.store_no and a.auth_person_id = b.auth_person_id and b.cust_no = a.cust_no
		where b.qty <> 0 and b.art_name = '' and a.seg_id = 'seg_'
		) with data;

select count(distinct a.home_store_id||a.auth_person_id||a.cust_no) as segbuyer, sum(b.qty) as segqty, sum(b.qty* b.price) as segsales from chnccp_msi_z.ganyu_seg1 a
join (select * from chnccp_msi_z.ganyu_temp where qty <> 0 ) b
on a.home_store_id = b.store_no and a.auth_person_id = b.auth_person_id and b.cust_no = a.cust_no;

---------------------------------------------------
-------------------wave2 control-------------------
---------------------not reviewed------------------
-----------fill in seg_id and art_name-------------
--all UV
select count(distinct a.storekey||a.custkey||a.cardholderkey) as alluv from chnccp_msi_z.ganyu_temp_control b
join chnccp_msi_z.ganyu_lighting_deals a
on a.storekey = b.home_store_id and a.custkey = b.cust_no and a.cardholderkey = b.auth_person_id
where b.seg_id = 'seg';

--page UV with seg_id
select count(distinct a.storekey||a.custkey||a.cardholderkey) as uv from chnccp_msi_z.ganyu_temp_control b
join chnccp_msi_z.ganyu_lighting_deals a
on a.storekey = b.home_store_id and a.custkey = b.cust_no and a.cardholderkey = b.auth_person_id
where b.seg_id = 'seg' and a.prod_name = '';

--ttl buyer, sales, quantity
select count(distinct a.home_store_id||a.auth_person_id||a.cust_no) as ttlbuyer, sum(b.qty) as quantity, sum(b.qty* b.price) as sales from chnccp_msi_z.ganyu_temp_control a
join (select * from chnccp_msi_z.ganyu_temp where qty <> 0) b
on a.home_store_id = b.store_no and a.auth_person_id = b.auth_person_id and b.cust_no = a.cust_no
where a.seg_id = 'seg';

--named buyer with seg_id
drop table chnccp_msi_z.ganyu_seg1;
create table chnccp_msi_z.ganyu_seg1
	as (select distinct a.home_store_id, a.cust_no, a.auth_person_id, b.art_name from chnccp_msi_z.abby_control a
		join chnccp_msi_z.ganyu_temp b
		on a.home_store_id = b.store_no and a.auth_person_id = b.auth_person_id and b.cust_no = a.cust_no
		where b.qty <> 0 and b.art_name = '' and a.seg_id = 'seg'
		) with data;

select count(distinct a.home_store_id||a.auth_person_id||a.cust_no) as segbuyer, sum(b.qty) as segqty, sum(b.qty* b.price) as segsales from chnccp_msi_z.ganyu_temp_control a
join (select * from chnccp_msi_z.ganyu_temp where qty <> 0 ) b
on a.home_store_id = b.store_no and a.auth_person_id = b.auth_person_id and b.cust_no = a.cust_no;

----------------------------------------------------------------------------------------------------------------------------
------------------------日期转化--------------------------
EXTRACT(parameter (dt AS TIMESTAMP FORMAT 'yyyy/mm/ddBhh:mi:SS.s(6)')) 
--这里的parameter可以是 SECOND/MINUTE/HOUR/DAY/MONTH/YEAR,对应需要的时间

-------------time distribution for customer------
/*select EXTRACT(DAY FROM CAST(b.dt AS TIMESTAMP FORMAT 'yyyy/mm/ddBhh:mi:SS.s(6)')) as days,
EXTRACT(HOUR FROM CAST(b.dt AS TIMESTAMP FORMAT 'yyyy/mm/ddBhh:mi:SS.s(6)')) as hours,
count(distinct a.auth_person_id||a.home_store_id||a.cust_no) as uv from 
(select distinct a.storekey, a.custkey, a.cardholderkey from chnccp_msi_z.abby_control b
join chnccp_msi_z.ganyu_lighting_deals a
on a.storekey = b.home_store_id and a.custkey = b.cust_no and a.cardholderkey = b.auth_person_id
where b.seg_id = 'seg_1') a
join chnccp_msi_z.ganyu_temp b
on a.home_store_id = b.store_no and a.auth_person_id = b.auth_person_id and a.cust_no = b.cust_no
group by 1,2
order by 1,2;*/

-------------------------------------------------------seg_id distribution----------------------------------------------------
------------------Sending group------------------
--what do customers buy within a specific group--

--WAVE 1 Sending segment distribution
select a.seg_id, b.art_name, count(distinct a.home_store_id||a.auth_person_id||a.cust_no) as buyer from chnccp_msi_z.abby_sending a
join (select * from chnccp_msi_z.ganyu_temp where qty <> 0) b
on a.home_store_id = b.store_no and a.auth_person_id = b.auth_person_id and b.cust_no = a.cust_no
where b.art_name is NOT NULL
group by a.seg_id, b.art_name
order by a.seg_id, b.art_name;

--WAVE 2 SENDING segment distribution
select a.seg_id, b.art_name, count(distinct a.home_store_id||a.auth_person_id||a.cust_no) as buyer from chnccp_msi_z.ganyu_temp_sending a
join (select * from chnccp_msi_z.ganyu_temp where qty <> 0) b
on a.home_store_id = b.store_no and a.auth_person_id = b.auth_person_id and b.cust_no = a.cust_no
where b.art_name is NOT NULL
group by a.seg_id, b.art_name
order by a.seg_id, b.art_name;

-----------------Control group-----------------
--what do customers buy within a specific group--

--WAVE 1 Control segment distribution
select a.seg_id, b.art_name, count(distinct a.home_store_id||a.auth_person_id||a.cust_no) as buyer from chnccp_msi_z.abby_control a
join (select * from chnccp_msi_z.ganyu_temp where qty <> 0) b
on a.home_store_id = b.store_no and a.auth_person_id = b.auth_person_id and b.cust_no = a.cust_no
where b.art_name is NOT NULL
group by a.seg_id, b.art_name
order by a.seg_id, b.art_name;

--WAVE 2 Control segment distribution
select a.seg_id, b.art_name, count(distinct a.home_store_id||a.auth_person_id||a.cust_no) as buyer from chnccp_msi_z.ganyu_temp_control a
join (select * from chnccp_msi_z.ganyu_temp where qty <> 0) b
on a.home_store_id = b.store_no and a.auth_person_id = b.auth_person_id and b.cust_no = a.cust_no
where b.art_name is NOT NULL
group by a.seg_id, b.art_name
order by a.seg_id, b.art_name;