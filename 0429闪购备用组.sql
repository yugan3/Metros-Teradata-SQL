
--母婴
drop table chnccp_msi_z.ganyu_temp_othermilkpower;
create table chnccp_msi_z.ganyu_temp_othermilkpower
as(select a.cust_no, a.home_store_id, a.auth_person_id from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj a
	join chnccp_dwh.dw_art_var_tu  b
	on a.art_no = b.art_no and a.var_tu_key = b.var_tu_key
	where a.date_of_day between '2019-04-24'and'2020-04-23'
	and a.wel_ind = 'N' 
	and a.fsd_ind = 'N' 
	and a.deli_ind = 'N' 
	and a.bvs_ind = 'N' 
	and a.pcr_ind = 'N'
	and b.mikg_art_no in (178297,78298,178299,183378,203346,203347,203348,203350,6038,27743,31156,108861,108864,115824,115825,126559,126564,126561,133090,133093,144853,144854,144855,144859,144871,169757,181897,181898,181899,201937,535363,962019,221852,221853,221855,221856,148156,148155,148157,148159,148160,179251,179252,179253,179256,179257,211753,211756,170658,170659,170660,170661,170662,170663,170664,170665,186713,186714,186715,186717,222796,222797,222798)
) with data;

drop table chnccp_msi_z.ganyu_temp_seg1and2;
create table chnccp_msi_z.ganyu_temp_seg1and2
as(select 'seg12' as seg_id, a.home_store_id, a.cust_no, a.auth_person_id, sum(a.sell_val_gsp) as gross_sales,count (distinct a.date_of_day) as visits,sum(a.sell_val_gsp) /sum(a.tunit_qty*a.sell_qty_colli) as avg_price,max(a.date_of_day) as recency from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj a 
	join chnccp_dwh.dw_art_var_tu b
	on a.var_tu_key = b.var_tu_key and a.art_no = b.art_no
	where a.date_of_day between '2019-04-24' and '2020-04-23'
	and a.wel_ind = 'N'
	and a.fsd_ind = 'N'
    and a.deli_ind = 'N'
    and a.bvs_ind = 'N' 
    and a.pcr_ind = 'N'
    and b.mikg_art_no in (133751,133753,133759,133763,133764,175294,175295,175296,175298,184179,184180,184182,184183,176325,176326,176332,176337,176338,176348,133750,133752,133756,133757,133758,153497,153500,133762,211198,211199,172690,172692,172694,172695,191412,191413,191414,191415,191416,191417,133760,200401,200402,186698,186699,194655,213658,202014,202015,202016,202018,202019,207658,207660,207661,207662,207663,221820,221821,221822)
    group by 1,2,3,4
    having sum(a.sell_val_gsp) >0 and sum(a.tunit_qty*a.sell_qty_colli) > 0
 ) with data;

drop table chnccp_msi_z.ganuyu_temp_seg1;
create table chnccp_msi_z.ganuyu_temp_seg1
as(select 1 as prio, 'seg1' as seg_id, a.home_store_id, a.cust_no, a.auth_person_id, a.gross_sales, a.visits, a.avg_price, a.recency from chnccp_msi_z.ganyu_temp_seg1and2 a 
	left join chnccp_msi_z.ganyu_temp_othermilkpower b
	on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
	where b.home_store_id is NULL
) with data;


--防晒
drop table chnccp_msi_z.ganyu_temp_seg2_skincare;
create table chnccp_msi_z.ganyu_temp_seg2_skincare
as(select 7 as prio, 'seg2'as seg_id, a.home_store_id, a.cust_no, a.auth_person_id, sum(a.sell_val_gsp) as gross_sales, 
   count (distinct a.date_of_day) as visits,sum(a.sell_val_gsp) /sum(a.tunit_qty*a.sell_qty_colli) as avg_price,max(a.date_of_day) as recency from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj a
   join (select home_store_id, cust_no, auth_person_id,identification_id, 
   case when REGEXP_SIMILAR(right (left(identification_id,10),4), '[0-9]{4}','c')  = 1 then 2020-right (left(identification_id,10),4) end as age,
   case when REGEXP_SIMILAR(left (right(identification_id,2),1), '[0-9]{1}','c')  = 1 then left (right(identification_id,2),1) end as gender from chnccp_dwh.dw_cust_auth_person ) b
   on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
   where a.date_of_day between '2019-10-24' and '2020-04-23'
   and b.age between 18 and 45
   and b.gender in(0,2,4,6,8)
   group by 1,2,3,4,5
   having sum(a.sell_val_gsp) >0 and sum(a.tunit_qty*a.sell_qty_colli) > 0 and sum(a.sell_val_gsp) / count (distinct a.date_of_day)  between 150 and 400
)with data;


--鱼皮
drop table chnccp_msi_z.ganyu_temp_seg3_fish;
create table chnccp_msi_z.ganyu_temp_seg3_fish
	as(select 3 as prio, 'seg3' as seg_id, a.home_store_id ,a.cust_no,a.auth_person_id, sum(a.sell_val_gsp) as gross_sales, count (distinct a.date_of_day) as visits,sum(a.sell_val_gsp) /sum(a.tunit_qty*a.sell_qty_colli) as avg_price,max(a.date_of_day) as recency from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj  a
inner join chnccp_dwh.dw_art_var_tu  b
	on a.art_no = b.art_no 
	and a.var_tu_key = b.var_tu_key
where a.date_of_day between '2019-10-24' 
	and '2020-04-23'
	and a.wel_ind = 'N' 
	and a.fsd_ind = 'N' 
	and a.deli_ind = 'N' 
	and a.bvs_ind = 'N' 
	and a.pcr_ind = 'N'
	and b.demand_field_domain_id = 603
	and b.pcg_main_cat_id = 401
	and b.pcg_cat_id in (30,40)
group by 1,2,3,4,5
having  sum(a.sell_val_gsp) >0 and sum(a.tunit_qty*a.sell_qty_colli) > 0 and count (distinct a.date_of_day) = 1
) with data;

--奶粉（冲饮类）
drop table chnccp_msi_z.ganyu_temp_seg4_drinks;
create table chnccp_msi_z.ganyu_temp_seg4_drinks
	as(select 4 as prio, 'seg4' as seg_id
,a.home_store_id ,a.cust_no,a.auth_person_id
,sum(a.sell_val_gsp) as gross_sales,count (distinct a.date_of_day) as visits,sum(a.sell_val_gsp) /sum(a.tunit_qty*a.sell_qty_colli) as avg_price,max(a.date_of_day) as recency
from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj  a
inner join chnccp_dwh.dw_art_var_tu  b
	on a.art_no = b.art_no 
	and a.var_tu_key = b.var_tu_key
where a.date_of_day between '2019-10-24' 
	and '2020-04-23'
	and a.wel_ind = 'N' 
	and a.fsd_ind = 'N' 
	and a.deli_ind = 'N' 
	and a.bvs_ind = 'N' 
	and a.pcr_ind = 'N'
	and ((b.demand_field_domain_id = 603 and b.pcg_main_cat_id = 463))
group by 1,2,3,4,5
having sum(a.tunit_qty*a.sell_qty_colli) > 0 and  sum(a.sell_val_gsp)  > 0 
)with data;

--洗涤
drop table chnccp_msi_z.ganyu_temp_seg5_washing;
create table chnccp_msi_z.ganyu_temp_seg5_washing
	as(select 5 as prio, 'seg5' as seg_id
,a.home_store_id ,a.cust_no,a.auth_person_id
,sum(a.sell_val_gsp) as gross_sales,count (distinct a.date_of_day) as visits,sum(a.sell_val_gsp) /sum(a.tunit_qty*a.sell_qty_colli) as avg_price,max(a.date_of_day) as recency
from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj  a
inner join chnccp_dwh.dw_art_var_tu  b
	on a.art_no = b.art_no 
	and a.var_tu_key = b.var_tu_key
where a.date_of_day between '2019-10-24' 
	and '2020-04-23'
	and a.wel_ind = 'N' 
	and a.fsd_ind = 'N' 
	and a.deli_ind = 'N' 
	and a.bvs_ind = 'N' 
	and a.pcr_ind = 'N'
	and b.demand_field_domain_id = 606 and b.pcg_main_cat_id = 487 
group by 1,2,3,4,5
having sum(a.tunit_qty*a.sell_qty_colli) > 0 and  sum(a.sell_val_gsp) > 0 and count (distinct a.date_of_day) = 1
) with data;

--oil(调料)
drop table chnccp_msi_z.ganyu_temp_seg6_source;
create table chnccp_msi_z.ganyu_temp_seg6_source
	as(select 6 as prio, 'seg6' as seg_id
,a.home_store_id ,a.cust_no,a.auth_person_id
,sum(a.sell_val_gsp) as gross_sales,count (distinct a.date_of_day) as visits,sum(a.sell_val_gsp) /sum(a.tunit_qty*a.sell_qty_colli) as avg_price,max(a.date_of_day) as recency
from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj  a
inner join chnccp_dwh.dw_art_var_tu  b
	on a.art_no = b.art_no 
	and a.var_tu_key = b.var_tu_key
where a.date_of_day between '2019-10-24' 
	and '2020-04-23'
	and a.wel_ind = 'N' 
	and a.fsd_ind = 'N' 
	and a.deli_ind = 'N' 
	and a.bvs_ind = 'N' 
	and a.pcr_ind = 'N'
	and b.demand_field_domain_id = 601
	and b.pcg_main_cat_id = 394
	group by 1,2,3,4,5
	having sum(a.tunit_qty*a.sell_qty_colli) > 0 and  sum(a.sell_val_gsp) > 0 and sum(a.sell_val_gsp) /sum(a.tunit_qty*a.sell_qty_colli) between 10 and 20 and count (distinct a.date_of_day) >= 2
		) with data;

--wine(关联)
drop table chnccp_msi_z.ganyu_temp_seg7_corr1;
create table chnccp_msi_z.ganyu_temp_seg7_corr1
	as(select a.art_no, a.var_tu_key, count(a.cust_no) as times, sum(a.sell_val_gsp) as money, sum(a.sell_val_gsp)/sum(a.tunit_qty*a.sell_qty_colli) as avgprice from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj a
join chnccp_msi_z.abby_temp_seg8_wine b
on a.auth_person_id = b.auth_person_id and a.cust_no = b.cust_no and a.home_store_id = b.home_store_id
where a.date_of_day between '2019-04-24' and '2020-04-23'
and a.wel_ind = 'N' 
and a.fsd_ind = 'N' 
and a.deli_ind = 'N' 
and a.bvs_ind = 'N' 
and a.pcr_ind = 'N'
group by 1,2
having sum(a.sell_val_gsp)>0 and sum(a.tunit_qty*a.sell_qty_colli)>0 
)with data;

select top 100 a.mikg_art_no,a.demand_field_domain_id, a.pcg_main_cat_id, a.pcg_main_cat_desc, a.pcg_cat_id, a.pcg_cat_desc, b.money, b.times from chnccp_dwh.dw_art_var_tu a
join chnccp_msi_z.ganyu_temp_seg7_corr1 b
on a.art_no = b.art_no and a.var_tu_key = b.var_tu_key
order by b.money DESC;


drop table chnccp_msi_z.ganyu_temp_seg7_wine;
create table chnccp_msi_z.ganyu_temp_seg7_wine
	as(select 2 as prio, 'seg7' as seg_id
,a.home_store_id ,a.cust_no,a.auth_person_id
,sum(a.sell_val_gsp) as gross_sales,count (distinct a.date_of_day) as visits,sum(a.sell_val_gsp) /sum(a.tunit_qty*a.sell_qty_colli) as avg_price,max(a.date_of_day) as recency
from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj  a
inner join chnccp_dwh.dw_art_var_tu  b
	on a.art_no = b.art_no 
	and a.var_tu_key = b.var_tu_key
where a.date_of_day between '2019-10-24' 
	and '2020-04-23'
	and a.wel_ind = 'N' 
	and a.fsd_ind = 'N' 
	and a.deli_ind = 'N' 
	and a.bvs_ind = 'N' 
	and a.pcr_ind = 'N'
    and (b.demand_field_domain_id = 614 and b.pcg_main_cat_id = 310 and b.pcg_cat_id = 21)
	group by 1,2,3,4,5
	having sum(a.tunit_qty*a.sell_qty_colli) > 0 and  sum(a.sell_val_gsp) > 0
		)with data;


drop table chnccp_msi_z.ganyu_temp_total1;
create table chnccp_msi_z.ganyu_temp_total1
as (
	select	a.*, b.mobile_phone_no 
	from	
	(
	select	a.*
	, row_number() over (Partition by a.home_store_id ,a.cust_no,a.auth_person_id order by a.prio) as row_id 
	from	
	( select * from chnccp_msi_z.ganuyu_temp_seg1
	union select * from chnccp_msi_z.ganyu_temp_seg2_skincare 
	union select * from chnccp_msi_z.ganyu_temp_seg3_fish 
	union  select * from chnccp_msi_z.ganyu_temp_seg4_drinks 
	union  select * from chnccp_msi_z.ganyu_temp_seg5_washing
	union select * from  chnccp_msi_z.ganyu_temp_seg6_source 
	union select * from chnccp_msi_z.ganyu_temp_seg7_wine) a
	) a
	left join  chnccp_dwh.dw_cust_address b
		on a.cust_no = b.cust_no 
		and a.auth_person_id =b.auth_person_id 
		and a.home_store_id = b.home_store_id
	where length( b.mobile_phone_no ) = 11 and a.row_id = 1
) with data;


drop table chnccp_msi_z.ganyu_temp_total;
create table chnccp_msi_z.ganyu_temp_total
as (select a.* from chnccp_msi_z.ganyu_temp_total1 a
	left join chnccp_msi_z.abby_ttl b
	on a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id and a.home_store_id = b.home_store_id
	where b.cust_no is NULL
	) with data;


drop table chnccp_msi_z.ganyu_temp_control;
create table chnccp_msi_z.ganyu_temp_control
as (
select *
from chnccp_msi_z.ganyu_temp_total sample 82081
) with data;


drop table chnccp_msi_z.ganyu_temp_sending;
create table chnccp_msi_z.ganyu_temp_sending
	as (
		select a.* from chnccp_msi_z.ganyu_temp_total a
		left join chnccp_msi_z.ganyu_temp_control b
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		where b.cust_no is NULL	)with data;



--check:
seg_id: seg_id
cust: number of customers
spend: price every time for shopping
visits: average of visits
price: average of price of goods(quantity)
interval_1: days between today and last time of shopping -> (today-recency) to be days


select seg_id, count(cust_no) as cust, sum(gross_sales)/count(visits) as spend, avg(visits) as visits,avg(avg_price) as price,avg((DATE'2020-04-23' - recency)day(4)) as interval_1 from chnccp_msi_z.ganyu_temp_control
group by 1 order by 1;
select seg_id, count(cust_no) as cust, sum(gross_sales)/count(visits) as spend, avg(visits) as visits,avg(avg_price) as price,avg((DATE'2020-04-23' - recency)day(4)) as interval_1 from chnccp_msi_z.ganyu_temp_sending
group by 1 order by 1;


select home_store_id, cust_no, auth_person_id, mobile_phone_no from chnccp_msi_z.ganyu_temp_sending where seg_id = 'seg1';



--------------------------------------------------------------------group3-----------------------------------------------------
drop table chnccp_msi_z.ganyu_temp_group3;
create table chnccp_msi_z.ganyu_temp_group3
as (
select a.home_store_id, a.cust_no, a.auth_person_id, sum(a.sell_val_gsp) as gross_sales, 
   count (distinct a.date_of_day) as visits,sum(a.sell_val_gsp) /sum(a.tunit_qty*a.sell_qty_colli) as avg_price,max(a.date_of_day) as recency from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj a
   where a.date_of_day between '2020-01-24' and '2020-04-23'
   	and a.wel_ind = 'N'
	and a.fsd_ind = 'N'
    and a.deli_ind = 'N'
    and a.bvs_ind = 'N' 
    and a.pcr_ind = 'N'
    group by 1,2,3
    having sum(a.tunit_qty*a.sell_qty_colli) >0 and sum(a.sell_val_gsp)>0
) with data;


drop table chnccp_msi_z.ganyu_temp_group3_l1;
create table chnccp_msi_z.ganyu_temp_group3_l1
	as(select a.* from chnccp_msi_z.ganyu_temp_group3 a
		left join chnccp_msi_z.abby_ttl b
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		where b.cust_no is NULL)with data;


drop table chnccp_msi_z.ganyu_temp_group3_l2;
create table chnccp_msi_z.ganyu_temp_group3_l2
	as(select a.* from chnccp_msi_z.ganyu_temp_group3_l1 a
		left join chnccp_msi_z.ganyu_temp_total b
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		where b.cust_no is NULL)with data;


select 
CASE 
WHEN gross_sales/visits between 0 and 100 THEN '0-100'
WHEN gross_sales/visits between 100 and 200 THEN '100-200'
WHEN gross_sales/visits between 200 and 300 THEN '200-300'
WHEN gross_sales/visits between 300 and 400 THEN '300-400'
WHEN gross_sales/visits between 400 and 1000 THEN '400-1000'
ELSE '>1000' END as range, 
count(gross_sales/visits) as people 
from chnccp_msi_z.ganyu_temp_group3_l2
group by 1;

