---coffee
drop table chnccp_msi_z.coffee;
create table chnccp_msi_z.coffee as (
	select 2 as priority, 'coffee' as seg, a.home_store_id, a.cust_no, a.auth_person_id from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj a
	join chnccp_dwh.dw_art_var_tu  b
	on a.art_no = b.art_no and a.var_tu_key = b.var_tu_key
	join chnccp_dwh.dw_customer c
	on a.home_store_id = c.home_store_id and a.cust_no = c.cust_no
	where a.date_of_day between '2019-06-08' and '2020-06-07'
	and a.wel_ind = 'N' 
	and a.fsd_ind = 'N' 
	and a.deli_ind = 'N' 
	and a.bvs_ind = 'N' 
	and a.pcr_ind = 'N'
	and (
(b.demand_field_domain_id = 605 and b.pcg_main_cat_id = 471 and b.pcg_cat_id = 10) Or
(b.demand_field_domain_id = 603 and b.pcg_main_cat_id = 463 and b.pcg_cat_id = 10) Or
(b.demand_field_domain_id = 603 and b.pcg_main_cat_id = 463 and b.pcg_cat_id = 99) Or
(b.demand_field_domain_id = 603 and b.pcg_main_cat_id = 463 and b.pcg_cat_id = 30) Or
(b.demand_field_domain_id = 605 and b.pcg_main_cat_id = 471 and b.pcg_cat_id = 99) Or
(b.demand_field_domain_id = 603 and b.pcg_main_cat_id = 463 and b.pcg_cat_id = 20) Or
(b.demand_field_domain_id = 603 and b.pcg_main_cat_id = 463 and b.pcg_cat_id = 50) )
	and c.branch_id in (401, 493, 492, 971, 973)
	group by priority, seg,a.home_store_id, a.cust_no, a.auth_person_id
   having sum(a.tunit_qty*a.sell_qty_colli) > 0 and  sum(a.sell_val_gsp) > 0 and sum(a.sell_val_gsp) /sum(a.tunit_qty*a.sell_qty_colli) >20)with data;

select count(*) as coffee from chnccp_msi_z.coffee;

--office
/*drop table chnccp_msi_z.office;
create table chnccp_msi_z.office as (
	select a.home_store_id, a.cust_no, a.auth_person_id from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj a
	join chnccp_dwh.dw_art_var_tu b
	on a.art_no = b.art_no and a.var_tu_key = b.var_tu_key
	join chnccp_dwh.dw_customer c
	on a.home_store_id = c.home_store_id and a.cust_no = c.cust_no
	where a.date_of_day between '2019-06-08' and '2020-06-07'
	and a.wel_ind = 'N' 
	and a.fsd_ind = 'N' 
	and a.deli_ind = 'N' 
	and a.bvs_ind = 'N' 
	and a.pcr_ind = 'N'
	and b.demand_field_domain_id = 462 and b.pcg_main_cat_id in (661,655,652,657,660,654,658)
	and c.branch_id in (401, 493, 492, 971, 973)
	group by a.home_store_id, a.cust_no, a.auth_person_id)with data;

select count(distinct a.home_store_id||a.cust_no||a.auth_person_id) as crossbuyer from chnccp_msi_z.coffee a 
join chnccp_msi_z.office b
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id;*/


--Aptamil
select demand_field_domain_id, pcg_main_cat_id, pcg_cat_id, mikg_art_no, art_name from chnccp_dwh.dw_art_var_tu
where demand_field_domain_id = 601 and pcg_main_cat_id = 392 and pcg_cat_id = 99 and art_name like '%爱他美%'
group by demand_field_domain_id, pcg_main_cat_id, pcg_cat_id, mikg_art_no, art_name;


drop table chnccp_msi_z.Aptamil;
create table chnccp_msi_z.Aptamil as(
	select 1 as priority, 'Aptamil' as seg, a.home_store_id, a.cust_no, a.auth_person_id from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj a
	join chnccp_dwh.dw_art_var_tu b
	on a.art_no = b.art_no and a.var_tu_key = b.var_tu_key
	join chnccp_dwh.dw_customer c
	on a.home_store_id = c.home_store_id and a.cust_no = c.cust_no
	where a.date_of_day between '2019-06-08' and '2020-06-07'
	and a.wel_ind = 'N' 
	and a.fsd_ind = 'N' 
	and a.deli_ind = 'N' 
	and a.bvs_ind = 'N' 
	and a.pcr_ind = 'N'
	and b.demand_field_domain_id = 601 and b.pcg_main_cat_id = 392 and b.pcg_cat_id = 99 and b.mikg_art_no in (189110,170665,186717,170664,234460)
	and c.branch_id in (401, 493, 492, 971, 973)
	group by a.home_store_id, a.cust_no, a.auth_person_id)with data;

select count(*) as Aptamil from chnccp_msi_z.Aptamil;

--import snacks
drop table chnccp_msi_z.importsnacks;
create table chnccp_msi_z.importsnacks as(
	select 3 as priority, 'importsnack' as seg, a.home_store_id, a.cust_no, a.auth_person_id from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj a
	join chnccp_dwh.dw_art_var_tu b
	on a.art_no = b.art_no and a.var_tu_key = b.var_tu_key
	join chnccp_dwh.dw_customer c
	on a.home_store_id = c.home_store_id and a.cust_no = c.cust_no
	join chnccp_dwh.dw_article d 
	on b.demand_field_domain_id = d.demand_field_domain_id and b.pcg_main_cat_id = d.pcg_main_cat_id and b.pcg_cat_id = d.pcg_cat_id
	where a.date_of_day between '2019-06-08' and '2020-06-07'
	and a.wel_ind = 'N' 
	and a.fsd_ind = 'N' 
	and a.deli_ind = 'N' 
	and a.bvs_ind = 'N' 
	and a.pcr_ind = 'N'
	and c.branch_id in (401, 493, 492, 971, 973)
	and b.demand_field_domain_id = 603 
	and b.pcg_main_cat_id = 401
	and d.pcg_cat_id = 99 
	and d.pcg_sub_cat_id = 20
	and d.fnf_cd = 'F'
	group by priority, seg,a.home_store_id, a.cust_no, a.auth_person_id
	having sum(a.tunit_qty*a.sell_qty_colli) > 0 and  sum(a.sell_val_gsp) > 0 and sum(a.sell_val_gsp) /sum(a.tunit_qty*a.sell_qty_colli) > 20)with data;

select count(*) as importsnack from chnccp_msi_z.importsnacks;


/*drop table chnccp_msi_z.namelist0610;
create table chnccp_msi_z.namelist0610
	(priority INTEGER,
	seg_id VARCHAR(48),
	home_store_id INTEGER,
	cust_no INTEGER,
	auth_person_id INTEGER);*/


/*insert into chnccp_msi_z.namelist0610 select 1 as priority, 'Aptamil' as seg_id, home_store_id, cust_no, auth_person_id from chnccp_msi_z.Aptamil;
insert into chnccp_msi_z.namelist0610 select 2 as priority, 'coffee' as seg_id, home_store_id, cust_no, auth_person_id from chnccp_msi_z.coffee;
insert into chnccp_msi_z.namelist0610 select 3 as priority, 'importsnacks' as seg_id, home_store_id, cust_no, auth_person_id from chnccp_msi_z.importsnacks;*/

drop table chnccp_msi_z.namelist0610_total;
create table chnccp_msi_z.namelist0610_total
	as(
		select	a.*, b.mobile_phone_no 
	from	
	(
	select	a.*
	, row_number() over (Partition by a.home_store_id ,a.cust_no,a.auth_person_id order by a.priority) as row_id 
	from	
	( select * from chnccp_msi_z.coffee
	union select * from chnccp_msi_z.Aptamil 
	union select * from chnccp_msi_z.importsnacks ) a
	) a
	left join  chnccp_dwh.dw_cust_address b
		on a.cust_no = b.cust_no 
		and a.auth_person_id =b.auth_person_id 
		and a.home_store_id = b.home_store_id
	where length( b.mobile_phone_no ) = 11 and a.row_id = 1
) with data;

/*drop table chnccp_msi_z.namelist0610_total_1;
create table chnccp_msi_z.namelist0610_total_1
	as(select * from chnccp_msi_z.namelist0610_total
		where row_id = 1
		)with data;*/

select seg, count(*) as people1 from chnccp_msi_z.namelist0610_total
group by seg;


drop table chnccp_msi_z.namelist0610_total_control;
create table chnccp_msi_z.namelist0610_total_control
	as(select * from  chnccp_msi_z.namelist0610_total sample  35746
	)with data;

drop table chnccp_msi_z.namelist0610_total_sending;
create table chnccp_msi_z.namelist0610_total_sending
	as(select a.* from chnccp_msi_z.namelist0610_total a 
		left join chnccp_msi_z.namelist0610_total_control b 
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		where b.cust_no is NULL
		)with data;



select home_store_id,cust_no,auth_person_id, mobile_phone_no from chnccp_msi_z.namelist0610_total_sending
where seg = 'coffee';

select home_store_id,cust_no,auth_person_id, mobile_phone_no from chnccp_msi_z.namelist0610_total_sending
where seg = 'import';

select home_store_id,cust_no,auth_person_id, mobile_phone_no from chnccp_msi_z.namelist0610_total_sending
where seg = 'Aptami';