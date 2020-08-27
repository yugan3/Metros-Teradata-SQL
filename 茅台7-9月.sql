drop table chnccp_msi_z.abby_moutai_qualified1;
create table chnccp_msi_z.abby_moutai_qualified1
as (
	select a.home_store_id,a.cust_no,a.auth_person_id
	,count(distinct a.month_id) as monthly_visit
	,sum(a.sell_val_gsp) as spending
	from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj  a
	where a.wel_ind = 'N' and a.deli_ind = 'N' and a.bvs_ind = 'N' 
	and home_store_id in (10, 17, 12, 198, 173, 44, 139, 229, 70, 74, 13, 142, 42, 125, 50)
	and a.month_id in (202004,202005,202006)
	group by 1,2,3
	having count(distinct a.month_id) = 3 and sum(a.sell_val_gsp) >= 3000
) with data;

drop table chnccp_msi_z.abby_moutai_earlybird1;
create table chnccp_msi_z.abby_moutai_earlybird1
as (
	select a.home_store_id,a.cust_no,a.auth_person_id
	,count(distinct a.month_id) as monthly_visit
	,sum(a.sell_val_gsp) as spending
	from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj  a
	left join chnccp_msi_z.abby_moutai_qualified1 b
	on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
	where a.wel_ind = 'N' and a.deli_ind = 'N' and a.bvs_ind = 'N' 
	and a.home_store_id in (10, 17, 12, 198, 173, 44, 139, 229, 70, 74, 13, 142, 42, 125, 50)
	and a.month_id in (202005,202006)
    and b.home_store_id is null
	group by 1,2,3
	having count(distinct a.month_id) = 2 
) with data;

drop table  chnccp_msi_z.abby_moutai_qualified2;
create table chnccp_msi_z.abby_moutai_qualified2
as (
	select distinct a.home_store_id,a.cust_no,a.auth_person_id,b.base_points,c.loy_mem_num_available_pts 
	from chnccp_dwh.dw_mcrm_loy_member a
	inner join (
		select a.loy_mem_row_id,SUM(CASE WHEN a.loy_pts_item_qty IS NULL THEN a.loy_item_num_trans_pts END) as base_points
		from chnccp_dwh.dw_mcrm_loy_pts_items a
		where  loy_pts_item_trans_date between '2019-07-01' and '2020-06-30'
		and loy_pts_item_prom_id='4-B0R7EYGJ' 
		group by 1
		having SUM(CASE WHEN a.loy_pts_item_qty IS NULL THEN a.loy_item_num_trans_pts END)  >= 100
	) b
	on a.loy_mem_row_id = b.loy_mem_row_id
	inner join chnccp_dwh.dw_mcrm_loy_mem_balance c
	on a.loy_mem_row_id = c.loy_mem_row_id
	where a.home_store_id in (10, 17, 12, 198, 173, 44, 139, 229, 70, 74, 13, 142, 42, 125, 50)
	and a.loy_mem_parent_ind = 0
	and loy_mem_num_available_pts >= 100
) with data;

drop table  chnccp_msi_z.abby_moutai_early2;
create table chnccp_msi_z.abby_moutai_early2
as (
	select a.home_store_id,a.cust_no,a.auth_person_id,b.base_points,c.loy_mem_num_available_pts 
	from chnccp_dwh.dw_mcrm_loy_member a
	inner join (
		select a.loy_mem_row_id,SUM(CASE WHEN a.loy_pts_item_qty IS NULL THEN a.loy_item_num_trans_pts END) as base_points
		from chnccp_dwh.dw_mcrm_loy_pts_items a
		where  loy_pts_item_trans_date between '2019-07-01' and '2020-06-30'
		and loy_pts_item_prom_id='4-B0R7EYGJ' 
		group by 1
		having SUM(CASE WHEN a.loy_pts_item_qty IS NULL THEN a.loy_item_num_trans_pts END)  >= 50
	) b
	on a.loy_mem_row_id = b.loy_mem_row_id
	inner join chnccp_dwh.dw_mcrm_loy_mem_balance c
	on a.loy_mem_row_id = c.loy_mem_row_id
	left join chnccp_msi_z.abby_moutai_qualified2 d
	on a.home_store_id = d.home_store_id and a.cust_no =d.cust_no and a.auth_person_id = d.auth_person_id
	where a.home_store_id in (10, 17, 12, 198, 173, 44, 139, 229, 70, 74, 13, 142, 42, 125, 50)
	and c.loy_mem_num_available_pts >= 50
	and d.home_store_id is null
) with data;

------------------------------------
------------------------------------
------------------------------------
create table chnccp_msi_z.abby_moutai_qualified2
as (
	select distinct a.home_store_id,a.cust_no,a.auth_person_id,
	--b.base_points,
	c.loy_mem_num_available_pts 
	from chnccp_dwh.dw_mcrm_loy_member a
	/*inner join (
		select a.loy_mem_row_id,SUM(CASE WHEN a.loy_pts_item_qty IS NULL THEN a.loy_item_num_trans_pts END) as base_points
		from chnccp_dwh.dw_mcrm_loy_pts_items a
		where  loy_pts_item_trans_date between '2019-07-01' and '2020-06-30'
		and loy_pts_item_prom_id='4-B0R7EYGJ' 
		group by 1
		having SUM(CASE WHEN a.loy_pts_item_qty IS NULL THEN a.loy_item_num_trans_pts END)  >= 100
	) b
	on a.loy_mem_row_id = b.loy_mem_row_id*/
	inner join chnccp_dwh.dw_mcrm_loy_mem_balance c
	on a.loy_mem_row_id = c.loy_mem_row_id
	where a.home_store_id in (10, 17, 12, 198, 173, 44, 139, 229, 70, 74, 13, 142, 42, 125, 50)
	and a.loy_mem_parent_ind = 0
	and loy_mem_num_available_pts >= 100
) with data;

drop table  chnccp_msi_z.abby_moutai_early2;
create table chnccp_msi_z.abby_moutai_early2
as (
	select a.home_store_id,a.cust_no,a.auth_person_id,
	--b.base_points,
	c.loy_mem_num_available_pts 
	from chnccp_dwh.dw_mcrm_loy_member a
	/*inner join (
		select a.loy_mem_row_id,SUM(CASE WHEN a.loy_pts_item_qty IS NULL THEN a.loy_item_num_trans_pts END) as base_points
		from chnccp_dwh.dw_mcrm_loy_pts_items a
		where  loy_pts_item_trans_date between '2019-07-01' and '2020-06-30'
		and loy_pts_item_prom_id='4-B0R7EYGJ' 
		group by 1
		having SUM(CASE WHEN a.loy_pts_item_qty IS NULL THEN a.loy_item_num_trans_pts END)  >= 50
	) b
	on a.loy_mem_row_id = b.loy_mem_row_id*/
	inner join chnccp_dwh.dw_mcrm_loy_mem_balance c
	on a.loy_mem_row_id = c.loy_mem_row_id
	left join chnccp_msi_z.abby_moutai_qualified2 d
	on a.home_store_id = d.home_store_id and a.cust_no =d.cust_no and a.auth_person_id = d.auth_person_id
	where a.home_store_id in (10, 17, 12, 198, 173, 44, 139, 229, 70, 74, 13, 142, 42, 125, 50)
	and c.loy_mem_num_available_pts >= 50
	and d.home_store_id is null
) with data;

select store_desc_simp, first_10shops, abc, lp, recency, frequency, UMCpotential, HTS, mobile, identification, union_id, open_id
,case when b.home_store_id is not null then 'qualified' 
            when c.home_store_id is not null then 'early bird' else 'others'end as sales_qualified
,case when d.home_store_id is not null then 'qualified' 
            when e.home_store_id is not null then 'early bird' else 'others'end as points_qualified
, count(distinct a.home_store_id||a.cust_no||a.auth_person_id) as people 
from chnccp_msi_z.maotai_1 a
left join chnccp_msi_z.abby_moutai_qualified1 b
on a.home_store_id =b.home_store_id and a.cust_no =b.cust_no and a.auth_person_id = b.auth_person_id
left join chnccp_msi_z.abby_moutai_earlybird1 c
on a.home_store_id =c.home_store_id and a.cust_no =c.cust_no and a.auth_person_id = c.auth_person_id
left join chnccp_msi_z.abby_moutai_qualified2  d
on a.home_store_id =d.home_store_id and a.cust_no =d.cust_no and a.auth_person_id = d.auth_person_id
left join chnccp_msi_z.abby_moutai_early2 e
on a.home_store_id =e.home_store_id and a.cust_no =e.cust_no and a.auth_person_id = e.auth_person_id
group by store_desc_simp, first_10shops, abc, lp, recency, frequency, UMCpotential, HTS, mobile, identification, union_id, open_id,sales_qualified,points_qualified
order by store_desc_simp, first_10shops, abc, lp, recency, frequency, UMCpotential, HTS, mobile, identification, union_id, open_id,sales_qualified,points_qualified;

----------------100分积分以上
select a.home_store_id, b.store_desc, count(distinct a.home_store_id||a.cust_no||a.auth_person_id) as buyer from chnccp_dwh.dw_mcrm_loy_member a
join chnccp_dwh.dw_mcrm_loy_mem_balance c
on a.loy_mem_row_id = c.loy_mem_row_id
join  chnccp_msi_d.vy_ref_store2015 b 
on a.home_store_id = b.store_id_mdw
join chnccp_dwh.dw_customer d
on a.home_store_id = d.home_store_id and a.cust_no = d.cust_no
where a.home_store_id in (10, 17, 12, 198, 173, 44, 139, 229, 70, 74, 13, 142, 42, 125, 50)
and a.loy_mem_parent_ind = 0
and c.loy_mem_num_available_pts >= 100
and d.branch_id not in (971, 973)
group by b.store_desc, a.home_store_id
order by a.home_store_id, b.store_desc;



-------------------------------------------------------activity namelist
--points
-->=100 points
drop table chnccp_msi_z.maotai_100points;
create table chnccp_msi_z.maotai_100points
	as(select a.home_store_id, a.cust_no, a.auth_person_id, b.loy_mem_num_available_pts,
		count(distinct month_id) as months, count(distinct orig_invoice_id) as invoices,
		sum (e.sell_val_nsp - e.sell_val_nnbp)/sum(e.sell_val_nsp) as front_margin, 
		count(distinct f.pcg_cat_id) as category
		from chnccp_dwh.dw_mcrm_loy_member a
		join chnccp_dwh.dw_mcrm_loy_mem_balance b
		on a.loy_mem_row_id = b.loy_mem_row_id
		join chnccp_dwh.dw_customer c
		on a.home_store_id = c.home_store_id and a.cust_no = c.cust_no
		join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj e
		on e.home_store_id = a.home_store_id and e.cust_no = a.cust_no and e.auth_person_id = a.auth_person_id
		join chnccp_dwh.dw_art_var_tu f 
		on f.var_tu_key = e.var_tu_key and f.art_no = e.art_no
		where a.home_store_id in (10,17,12,198,44,70,74,13,125,50)
		and a.loy_mem_parent_ind = 0
		and b.loy_mem_num_available_pts >= 100
		and c.branch_id not in (971,973)
		and e.date_of_day between '2020-02-19' and '2020-08-18'
		group by a.home_store_id, a.cust_no, a.auth_person_id, b.loy_mem_num_available_pts
		having sum(e.sell_val_nsp) > 0
		)with data;

drop table chnccp_msi_z.maotai_blacknamelist;
create table chnccp_msi_z.maotai_blacknamelist
	as(
		select a.* from 
			(
				(select * from chnccp_msi_z.maotai_100points
					where front_margin < 0.05
					)
				union
				(select * from chnccp_msi_z.maotai_100points
					where category < 3
					)
				union
				(select * from chnccp_msi_z.maotai_100points
					where months < 3
					)
			) a
		)with data;

--blacknamelist
--select * from chnccp_msi_z.maotai_blacknamelist;

drop table chnccp_msi_z.maotai_whitenamelist;
create table chnccp_msi_z.maotai_whitenamelist
	as(select a.home_store_id, a.cust_no, a.auth_person_id, a.loy_mem_num_available_pts, '2020-08-18' as last_day from chnccp_msi_z.maotai_100points a 
		left join chnccp_msi_z.maotai_blacknamelist b 
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		where b.cust_no is NULL
		)with data;

select * from chnccp_msi_z.maotai_whitenamelist;

/*drop table chnccp_msi_z.maotai_100points_1;
create table chnccp_msi_z.maotai_100points_1
	as(select * from chnccp_msi_z.maotai_100points_1
		where months in (1,2)
		)with data;
select count(1) from chnccp_msi_z.maotai_100points_1;

drop table chnccp_msi_z.maotai_100points_2;
create table chnccp_msi_z.maotai_100points_2
	as(select a.* from chnccp_msi_z.maotai_100points a
		left join chnccp_msi_z.maotai_100points_1 b 
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		)with data;
select count(1) from chnccp_msi_z.maotai_100points_2 where front_margin < 0.05;

drop table chnccp_msi_z.maotai_100points_3;
create table chnccp_msi_z.maotai_100points_3
	as(select a.* from chnccp_msi_z.maotai_100points_2 a 
		where front_margin >= 0.05
		)with data;*/


--[50,100) points
/*drop table chnccp_msi_z.maotai_50points;
create table chnccp_msi_z.maotai_50points
	as(select distinct a.home_store_id, a.cust_no, a.auth_person_id from chnccp_dwh.dw_mcrm_loy_member a
		join chnccp_dwh.dw_mcrm_loy_mem_balance c 
		on a.loy_mem_row_id = c.loy_mem_row_id
		join chnccp_dwh.dw_customer d
		on a.home_store_id = d.home_store_id and a.cust_no = d.cust_no
		where a.home_store_id in (10,17,12,198,44,70,74,13,125,50)
		and a.loy_mem_parent_ind = 0
		and (c.loy_mem_num_available_pts >= 50 and c.loy_mem_num_available_pts < 100)
		and d.branch_id not in (971,973)
		)with data;*/

--SMS
drop table chnccp_msi_z.maotai_100points_mobile;
create table chnccp_msi_z.maotai_100points_mobile
	as(select a.home_store_id, a.cust_no, a.auth_person_id, b.mobile_phone_no from chnccp_msi_z.maotai_whitenamelist a 
		left join chnccp_dwh.dw_cust_address b 
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		where length(b.mobile_phone_no) = 11
		)with data;


-----------
--pool
drop table chnccp_msi_z.maotai_namelist_Feb_to_July_1;
create table chnccp_msi_z.maotai_namelist_Feb_to_July_1
	as(select home_store_id, cust_no, auth_person_id, month_id from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj
		where date_of_day between '2020-02-01' and '2020-07-27'
		group by home_store_id, cust_no, auth_person_id, month_id
		having sum(sell_val_gsp) > 0
		)with data;

drop table chnccp_msi_z.maotai_namelist_Feb_to_July_2;
create table chnccp_msi_z.maotai_namelist_Feb_to_July_2
	as(select home_store_id, cust_no, auth_person_id,
		CASE WHEN month_id = 202002 THEN 1 ELSE 0 END as feb,
		CASE WHEN month_id = 202003 THEN 1 ELSE 0 END as march, 
		CASE WHEN month_id = 202004 THEN 1 ELSE 0 END as april,
		CASE WHEN month_id = 202005 THEN 1 ELSE 0 END as may,
		CASE WHEN month_id = 202006 THEN 1 ELSE 0 END as june,
		CASE WHEN month_id = 202007 THEN 1 ELSE 0 END as july 
		from chnccp_msi_z.maotai_namelist_Feb_to_July_1
		)with data;

drop table chnccp_msi_z.maotai_namelist_Feb_to_July;
create table chnccp_msi_z.maotai_namelist_Feb_to_July
as(
	select home_store_id, cust_no, auth_person_id,
	sum(feb) as feb, sum(march) as march, sum(april) as april,
	sum(may) as may, sum(june) as june, sum(july) as july
	from chnccp_msi_z.maotai_namelist_Feb_to_July_2
	group by home_store_id, cust_no, auth_person_id
	)with data;

select count(1), count(distinct home_store_id||cust_no||auth_person_id) from chnccp_msi_z.maotai_namelist_Feb_to_July;




--python
select tt.home_store_id, tt.cust_no, tt.auth_person_id, 
	sum(tt.feb) as feb, sum(tt.march) as march, sum(tt.april) as april,
	sum(tt.may) as may, sum(tt.june) as june, sum(tt.july) as july
	from 
(select a.home_store_id, a.cust_no, a.auth_person_id,
		CASE WHEN a.month_id = 202002 THEN 1 ELSE 0 END as feb,
		CASE WHEN a.month_id = 202003 THEN 1 ELSE 0 END as march, 
		CASE WHEN a.month_id = 202004 THEN 1 ELSE 0 END as april,
		CASE WHEN a.month_id = 202005 THEN 1 ELSE 0 END as may,
		CASE WHEN a.month_id = 202006 THEN 1 ELSE 0 END as june,
		CASE WHEN a.month_id = 202007 THEN 1 ELSE 0 END as july from 
(select home_store_id, cust_no, auth_person_id, month_id from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj
		where date_of_day between '2020-02-01' and '2020-07-31'
		group by home_store_id, cust_no, auth_person_id, month_id
		having sum(sell_val_gsp) > 0
		) a ) tt
group by tt.home_store_id, tt.cust_no, tt.auth_person_id;



--test:200000
select * from chnccp_msi_z.maotai_test;

insert into maotai_namelist_2and7 values(10, 911640,1,1,1,1,0,0,1);
insert into maotai_namelist_2and7 values(10, 911787,1,1,1,1,0,0,1);
insert into maotai_namelist_2and7 values(10, 911846,1,1,0,1,0,0,1);
insert into maotai_namelist_2and7 values(10, 901337,1,1,1,1,1,1,1);
insert into maotai_namelist_2and7 values(10, 911998,1,0,1,1,0,0,1);
insert into maotai_namelist_2and7 values(10, 914372,1,1,0,0,0,0,1);
insert into maotai_namelist_2and7 values(10, 914135,1,1,0,1,0,0,1);


--上传75数据库
create table maotai_namelist_2and7
	(home_store_id DECIMAL(5,0),
	cust_no DECIMAL(8,0),
	auth_person_id DECIMAL(2,0),
	feb INTEGER,
	march INTEGER,
	april INTEGER,
	may INTEGER,
	june INTEGER,
	july INTEGER);

create table maotai_namelist_8
	(home_store_id DECIMAL(5,0),
	cust_no DECIMAL(8,0),
	auth_person_id DECIMAL(2,0));

--posting
drop table chnccp_msi_z.maotai_posting;
create table chnccp_msi_z.maotai_posting
	as(
		select a.home_store_id, a.cust_no, a.auth_person_id, b.loy_mem_num_available_pts 
		from (select distinct home_store_id, cust_no, auth_person_id 
			from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj where date_of_day between '2019-08-27' and '2020-07-28'
			and home_store_id in (10,17,12,198,44,70,74,13,125,50) and store_id in (10,17,12,198,44,70,74,13,125,50)) a
		join chnccp_dwh.dw_mcrm_loy_member t 
		on t.home_store_id = a.home_store_id and t.cust_no = a.cust_no and a.auth_person_id = t.auth_person_id
		join chnccp_dwh.dw_mcrm_loy_mem_balance b
		on t.loy_mem_row_id = b.loy_mem_row_id
		where t.loy_mem_parent_ind = 0
		)with data;

drop table chnccp_msi_z.maotai_posting_1;
create table chnccp_msi_z.maotai_posting_1
	as(select home_store_id, cust_no, auth_person_id, loy_mem_num_available_pts,
		CASE WHEN loy_mem_num_available_pts > 0 and loy_mem_num_available_pts < 10 THEN '(0,10)'
			 WHEN loy_mem_num_available_pts >= 10 and loy_mem_num_available_pts < 20 THEN '[10,20)'
			 WHEN loy_mem_num_available_pts >= 20 and loy_mem_num_available_pts < 50 THEN '[20, 50)'
			 WHEN loy_mem_num_available_pts >= 50 and loy_mem_num_available_pts < 75 THEN '[50,75)'
			 WHEN loy_mem_num_available_pts >= 75 and loy_mem_num_available_pts <= 100 THEN '[75,100)'
			 WHEN loy_mem_num_available_pts >= 100 THEN '[100,+)'
			 ELSE 'others' END as groups from chnccp_msi_z.maotai_posting
		)with data;


-- >= 3 months
create table maotai_10
	as(select home_store_id, cust_no, auth_person_id, (feb+march+april+may+june+july) as times from  maotai_namelist_2and7
		);

select count(1) from maotai_10
where home_store_id in (10,17,12,198,44,70,74,13,125,50) and times >= 3;


select count(1) from maotai_10
where home_store_id in (10,17,12,198,173,44,139,229,70,74,13,142,42,125,50) and times >= 3;

--SMS
drop table chnccp_msi_z.maotai_sms_namelist;
create table chnccp_msi_z.maotai_sms_namelist
	as( select fazz.home_store_id, fazz.cust_no, fazz.auth_person_id from
		(select tt.home_store_id, tt.cust_no, tt.auth_person_id from 
		((select a.home_store_id, a.cust_no, a.auth_person_id from chnccp_dwh.dw_mcrm_loy_member a
		join chnccp_dwh.dw_mcrm_loy_mem_balance c
		on a.loy_mem_row_id = c.loy_mem_row_id
		join (select distinct home_store_id, cust_no, auth_person_id from chnccp_crm.frank_paid_member_dashboard_cust_2 ) b 
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		where c.loy_mem_num_available_pts >= 50
		and a.loy_mem_parent_ind = 0)
		union
		(select a.home_store_id, a.cust_no, a.auth_person_id from chnccp_dwh.dw_mcrm_loy_member a
		join chnccp_dwh.dw_mcrm_loy_mem_balance c
		on a.loy_mem_row_id = c.loy_mem_row_id
		where c.loy_mem_num_available_pts >= 70
		and a.loy_mem_parent_ind = 0) )tt
		)fazz 
		join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj c 
		on c.home_store_id = fazz.home_store_id and c.cust_no = fazz.cust_no and c.auth_person_id =  fazz.auth_person_id
		where c.month_id in(202002, 202003, 202004, 202005, 202006, 202007)
		and fazz.home_store_id in (10,17,12,198,173,44,139,229,70,74,13,142,42,125,50)
		and c.store_id in (10,17,12,198,173,44,139,229,70,74,13,142,42,125,50)
		group by fazz.home_store_id, fazz.cust_no, fazz.auth_person_id
		having count(distinct c.month_id) >= 3 )with data;


drop table chnccp_msi_z.maotai_sms_namelist_output;
create table chnccp_msi_z.maotai_sms_namelist_output
	as(select tt.home_store_id, tt.cust_no, tt.auth_person_id, c.mobile_phone_no from
		(select a.home_store_id, a.cust_no, a.auth_person_id from chnccp_msi_z.maotai_sms_namelist a 
			left join chnccp_msi_z.maotai_blacknamelist_total b 
			on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
			where b.cust_no is null ) tt
		left join chnccp_dwh.dw_cust_address c 
		on tt.home_store_id = c.home_store_id and tt.cust_no = c.cust_no and tt.auth_person_id = c.auth_person_id
		where length(c.mobile_phone_no) = 11
		)with data;

--收集的所有黑名单
chnccp_msi_z.maotai_blacknamelist_total

drop table chnccp_msi_z.maotai_sms_namelist_output_1;
create table chnccp_msi_z.maotai_sms_namelist_output_1
	as(select * from chnccp_msi_z.maotai_sms_namelist_output sample 7600 )with data;

drop table chnccp_msi_z.maotai_sms_namelist_output_2;
create table chnccp_msi_z.maotai_sms_namelist_output_2
	as( select tt.* from 
		(select a.* from chnccp_msi_z.maotai_sms_namelist_output a 
			left join chnccp_msi_z.maotai_sms_namelist_output_1 b 
			on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
			where b.cust_no is null	) tt 
		    sample 7600	)with data;

drop table chnccp_msi_z.maotai_sms_namelist_output_3;
create table chnccp_msi_z.maotai_sms_namelist_output_3
	as(select tt.* from chnccp_msi_z.maotai_sms_namelist_output tt
		left join chnccp_msi_z.maotai_sms_namelist_output_1 a 
		on a.home_store_id = tt.home_store_id and a.cust_no = tt.cust_no and a.auth_person_id = tt.auth_person_id
		left join chnccp_msi_z.maotai_sms_namelist_output_2 b 
		on tt.home_store_id = b.home_store_id and tt.cust_no = b.cust_no and tt.auth_person_id = b.auth_person_id
		where a.home_store_id is null
		and b.cust_no is null
		)with data;


--------evolve
drop table moutai;
create table moutai as (
select o.id, t.created_at::timestamp without time zone, t.buyer_id,
        i.title as art_name, o.payment/100 as sales, o.num as qty, t.status,
        b.coupon_status, b.use_store, (TIMESTAMP WITHOUT TIME ZONE 'epoch' + b.redeem_time * INTERVAL '1 second') as redeem_time
        from eorder.trades t
        left join eorder.orders o
        on t.id  = o.trade_id
        left join eproduct.items i
        on o.item_id=i.id
        left join eproduct.skus s 
        on o.sku_id=s.id
        left join coupon_data.couponlist b
        on o.id = b.trade_no
        where t.app_id = 'flashsale-moutai');

select date(tt.redeem_time) as dates, tt.use_store, sum(tt.qty) as redeem_qty, count(distinct tt.buyer_id) as redeem_cust from
moutai tt
where date(tt.redeem_time) between '2020-08-05' and '2020-08-13'
group by date(tt.redeem_time), tt.use_store
order by date(tt.redeem_time), tt.use_store;
/*
select  o.id, t.created_at::timestamp without time zone, t.buyer_id, 
        i.title as art_name, o.payment/100 as sales, o.num as qty, t.status, t.app_id,
        p.coupon_status, p.use_store, (TIMESTAMP WITHOUT TIME ZONE 'epoch' + p.redeem_time * INTERVAL '1 second') as redeem_time
        from eorder.trades t
        left join eorder.orders o
        on t.id  = o.trade_id
        left join eproduct.items i
        on o.item_id=i.id
        left join eproduct.skus s 
        on o.sku_id=s.id
        left join coupon_data.couponlist p
        on o.id = p.trade_no
        where t.app_id = 'flashsale-moutai' limit 10;

select TIMESTAMP WITHOUT TIME ZONE 'epoch' + 1596954877 * INTERVAL '1 second';
*/

select a.date_of_day, a.store_id, sum(a.sell_qty_colli) as qty, count(distinct a.home_store_id||a.cust_no||a.auth_person_id) as buyer 
from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj a 
join chnccp_dwh.dw_art_var_tu b 
on a.var_tu_key = b.var_tu_key and a.art_no = b.art_no
where a.date_of_day = '2020-08-19'
and b.mikg_art_no = 150619
and a.store_id in (10,17,12,198,44,70,74,13,125,50)
group by a.date_of_day, a.store_id
order by a.date_of_day, a.store_id;




select store_id,sum(a.sell_qty_colli) as qty, count(distinct a.home_store_id||a.cust_no||a.auth_person_id) as buyer from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj a 
join chnccp_dwh.dw_art_var_tu b 
on a.var_tu_key = b.var_tu_key and a.art_no = b.art_no
where a.date_of_day between '2020-08-05'and '2020-08-17'
and b.mikg_art_no = 150619
and a.store_id in (10,17,12,198,44,70,74,13,125,50)
group by store_id
order by store_id;

--postgresql
--select
select date(tt.redeem_time) as dates, tt.use_store, sum(tt.qty) as redeem_qty, count(distinct tt.buyer_id) as redeem_cust from
 (select o.id, t.created_at::timestamp without time zone, t.buyer_id,
        i.title as art_name, o.payment/100 as sales, o.num as qty, t.status,
        b.coupon_status, b.use_store, (TIMESTAMP WITHOUT TIME ZONE 'epoch' + b.redeem_time * INTERVAL '1 second') as redeem_time
        from eorder.trades t
        left join eorder.orders o
        on t.id  = o.trade_id
        left join eproduct.items i
        on o.item_id=i.id
        left join eproduct.skus s 
        on o.sku_id=s.id
        left join coupon_data.couponlist b
        on o.id = b.trade_no
        where t.app_id = 'flashsale-moutai') tt
where date(tt.redeem_time) between '2020-08-05' and current_date - 1
group by date(tt.redeem_time), tt.use_store
order by date(tt.redeem_time), tt.use_store;

--view
drop view moutai_redeem;
create view moutai_redeem as 
select date(tt.redeem_time) as dates, tt.store_id, tt.use_store as pickup_store, sum(tt.qty) as quantity, count(distinct tt.buyer_id) as customer from
 (select t.buyer_id, o.num as qty, z.store_id, b.use_store, (TIMESTAMP WITHOUT TIME ZONE 'epoch' + b.redeem_time * INTERVAL '1 second') as redeem_time
        from eorder.trades t
        left join eorder.orders o
        on t.id  = o.trade_id
        left join eproduct.items i
        on o.item_id=i.id
        left join eproduct.skus s 
        on o.sku_id=s.id
        left join coupon_data.couponlist b
        on o.id = b.trade_no
        left join store_id z 
        on z.store_name = b.use_store
        where t.app_id = 'flashsale-moutai') tt
where date(tt.redeem_time) between '2020-08-05' and current_date - 1
group by date(tt.redeem_time), tt.store_id, tt.use_store
order by date(tt.redeem_time), tt.store_id, tt.use_store;

select dates, store_id, quantity from moutai_redeem
where dates between '2020-08-21' and '2020-08-23'
order by dates, store_id;




mp_maotaiIndex_view
mp_entranceindex_tomaotai_click 

select distinct tt.store_id, tt.use_store from 
(select t.buyer_id, o.num as qty, z.store_id, b.use_store, (TIMESTAMP WITHOUT TIME ZONE 'epoch' + b.redeem_time * INTERVAL '1 second') as redeem_time
        from eorder.trades t
        left join eorder.orders o
        on t.id  = o.trade_id
        left join eproduct.items i
        on o.item_id=i.id
        left join eproduct.skus s 
        on o.sku_id=s.id
        left join coupon_data.couponlist b
        on o.id = b.trade_no
        left join store_id z 
        on z.store_name = b.use_store
        where t.app_id = 'flashsale-moutai') tt;

-----茅台页面uv漏斗

/*
--1.到页面/2.到按钮
select event,date(fromat) as dates, count(distinct home_store_id|cust_no|auth_person_id) as uv from maotai_uv
group by event, date(fromat)
order by event, date(fromat);

--3.参与抢购
select order_type,  date(created_at::timestamp without time zone) as dates, count(distinct buyer_id) as buyer from flash_sale_order
where order_type = 'flashsale-moutai'
group by order_type, date(created_at::timestamp without time zone)
order by order_type, date(created_at::timestamp without time zone);

--4.兑换
select date(tt.redeem_time) as dates, sum(tt.qty) as qty, count(distinct tt.buyer_id) as cust from
 (select o.id, t.created_at::timestamp without time zone, t.buyer_id,
        i.title as art_name, o.payment/100 as sales, o.num as qty, t.status,
        b.coupon_status, b.use_store, (TIMESTAMP WITHOUT TIME ZONE 'epoch' + b.redeem_time * INTERVAL '1 second') as redeem_time
        from eorder.trades t
        left join eorder.orders o
        on t.id = o.trade_id
        left join eproduct.items i
        on o.item_id = i.id
        left join eproduct.skus s 
        on o.sku_id = s.id
        left join coupon_data.couponlist b
        on o.id = b.trade_no
        where t.app_id = 'flashsale-moutai') tt
group by date(tt.redeem_time)
order by date(tt.redeem_time);
*/


--75database:uv check
select distinct date(fromat) as fromat, storekey as home_store_id, custkey as cust_no, cardholderkey as auth_person_id, event, paidmember as plus from mptrack.kpi
where event in ('mp_maotaiIndex_view', 'mp_entranceindex_tomaotai_click')
and date(fromat) between '2020-08-05' and current_date -1;

select date(fromat) as fromat, count(distinct storekey|custkey|cardholderkey) as uv from mptrack.kpi
where event = 'mp_maotaiIndex_view'
group by date(fromat)
order by date(fromat);





-------------------------------------------------------------------------------------------------------------------------------------------------
--teradata
--maotai uv
--linux automatic running
drop table chnccp_msi_z.maotai_uv;
create table chnccp_msi_z.maotai_uv
	(fromat date,
	store_id VARCHAR(48),
	home_store_id INTEGER,
	cust_no INTEGER,
	auth_person_id INTEGER,
	event VARCHAR(48),
	plus VARCHAR(200)
		);


--part1
-------page uv
--first 10 shops
select fromat, store_id, home_store_id, count(distinct home_store_id||cust_no||auth_person_id) as uv from chnccp_msi_z.maotai_uv
where fromat between '2020-08-05' and '2020-08-20' and event = ''mp_maotaiIndex_view''
and home_store_id in (10,17,12,198,44,70,74,13,125,50)
group by fromat, store_id, home_store_id;
order by fromat, store_id, home_store_id;

--new 15 shops
select fromat, store_id, count(distinct home_store_id||cust_no||auth_person_id) as uv from chnccp_msi_z.maotai_uv
where fromat between '2020-08-21' and '2020-08-25'
and home_store_id in (10, 17, 12, 198, 173, 44, 139, 229, 70, 74, 13, 142, 42, 125, 50)
group by fromat, store_id, home_store_id
order by fromat, store_id, home_store_id;

--------qualified uv
--first 10 shops
select tt.fromat, tt.store_id, tt.home_store_id, count(distinct tt.home_store_id||tt.cust_no||tt.auth_person_id) as qualified_uv from 
(
(select distinct a.fromat, a.store_id, a.home_store_id, a.cust_no, a.auth_person_id from chnccp_msi_z.maotai_uv a 
where a.event = 'mp_entranceindex_tomaotai_click'
and a.home_store_id in (10,17,12,198,44,70,74,13,125,50)
and a.fromat between '2020-08-05' and '2020-08-20')
union
(select distinct a.fromat, a.store_id, a.home_store_id, a.cust_no, a.auth_person_id from chnccp_msi_z.maotai_uv a 
left join chnccp_msi_z.points_100_not_recorded b 
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id and a.fromat = b.points_date
where a.event = 'mp_maotaiIndex_view'
and a.home_store_id in (10,17,12,198,44,70,74,13,125,50)
and a.fromat between '2020-08-05' and '2020-08-20'
and b.cust_no is null)
) tt
group by tt.fromat, tt.home_store_id, tt.store_id
order by tt.fromat, tt.home_store_id, tt.store_id;

--new 15 shops
select tt.fromat, tt.store_id, tt.home_store_id, count(distinct tt.home_store_id||tt.cust_no||tt.auth_person_id) as qualified_uv from 
(
(select distinct a.fromat, a.store_id, a.home_store_id, a.cust_no, a.auth_person_id from chnccp_msi_z.maotai_uv a 
where a.event = 'mp_entranceindex_tomaotai_click'
and a.home_store_id in (10, 17, 12, 198, 173, 44, 139, 229, 70, 74, 13, 142, 42, 125, 50)
and a.fromat between '2020-08-21' and '2020-08-25')
union
(select distinct a.fromat, a.store_id, a.home_store_id, a.cust_no, a.auth_person_id from chnccp_msi_z.maotai_uv a 
left join chnccp_msi_z.points_100_not_recorded b 
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id and a.fromat = b.points_date
where a.event = 'mp_maotaiIndex_view'
and a.home_store_id in (10, 17, 12, 198, 173, 44, 139, 229, 70, 74, 13, 142, 42, 125, 50)
and a.fromat between '2020-08-21' and '2020-08-25'
and b.cust_no is null)
) tt
group by tt.fromat, tt.home_store_id, tt.store_id
order by tt.fromat, tt.home_store_id, tt.store_id;

------order quantity
--in python
/*drop table maotai_orders;
create table maotai_orders
	as select o.id, t.created_at::timestamp without time zone, t.buyer_id,
        i.title as art_name, o.payment/100 as sales, o.num as qty, t.status,
        b.coupon_status, b.use_store, z.store_id, z.store_id||'_'||z.store_name as store_name, 
        (TIMESTAMP WITHOUT TIME ZONE 'epoch' + b.redeem_time * INTERVAL '1 second') as redeem_time
        from eorder.trades t
        left join eorder.orders o
        on t.id = o.trade_id
        left join eproduct.items i
        on o.item_id = i.id
        left join eproduct.skus s 
        on o.sku_id = s.id
        left join coupon_data.couponlist b
        on o.id = b.trade_no
        left join store_id z
        on z.store_name = b.use_store
        where t.app_id = 'flashsale-moutai';*/

select date(created_at) as dates, store_id, store_name, sum(qty) as qty, count(distinct buyer_id) as cust from maotai_orders
where date(created_at) between '2020-08-21' and '2020-08-25'
and coupon_status is not null
group by date(created_at), store_id, store_name
order by date(created_at), store_id, store_name;

--combined table from teradata
--20200820 to 20200825
select a.fromat, a.home_store_id, a.store_id, a.uv, b.qualified_uv from 
(select fromat, store_id, home_store_id, count(distinct home_store_id||cust_no||auth_person_id) as uv from chnccp_msi_z.maotai_uv
where fromat between '2020-08-21' and '2020-08-25' and event = 'mp_maotaiIndex_view'
and home_store_id in (10, 17, 12, 198, 173, 44, 139, 229, 70, 74, 13, 142, 42, 125, 50)
group by fromat, store_id, home_store_id
) a 
left join 
(select tt.fromat, tt.store_id, tt.home_store_id, count(distinct tt.home_store_id||tt.cust_no||tt.auth_person_id) as qualified_uv from 
(
(select distinct a.fromat, a.store_id, a.home_store_id, a.cust_no, a.auth_person_id from chnccp_msi_z.maotai_uv a 
where a.event = 'mp_entranceindex_tomaotai_click'
and a.home_store_id in (10, 17, 12, 198, 173, 44, 139, 229, 70, 74, 13, 142, 42, 125, 50)
and a.fromat between '2020-08-21' and '2020-08-25')
union
(select distinct a.fromat, a.store_id, a.home_store_id, a.cust_no, a.auth_person_id from chnccp_msi_z.maotai_uv a 
left join chnccp_msi_z.points_100_not_recorded b 
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id and a.fromat = b.points_date
where a.event = 'mp_maotaiIndex_view'
and a.home_store_id in (10, 17, 12, 198, 173, 44, 139, 229, 70, 74, 13, 142, 42, 125, 50)
and a.fromat between '2020-08-21' and '2020-08-25'
and b.cust_no is null) ) tt
group by tt.fromat, tt.home_store_id, tt.store_id ) b 
on a.fromat = b.fromat and a.store_id = b.store_id
order by a.fromat, a.home_store_id, a.store_id;

--20200821 to 20200825
select a.fromat, a.home_store_id, a.store_id, a.uv, b.qualified_uv from 
(select fromat, store_id, home_store_id, count(distinct home_store_id||cust_no||auth_person_id) as uv from chnccp_msi_z.maotai_uv
where fromat between '2020-08-05' and '2020-08-20' and event = 'mp_maotaiIndex_view'
and home_store_id in (10,17,12,198,44,70,74,13,125,50)
group by fromat, store_id, home_store_id
) a 
left join 
(select tt.fromat, tt.store_id, tt.home_store_id, count(distinct tt.home_store_id||tt.cust_no||tt.auth_person_id) as qualified_uv from 
(
(select distinct a.fromat, a.store_id, a.home_store_id, a.cust_no, a.auth_person_id from chnccp_msi_z.maotai_uv a 
where a.event = 'mp_entranceindex_tomaotai_click'
and a.home_store_id in (10,17,12,198,44,70,74,13,125,50)
and a.fromat between '2020-08-05' and '2020-08-20')
union
(select distinct a.fromat, a.store_id, a.home_store_id, a.cust_no, a.auth_person_id from chnccp_msi_z.maotai_uv a 
left join chnccp_msi_z.points_100_not_recorded b 
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id and a.fromat = b.points_date
where a.event = 'mp_maotaiIndex_view'
and a.home_store_id in (10,17,12,198,44,70,74,13,125,50)
and a.fromat between '2020-08-05' and '2020-08-20'
and b.cust_no is null) ) tt
group by tt.fromat, tt.home_store_id, tt.store_id ) b 
on a.fromat = b.fromat and a.store_id = b.store_id
order by a.fromat, a.home_store_id, a.store_id;


--postgresql
select date(created_at) as dates, store_id, store_name, sum(qty) as qty, count(distinct buyer_id) as cust from maotai_orders
where date(created_at) between '2020-08-05' and '2020-08-20'
and coupon_status is not null
group by date(created_at), store_id, store_name
order by date(created_at), store_id, store_name;


------------------------------------------
--new namelist 100 points
create table chnccp_msi_z.qualified_100_points as(
select a.home_store_id, a.cust_no , a.auth_person_id
        from chnccp_dwh.dw_mcrm_loy_member a
        join chnccp_dwh.dw_mcrm_loy_mem_balance b
        on a.loy_mem_row_id = b.loy_mem_row_id
        join chnccp_dwh.dw_customer c
        on a.home_store_id = c.home_store_id and a.cust_no = c.cust_no
        join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj e
        on e.home_store_id = a.home_store_id and e.cust_no = a.cust_no and e.auth_person_id = a.auth_person_id
        join chnccp_dwh.dw_art_var_tu f 
        on f.var_tu_key = e.var_tu_key and f.art_no = e.art_no
        left join (select distinct a.home_store_id ,a.cust_no,a.auth_person_id from chnccp_msi_z.maotai_blacknamelist_total a ) g
        on a.home_store_id = g.home_store_id and a.cust_no = g.cust_no and a.auth_person_id = g.auth_person_id
        --where a.home_store_id in (10,17,12,198,44,70,74,13,125,50)
		left join (select distinct home_store_id, cust_no, auth_person_id from chnccp_msi_z.sales_namelist ) h 
		on a.home_store_id = h.home_store_id and a.cust_no = h.cust_no and a.auth_person_id = h.auth_person_id
        where a.home_store_id in (10, 17, 12, 198, 173, 44, 139, 229, 70, 74, 13, 142, 42, 125, 50)
        and a.loy_mem_parent_ind = 0  
        and b.loy_mem_num_available_pts >= 100
        and c.branch_id not in (971,973)   
        and e.date_of_day between '2020-02-01' and '2020-07-30'
        and g.home_store_id is null 
		and h.home_store_id is null
        group by a.home_store_id, a.cust_no, a.auth_person_id
        having sum(e.sell_val_nsp) > 0
        and  count(distinct month_id) >= 3 
        and sum (e.sell_val_nsp - e.sell_val_nnbp)/sum(e.sell_val_nsp)  >= 0.05 
        and count(distinct f.pcg_cat_id)  >= 3 
		
		)with data;

--namelist not permitted
drop table chnccp_msi_z.points_100_not_recorded;
create table chnccp_msi_z.points_100_not_recorded
	as(	points_date DATE,
		home_store_id INTEGER,
		cust_no INTEGER,
		auth_person_id INTEGER);

insert into chnccp_msi_z.points_100_not_recorded select '2020-08-05' as points_date, home_store_id, cust_no, auth_person_id from chnccp_msi_z.qualified_100_points where home_store_id in (10,17,12,198,44,70,74,13,125,50);
insert into chnccp_msi_z.points_100_not_recorded select '2020-08-06' as points_date, home_store_id, cust_no, auth_person_id from chnccp_msi_z.qualified_100_points where home_store_id in (10,17,12,198,44,70,74,13,125,50);
insert into chnccp_msi_z.points_100_not_recorded select '2020-08-07' as points_date, home_store_id, cust_no, auth_person_id from chnccp_msi_z.qualified_100_points where home_store_id in (10,17,12,198,44,70,74,13,125,50);
insert into chnccp_msi_z.points_100_not_recorded select '2020-08-08' as points_date, home_store_id, cust_no, auth_person_id from chnccp_msi_z.qualified_100_points where home_store_id in (10,17,12,198,44,70,74,13,125,50);
insert into chnccp_msi_z.points_100_not_recorded select '2020-08-09' as points_date, home_store_id, cust_no, auth_person_id from chnccp_msi_z.qualified_100_points where home_store_id in (10,17,12,198,44,70,74,13,125,50);
insert into chnccp_msi_z.points_100_not_recorded select '2020-08-10' as points_date, home_store_id, cust_no, auth_person_id from chnccp_msi_z.qualified_100_points where home_store_id in (10,17,12,198,44,70,74,13,125,50);
insert into chnccp_msi_z.points_100_not_recorded select '2020-08-11' as points_date, home_store_id, cust_no, auth_person_id from chnccp_msi_z.qualified_100_points where home_store_id in (10,17,12,198,44,70,74,13,125,50);
insert into chnccp_msi_z.points_100_not_recorded select '2020-08-12' as points_date, home_store_id, cust_no, auth_person_id from chnccp_msi_z.qualified_100_points where home_store_id in (10,17,12,198,44,70,74,13,125,50);
insert into chnccp_msi_z.points_100_not_recorded select '2020-08-13' as points_date, home_store_id, cust_no, auth_person_id from chnccp_msi_z.qualified_100_points where home_store_id in (10,17,12,198,44,70,74,13,125,50);
insert into chnccp_msi_z.points_100_not_recorded select '2020-08-14' as points_date, home_store_id, cust_no, auth_person_id from chnccp_msi_z.qualified_100_points where home_store_id in (10,17,12,198,44,70,74,13,125,50);
insert into chnccp_msi_z.points_100_not_recorded select '2020-08-15' as points_date, home_store_id, cust_no, auth_person_id from chnccp_msi_z.qualified_100_points where home_store_id in (10,17,12,198,44,70,74,13,125,50);
insert into chnccp_msi_z.points_100_not_recorded select '2020-08-16' as points_date, home_store_id, cust_no, auth_person_id from chnccp_msi_z.qualified_100_points where home_store_id in (10,17,12,198,44,70,74,13,125,50);
insert into chnccp_msi_z.points_100_not_recorded select '2020-08-17' as points_date, home_store_id, cust_no, auth_person_id from chnccp_msi_z.qualified_100_points where home_store_id in (10,17,12,198,44,70,74,13,125,50);
insert into chnccp_msi_z.points_100_not_recorded select '2020-08-18' as points_date, home_store_id, cust_no, auth_person_id from chnccp_msi_z.qualified_100_points where home_store_id in (10,17,12,198,44,70,74,13,125,50);
insert into chnccp_msi_z.points_100_not_recorded select '2020-08-19' as points_date, home_store_id, cust_no, auth_person_id from chnccp_msi_z.qualified_100_points where home_store_id in (10,17,12,198,44,70,74,13,125,50);
insert into chnccp_msi_z.points_100_not_recorded select '2020-08-20' as points_date, home_store_id, cust_no, auth_person_id from chnccp_msi_z.qualified_100_points where home_store_id in (10,17,12,198,44,70,74,13,125,50);

insert into chnccp_msi_z.points_100_not_recorded select '2020-08-21' as points_date, home_store_id, cust_no, auth_person_id from chnccp_msi_z.qualified_100_points where home_store_id in (10, 17, 12, 198, 173, 44, 139, 229, 70, 74, 13, 142, 42, 125, 50);
insert into chnccp_msi_z.points_100_not_recorded select '2020-08-22' as points_date, home_store_id, cust_no, auth_person_id from chnccp_msi_z.qualified_100_points where home_store_id in (10, 17, 12, 198, 173, 44, 139, 229, 70, 74, 13, 142, 42, 125, 50);
insert into chnccp_msi_z.points_100_not_recorded select '2020-08-23' as points_date, home_store_id, cust_no, auth_person_id from chnccp_msi_z.qualified_100_points where home_store_id in (10, 17, 12, 198, 173, 44, 139, 229, 70, 74, 13, 142, 42, 125, 50);
insert into chnccp_msi_z.points_100_not_recorded select '2020-08-24' as points_date, home_store_id, cust_no, auth_person_id from chnccp_msi_z.qualified_100_points where home_store_id in (10, 17, 12, 198, 173, 44, 139, 229, 70, 74, 13, 142, 42, 125, 50);
insert into chnccp_msi_z.points_100_not_recorded select '2020-08-25' as points_date, home_store_id, cust_no, auth_person_id from chnccp_msi_z.qualified_100_points where home_store_id in (10, 17, 12, 198, 173, 44, 139, 229, 70, 74, 13, 142, 42, 125, 50);





--part2


--0805 to 0812
select '2020-08-12' as dates, a.store_id, a.store_name,
coalesce(sum(CASE WHEN date(redeem_time) = '2020-08-12' then qty end),0) as now_day_redeem,
coalesce(count(distinct CASE WHEN date(redeem_time) = '2020-08-12' then buyer_id end),0) as now_day_cust,
coalesce(sum(CASE WHEN (date(created_at) between '2020-08-05' and '2020-08-12') and sales <> 0 then qty end) - 
sum(CASE WHEN (date(redeem_time) between '2020-08-05' and '2020-08-12') and sales <> 0 then qty end),0) as active_qty
from maotai_orders b 
join store_id a
on a.store_name = b.use_store
group by dates, a.store_id, a.store_name
order by dates, a.store_id, a.store_name;

--regular redemption
select '2020-08-25' as dates, a.store_id||'_'||a.store_name as store_id,
coalesce(sum(CASE WHEN date(redeem_time) = '2020-08-25' then qty end),0) as now_day_redeem,
coalesce(count(distinct CASE WHEN date(redeem_time) = '2020-08-25' then buyer_id end),0) as now_day_cust,
coalesce(sum(CASE WHEN coupon_status = 'ACTIVE' and (date(created_at) between '2020-08-18' and '2020-08-25') then qty end),0) as active_qty,
coalesce(sum(CASE WHEN coupon_status = 'EXPIRED' and (date(created_at) between '2020-08-05' and '2020-08-17') then qty end),0) as expired_qty
from maotai_orders b 
join store_id a
on a.store_name = b.use_store
group by dates, a.store_id, a.store_name
order by dates, a.store_id, a.store_name;


--current_date orders
select date(a.created_at) as dates, b.store_id||'_'||b.store_name as pickup_store,
coalesce(sum(CASE WHEN a.coupon_status = 'REDEEMED' then a.qty end ),0) as redeem_qty,
coalesce(1.000 * sum(CASE WHEN a.coupon_status = 'REDEEMED' then a.qty end ) / sum(CASE WHEN a.coupon_status is not null then a.qty end),0) as redeem_rate
from maotai_orders a
join store_id b 
on b.store_name = a.use_store
where date(a.created_at) between '2020-08-20' and current_date - 1
group by dates, pickup_store
order by dates, pickup_store;


--part3


--early bird original table: chnccp_msi_z.abby_moutai_early2
--copy: 
create table chnccp_msi_z.abby_moutai_early2_copy
	as(select * from chnccp_msi_z.abby_moutai_early2)with data;

--total 抢购成功的名单，包括所有兑换状态
--linux automatic running
drop table chnccp_msi_z.sales_namelist;
create table chnccp_msi_z.sales_namelist
(	home_store_id INTEGER,
	cust_no INTEGER,
	auth_person_id INTEGER,
	coupon_status VARCHAR(255), 
	redeem_time DATE);



--namelist for categories
drop table chnccp_msi_z.maotai_redeeem_namelist;
create table chnccp_msi_z.maotai_redeeem_namelist
	as(select tt.* from 
		(
		(select distinct a.home_store_id, a.cust_no, a.auth_person_id, 'early_bird_non_part' as event from chnccp_msi_z.abby_moutai_early2 a
		left join (select distinct home_store_id, cust_no, auth_person_id from chnccp_msi_z.maotai_uv where fromat between '2020-08-05' and (date -1)) c
		on a.home_store_id = c.home_store_id and a.cust_no = c.cust_no and a.auth_person_id = c.auth_person_id
		where c.cust_no is null
		    )
		union
		(select distinct a.home_store_id, a.cust_no, a.auth_person_id, 'early_bird_part' as event from chnccp_msi_z.abby_moutai_early2 a
		join (select distinct home_store_id, cust_no, auth_person_id from chnccp_msi_z.maotai_uv where fromat between '2020-08-05' and (date -1) )c
		on a.home_store_id = c.home_store_id and a.cust_no = c.cust_no and a.auth_person_id = c.auth_person_id
		    )
		union
		(select distinct a.home_store_id, a.cust_no, a.auth_person_id, 'view_page' as event from chnccp_msi_z.maotai_uv a
			where a.fromat between '2020-08-05' and (date -1)
			)
		union
        (select tt.home_store_id, tt.cust_no, tt.auth_person_id, 'view_qualified' as event from 
        (
        	(select distinct a.fromat, a.store_id, a.home_store_id, a.cust_no, a.auth_person_id from chnccp_msi_z.maotai_uv a
        		where a.event = 'mp_entranceindex_tomaotai_click'
        		and a.home_store_id in (10, 17, 12, 198, 173, 44, 139, 229, 70, 74, 13, 142, 42, 125, 50)
        		and a.fromat between '2020-08-05' and (date -1))
        	union
        	(select distinct a.fromat, a.store_id, a.home_store_id, a.cust_no, a.auth_person_id from chnccp_msi_z.maotai_uv a
        		left join chnccp_msi_z.points_100_not_recorded b
        		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id and a.fromat = b.points_date
        		where a.event = 'mp_maotaiIndex_view'
        		and a.home_store_id in (10, 17, 12, 198, 173, 44, 139, 229, 70, 74, 13, 142, 42, 125, 50)
        		and a.fromat between '2020-08-05' and (date -1)
        		and b.cust_no is null) 
        	    ) tt
                )
        union
		(select distinct a.home_store_id, a.cust_no, a.auth_person_id, 'success_buying' as event from chnccp_msi_z.sales_namelist a
		where a.created_at between '2020-08-05' and (date - 1)
			)
		)tt
		)with data;


select event, count(1) as viewer from chnccp_msi_z.maotai_redeeem_namelist
group by event
order by event;


select event, count(distinct a.home_store_id||a.cust_no||a.auth_person_id) as buyer, 
sum(b.sell_val_gsp) as sales, count(distinct b.invoice_id) / count(distinct a.home_store_id||a.cust_no||a.auth_person_id) as frequency, sum(b.sell_val_gsp) / count(distinct b.invoice_id) as basket
from chnccp_msi_z.maotai_redeeem_namelist a 
join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj  b 
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
join chnccp_dwh.dw_art_var_tu c 
on c.var_tu_key = b.var_tu_key and b.art_no = c.art_no
where c.mikg_art_no <> 150619
and b.date_of_day between '2020-08-05' and date - 1
group by event;


