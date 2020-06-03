------------------------------------------------
--channel渠道明细
create table chnccp_msi_z.ganyu_channel_first_userinfo(
channel VARCHAR(200),
storekey INTEGER,
custkey INTEGER,
cardholderkey INTEGER
)

drop table chnccp_msi_z.ganyu_temp_channel_first_userinfo;
create table chnccp_msi_z.ganyu_temp_channel_first_userinfo
	as(select channel as channel, storekey as home_store_id, custkey as cust_no, cardholderkey as auth_person_id from chnccp_msi_z.ganyu_channel_first_userinfo
		where storekey is NOT NULL
		)with data;

drop table chnccp_msi_z.ganyu_temp_channel_first_userinfo_output;
create table chnccp_msi_z.ganyu_temp_channel_first_userinfo_output
	as(select a.*, CAST(b.mobile_phone_no AS DECIMAL(11)) from chnccp_msi_z.ganyu_temp_channel_first_userinfo a 
		left join chnccp_dwh.dw_cust_address b
		on a.home_store_id = b.home_store_id and a.auth_person_id = b.auth_person_id and a.cust_no = b.cust_no 
		)with data;

-------------------------------------------------
------------------maotaishangou------------------
create table chnccp_msi_z.maotai
as(select a.* from 
((select a.home_store_id ,a.cust_no ,a.auth_person_id
from chnccp_dwh.dw_cust_auth_person a
inner join chnccp_msi_z.mem_ref_umc_tag_act c
on a.home_store_id = c.home_store_id and a.cust_no = c.cust_no and a.auth_person_id = c.auth_person_id
where a.home_store_id in (11,40,41,54,60,62,66,67,76,105,179)
and c.member_type = 'UMC+')
Union
(select distinct CAST(home_store_id AS DEC(5)) , CAST(cust_no AS DEC(8)), CAST(auth_person_id AS DEC(2))  from chnccp_msi_z.frank_paid_member_dashboard_cust_2
where  plus_join_store in  (11,40,41,54,60,62,66,67,76,105,179)) )a
)with data;

select home_store_id ,cust_no ,auth_person_id from chnccp_msi_z.maotai;


--------------------异地购买---------------------
--no.customer
select count(distinct auth_person_id||home_store_id||cust_no) as people from chnccp_msi_z.flashsales_address
where province not in('上海','江苏','浙江','福建','湖北','山东','辽宁','重庆','四川','湖南','天津','陕西','广东','深圳','北京','黑龙江','安徽','河南','云南','江西','吉林','宁夏','贵州','甘肃')
or city not in ('上海市','无锡市','宁波市','南京市','福州市','武汉市','青岛市','大连市','重庆市','成都市','长沙市','天津市','西安市','厦门市','东莞市','深圳市','北京市','沈阳市','广州市','哈尔滨市','合肥市','郑州市','常熟市','苏州市','杭州市','昆明市','南昌市','泉州市','南通市','长春市','银川市','中山市','常州市','张家港市','扬州市','烟台市','慈溪市','宜兴市','淄博市','潍坊市','株洲市','台州市','徐州市','盐城市','宜昌市','淮安市','绍兴市','襄阳市','莆田市','临沂市','芜湖市','九江市','贵阳市','济南市','德阳市','兰州市');
--no.orders
drop table chnccp_msi_z.flashsales_address_orders;
create table chnccp_msi_z.flashsales_address_orders(
home_store_id INTEGER,
cust_no INTEGER,
auth_person_id INTEGER,
province VARCHAR(36),
city VARCHAR(36),
district VARCHAR(36),
detailed_address VARCHAR(36)) --size不要太大，否则无法显示

select count(auth_person_id||home_store_id||cust_no) as orders from chnccp_msi_z.flashsales_address_orders
where province not in ('上海','江苏','安徽','湖北','陕西','宁夏','甘肃','辽宁','北京','黑龙江','吉林','山东','天津','河南','广东','深圳','浙江','福建','重庆','四川','湖南','云南','江西','贵州')
or city not in ('上海市','无锡市','苏州市','常州市','宜兴市','南京市','合肥市','南通市','扬州市','徐州市','盐城市','淮安市','芜湖市','镇江市','武汉市','西安市','银川市','宜昌市','襄阳市','兰州市','大连市','北京市','沈阳市','哈尔滨市','长春市','青岛市','天津市','郑州市','烟台市','淄博市','潍坊市','临沂市','济南市','东莞市','深圳市','广州市','中山市','宁波市','福州市','厦门市','杭州市','泉州市','台州市','绍兴市','莆田市','重庆市','成都市','德阳市','长沙市','昆明市','南昌市','株洲市','九江市','贵阳市')

------------------------------------------------
-------------------liveshow---------------------
drop table chnccp_msi_z.liveshow_newuser;
create table chnccp_msi_z.liveshow_newuser(
storekey INTEGER,
custkey INTEGER,
cardholderkey INTEGER);

--date_created
select count(distinct a.storekey||a.custkey||a.cardholderkey) as people from chnccp_msi_z.liveshow_newuser a 
join chnccp_dwh.dw_cust_auth_person b 
on a.storekey = b.home_store_id and a.custkey = b.cust_no and a.cardholderkey = b.auth_person_id
where b.date_created ='2020-04-29';

--new user
--先找到人再计算人数
select a.storekey, a.custkey, a.cardholderkey from chnccp_msi_z.liveshow_newuser a 
left join chnccp_dwh.dw_cust_invoice b 
on a.storekey = b.home_store_id and a.custkey = b.cust_no and a.cardholderkey = b.auth_person_id
having min(b.date_of_day) >= '2020-04-29';

-----------------------------------------------
------------------首单发货测算------------------ 
--points >= 2
select a.home_store_id,count(*) as points
from  chnccp_dwh.dw_mcrm_loy_member a
inner join chnccp_dwh.dw_mcrm_loy_mem_balance b
on a.loy_mem_row_id = b.loy_mem_row_id
where a.loy_mem_parent_ind = 0
and b.loy_mem_num_available_pts >= 2
group by a.home_store_id
order by a.home_store_id;



--雪碧
select a.store_id,count(distinct a.home_store_id || a.cust_no) as buyer
from chnccp_dwh.dw_cust_invoice_line a
inner join chnccp_dwh.dw_art_var_tu  b
on a.art_no =b.art_no and a.var_tu_key = b.var_tu_key
where  b.art_name like '%雪碧%'
and a.date_of_day between add_months( date-1,-12) and date - 1
group by a.store_id
order by  a.store_id;

--伊利巧乐兹绮炫比利时巧克力脆层+香草口味冰淇淋65g  /   伊利须尽欢胡萝卜橙子酸奶冰淇淋 65g
select a.store_id,count(distinct a.home_store_id || a.cust_no) as buyer
from chnccp_dwh.dw_cust_invoice_line a
inner join chnccp_dwh.dw_art_var_tu  b
on a.art_no =b.art_no and a.var_tu_key = b.var_tu_key
where  b.art_name like '%冰淇淋%'
and a.month_id = 201906 
group by a.store_id;

--巴利特小麦黑啤酒 500ml
select a.store_id,count(distinct a.home_store_id || a.cust_no) as buyer
from chnccp_dwh.dw_cust_invoice_line a
inner join chnccp_dwh.dw_art_var_tu  b
on a.art_no =b.art_no and a.var_tu_key = b.var_tu_key
where (b.art_name like '%黑啤%' OR  (b.demand_field_domain_id = 605 and b.pcg_main_cat_id = 454))
and a.month_id in (201905, 201906, 201907)
group by a.store_id;

--蒙牛纯甄果粒轻酪乳白桃+石榴味风味酸奶230g
select a.store_id,count(distinct a.home_store_id || a.cust_no) as buyer
from chnccp_dwh.dw_cust_invoice_line a
inner join chnccp_dwh.dw_art_var_tu  b
on a.art_no =b.art_no and a.var_tu_key = b.var_tu_key
where  b.art_name like '%酸奶%'
and a.date_of_day between add_months( date-1,-12) and date - 1
group by a.store_id
order by  a.store_id;

--鹅岛312小麦风味艾尔啤酒 355ml瓶装
select a.store_id,count(distinct a.home_store_id || a.cust_no) as buyer
from chnccp_dwh.dw_cust_invoice_line a
inner join chnccp_dwh.dw_art_var_tu  b
on a.art_no =b.art_no and a.var_tu_key = b.var_tu_key
where (b.art_name like '%鹅岛%' OR  (b.demand_field_domain_id = 605 and b.pcg_main_cat_id = 453))
and a.month_id in (201905, 201906, 201907)
group by a.store_id;

--PATAGONIA帕塔歌尼亚白啤CAN听装473ml 

select a.store_id,count(distinct a.home_store_id || a.cust_no) as buyer
from chnccp_dwh.dw_cust_invoice_line a
inner join chnccp_dwh.dw_art_var_tu  b
on a.art_no =b.art_no and a.var_tu_key = b.var_tu_key
where (b.art_name like '%帕塔歌尼亚%' OR  (b.demand_field_domain_id = 605 and b.pcg_main_cat_id = 452))
and a.month_id in (201905, 201906, 201907)
group by a.store_id;

--多芬白桃果香浓密沐浴泡泡 400ml
select a.store_id,count(distinct a.home_store_id || a.cust_no) as buyer
from chnccp_dwh.dw_cust_invoice_line a
inner join chnccp_dwh.dw_art_var_tu  b
on a.art_no =b.art_no and a.var_tu_key = b.var_tu_key
where b.art_name like '%多芬%沐浴%'
and a.date_of_day between add_months( date-1,-12) and date - 1
group by a.store_id;

--redeemed from weekly report

-----------------namelist-----------------
--postgresql
create table diwangxie
	as(select store_key,cust_key, ch_key from metro_order.release_order_orders
	where count != 0 and goods_name like '%帝王蟹%' and order_status = 1);

--teradata
drop table chnccp_msi_z.diwangxie;
create table chnccp_msi_z.diwangxie
 (home_store_id INTEGER,
      cust_no INTEGER, 
	  auth_person_id INTEGER);
-----------------------------------------
--last chongqing: 196
select min(date_of_day) as opentime from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj 
where store_id = 196;

select store_id, count(distinct auth_person_id||home_store_id||cust_no) as buyer, sum(sell_val_gsp)/count(distinct invoice_id) as basket from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj
where store_id = 196 and date_of_day between '2019-11-20' and '2019-12-19'
and wel_ind = 'N' and fsd_ind = 'N' and deli_ind = 'N' and bvs_ind = 'N' and pcr_ind = 'N'
group by store_id;

drop table chnccp_msi_z.chongqing;
create table chnccp_msi_z.chongqing
	as(select store_id, auth_person_id, home_store_id, cust_no, sum(sell_val_gsp)/count(distinct invoice_id) as basket, count(distinct date_of_day) as repeats from  chnccp_fls.view_frank_auth_person_invoice_line_channel_adj
		where store_id = 196 and date_of_day between '2019-11-20' and '2020-02-19'
		and wel_ind = 'N' and fsd_ind = 'N' and deli_ind = 'N' and bvs_ind = 'N' and pcr_ind = 'N'
		group by store_id, auth_person_id, home_store_id, cust_no
		)with data;

select store_id, count(distinct auth_person_id||home_store_id||cust_no) as people, avg(basket), count(CASE WHEN repeats >=2 THEN repeats END) from chnccp_msi_z.chognqing
group by store_id;

-----------------------------------------
--beijing four shops -290642
select distinct home_store_id, cust_no, auth_person_id from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj 
where date_of_day between '2019-05-20' and '2020-05-19' and store_id in (31,37,46,108);

----------------------------------------
drop table duihuan;
create table duihuan as (
	select co.user_id,co.state,co.create_time, co.pick_store, c.trade_no_sub,c.sku_id,c.count,c.coupon_csn,c.coupon_epc 
from campaign_manager.campaign_orders co 
join campaign_manager.carts c on c.trade_no = co.trade_no where c.campaign_id in (1,2) and co.state >=11);


/*select b.home_store_id, b.cust_no, b.auth_person_id, a.gcn_disposition, b.epc, b.create_time from chnccp_dwh.dw_gcn_campaign_event a 
join chnccp_msi_z.duihuan_01 b
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id and b.epc = a.sgcn_no
where a.gcn_no in (
6947890910986,
6947890911013,
6947890910931,
6947890910979,
6947890910955,
6947890910948, 
6947890911006,
6947890910962,
6947890909638,
6947890909720, 
6947890909737, 
6947890909744, 
6947890909751, 
6947890909768, 
6947890909775, 
6947890909782)
and a.gcn_disposition = 'redeemable' and CAST(b.create_time as date)> '2020-04-27';*/


drop table chnccp_msi_z.duihuan;
create table chnccp_msi_z.duihuan
(user_id VARCHAR(48),
create_time timestamp,
pick_store INTEGER,
sku_id INTEGER,
coupon_epc CHAR(64));


drop table chnccp_msi_z.duihuan_01;
create table chnccp_msi_z.duihuan_01 
as (select STRTOK(t.user_id, '_', 1) as home_store_id, STRTOK(t.user_id, '_', 2) as cust_no, STRTOK(t.user_id, '_', 3) as auth_person_id, 
CAST(create_time as date) as create_time, pick_store, sku_id,STRTOK(t.coupon_epc, ':', 5) as epc  from chnccp_msi_z.duihuan t
)with data;


drop table chnccp_msi_z.duihuan_gcn;
create table chnccp_msi_z.duihuan_gcn
as(select a.*, b.gcn_disposition from chnccp_msi_z.duihuan_01 a
join  chnccp_dwh.dw_gcn_campaign_event b 
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id and a.epc = b.sgcn_no
where b.gcn_disposition = 'redeemed')with data;


drop table chnccp_msi_z.duihuan_tbc;
create table chnccp_msi_z.duihuan_tbc
	as(select a.* from chnccp_msi_z.duihuan_01 a 
		left join chnccp_msi_z.duihuan_gcn b
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id and a.epc = b.epc
		where b.cust_no is NULL or b.auth_person_id is NULL or b.auth_person_id is NULL or b.epc is
		)with data;

drop table chnccp_msi_z.duihuan_valid;
create table chnccp_msi_z.duihuan_valid
	as
	(select * from chnccp_msi_z.duihuan_tbc
		where create_time >= '2020-04-27')with data;

drop table chnccp_msi_z.duihuan_invalid;
create table chnccp_msi_z.duihuan_invalid
	as(select a.* from chnccp_msi_z.duihuan_tbc a
		left join chnccp_msi_z.duihuan_valid b
		on a.home_store_id = b.home_store_id and a.auth_person_id = b.auth_person_id and a.cust_no = b.cust_no and a.epc = b.epc
		where b.cust_no is NULL)with data;

------OPA
select distinct a.art_no, b.art_name, a.sell_val_gsp from chnccp_dwh.dw_cust_invoice_line a 
left join chnccp_dwh.dw_art_var_tu b
on a.art_no = b.art_no and a.var_tu_key = b.var_tu_key
where a.date_of_day between '2019-11-29' and '2020-05-28'
and a.art_no in (213844,
209317,
950377,
213384,
213752,
63772);

select distinct b.mikg_art_no, b.art_name, a.sell_val_gsp from chnccp_dwh.dw_cust_invoice_line a 
join chnccp_dwh.dw_art_var_tu b
on a.art_no = b.art_no and a.var_tu_key = b.var_tu_key
where a.date_of_day between '2019-11-29' and '2020-05-28'
and b.mikg_art_no  = 63772;

---------------------------------------
--VIEW中在一个数据库访问另一个数据库中的表格需要赋权
--TERADATA中的问题
GRANT SELECT ON tablename TO database_name WITH GRANT OPTION;

--------------------------------------
--PLUS会员节约金额

--PLUS会员数
drop table chnccp_msi_z.PLUS_Maynamelist;
create table chnccp_msi_z.PLUS_Maynamelist
	as(select a.home_store_id, a.cust_no, a.auth_person_id, c.Cardnumber, c.Mobile
from chnccp_crm.frank_paid_member_dashboard_cust_2 a 
left join chnccp_dwh.dw_customer b 
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no
left join chnccp_msi_z.paid_member_from_evolve c 
on a.home_store_id = c.home_store_id and a.cust_no = c.cust_no and c.auth_person_id = c.auth_person_id
where a.join_date <= '2020-05-31'
and b.branch_id in (401,492,493,971,973))with data;

--saving money
drop table chnccp_msi_z.PLUS_Maysaving;
create table chnccp_msi_z.PLUS_Maysaving 
	as(select home_store_id, cust_no, disc_val_nsp, disc_action_id, date_of_day from chnccp_dwh.dw_cust_invoice_line_disc
		where date_of_day between '2020-05-01' and '2020-05-31'
		and disc_action_id in (205035370,205035371,205035372,205035384,205035374,205035375,205035376,205035377,205035378,205035379,205035380,205035381,205035382,205035383,195032270,195032271,195032272,205035022,205035018,205035021)
		)with data;

--total savings
--by coupon
drop table chnccp_msi_z.PLUS_Maytotal;
create table chnccp_msi_z.PLUS_Maytotal
	as(select a.home_store_id, a.cust_no, a.auth_person_id, right(a.Cardnumber,4) as Cardnumber, c.mobile_phone_no, sum(b.disc_val_nsp) as savingmoney, b.disc_action_id from chnccp_msi_z.PLUS_Maynamelist a 
		left join chnccp_msi_z.PLUS_Maysaving b
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no
		left join chnccp_dwh.dw_cust_address c 
		on a.home_store_id = c.home_store_id and a.cust_no = c.cust_no and a.auth_person_id = c.auth_person_id
		group by a.home_store_id, a.cust_no, a.auth_person_id, Cardnumber, c.mobile_phone_no, b.disc_action_id)with data;

--coupon_type
select CASE WHEN disc_action_id in (205035374,205035375,205035376,205035377,205035378,205035379,205035380,205035381,205035382,205035383) THEN 'member_price'
            WHEN disc_action_id in (205035370,205035371,205035372,205035384) THEN 'crazy_offer'
            WHEN disc_action_id in (195032270,195032271,195032272,205035022,205035018,205035021) THEN 'cash_coupon' END AS coupon_type,
            sum(savingmoney) as money, count(distinct home_store_id||cust_no) as people, count(home_store_id||cust_no) as times
from chnccp_msi_z.PLUS_Maytotal
group by coupon_type;

--by buyer
drop table chnccp_msi_z.PLUS_Maytotal_1;
create table chnccp_msi_z.PLUS_Maytotal_1
	as(select a.home_store_id, a.cust_no, a.auth_person_id, right(a.Cardnumber,4) as Cardnumber, c.mobile_phone_no, sum(b.disc_val_nsp) as savingmoney from chnccp_msi_z.PLUS_Maynamelist a 
		left join chnccp_msi_z.PLUS_Maysaving b
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no
		left join chnccp_dwh.dw_cust_address c 
		on a.home_store_id = c.home_store_id and a.cust_no = c.cust_no and a.auth_person_id = c.auth_person_id
		group by a.home_store_id, a.cust_no, a.auth_person_id, Cardnumber, c.mobile_phone_no)with data;

---------check
--high
select a.home_store_id, a.cust_no, a.auth_person_id, a.art_no, a.cupr_action_id * 1000 + a.cupr_action_sequence_id as dnr, a.date_of_day, a.sell_val_gsp, b.art_name
from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj a
left join chnccp_dwh.dw_art_var_tu b
on a.var_tu_key = b.var_tu_key and a.art_no = b.art_no
where a.home_store_id = 19 and a.cust_no = 2102515 and a.auth_person_id = 1
and a.cupr_action_id * 1000 + a.cupr_action_sequence_id IN  (205035370,205035371,205035372,205035384,205035374,205035375,205035376,205035377,205035378,205035379,205035380,205035381,205035382,205035383,195032270,195032271,195032272,205035022,205035018,205035021)
and a.date_of_day between '2020-05-01' and '2020-05-31';

--low
select a.home_store_id, a.cust_no, a.auth_person_id, a.art_no, a.cupr_action_id * 1000 + a.cupr_action_sequence_id as dnr, a.date_of_day, a.sell_val_gsp, b.art_name
from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj a
left join chnccp_dwh.dw_art_var_tu b
on a.var_tu_key = b.var_tu_key and a.art_no = b.art_no
where (a.home_store_id = 20 and a.cust_no = 107708 and a.auth_person_id = 1) Or 
(a.home_store_id = 10 and a.cust_no = 90410 and a.auth_person_id = 1) Or 	 
(a.home_store_id = 53 and a.cust_no = 2013394 and a.auth_person_id = 1) 
and a.cupr_action_id * 1000 + a.cupr_action_sequence_id IN  (205035370,205035371,205035372,205035384,205035374,205035375,205035376,205035377,205035378,205035379,205035380,205035381,205035382,205035383,195032270,195032271,195032272,205035022,205035018,205035021)
and a.date_of_day between '2020-05-01' and '2020-05-31';

-----duplicate cards check cards
select a.home_store_id, a.cust_no, a.auth_person_id, a.auth_person_short_name, 
CASE WHEN b.home_store_id is not NULL THEN 'Y' ELSE 'N' END AS plus from chnccp_dwh.dw_cust_auth_person a
left join chnccp_crm.frank_paid_member_dashboard_cust_2 b 
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
where  (a.home_store_id = 10	 and a.cust_no =912213	)
Or (a.home_store_id = 10	 and a.cust_no = 90230	  )
Or (a.home_store_id = 10	 and a.cust_no = 912190  )
Or (a.home_store_id = 10	 and a.cust_no = 17480	  )
Or (a.home_store_id = 16	 and a.cust_no = 33355	  )
Or (a.home_store_id = 16	 and a.cust_no = 34344	  )
Or (a.home_store_id = 16	 and a.cust_no = 62339	  )
Or (a.home_store_id = 20	 and a.cust_no = 154223  )
Or (a.home_store_id = 20	 and a.cust_no = 910218  )
Or (a.home_store_id = 40	 and a.cust_no = 52056	  )
Or (a.home_store_id = 41	 and a.cust_no = 65586	  )
Or (a.home_store_id = 41	 and a.cust_no = 66013	  )
Or (a.home_store_id = 41	 and a.cust_no = 63352	  )
Or (a.home_store_id = 44	 and a.cust_no = 899795  )
Or (a.home_store_id = 59	 and a.cust_no = 60205	  )
Or (a.home_store_id = 62	 and a.cust_no = 33672	  )
Or (a.home_store_id = 62	 and a.cust_no = 33577	  )
Or (a.home_store_id = 62	 and a.cust_no = 34418	  )
Or (a.home_store_id = 62	 and a.cust_no = 88156	  )
Or (a.home_store_id = 62	 and a.cust_no = 33578	  )
Or (a.home_store_id = 62	 and a.cust_no = 33567	  )
Or (a.home_store_id = 67	 and a.cust_no = 56194	  )
Or (a.home_store_id = 67	 and a.cust_no = 59564	  )
Or (a.home_store_id = 67	 and a.cust_no = 50048	  )
Or (a.home_store_id = 67	 and a.cust_no = 51236	  )
Or (a.home_store_id = 67	 and a.cust_no = 57828	  )
Or (a.home_store_id = 80	 and a.cust_no = 76305	  )
Or (a.home_store_id = 105    and a.cust_no = 	18292  )
Or (a.home_store_id = 158    and a.cust_no = 	32902  )
Or (a.home_store_id = 158    and a.cust_no = 	32897  )
Or (a.home_store_id = 158    and a.cust_no = 	32901  )
Or (a.home_store_id = 160    and a.cust_no = 	66666  );
