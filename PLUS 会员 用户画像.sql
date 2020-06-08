-----------------PLUS 会员用户画像----------------------
--plus namelist:O2O&C2C
drop table chnccp_msi_z.plus_namelist;
create table chnccp_msi_z.plus_namelist
	as (select a.home_store_id, a.cust_no, a.auth_person_id from chnccp_crm.frank_paid_member_dashboard_cust_2 a 
		join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b 
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		join chnccp_dwh.dw_customer c
		on a.home_store_id = c.home_store_id and a.cust_no = c.cust_no
		where a.join_date < '2020-06-01' 
		and b.store_id in (11,40,41,54,60,62,66,67,76,105,179)
		and b.wel_ind = 'N' 
	    and b.fsd_ind = 'N' 
	    and b.deli_ind = 'N' 
	    and b.bvs_ind = 'N' 
	    and b.pcr_ind = 'N'
	    and c.branch_id in (401, 493, 492, 971, 973)
	    group by a.home_store_id, a.cust_no, a.auth_person_id
		)with data;

select count(distinct home_store_id||cust_no||auth_person_id) as plus from chnccp_msi_z.plus_namelist;
select count(*) from chnccp_msi_z.plus_namelist;

--tags
drop table chnccp_msi_z.plus_chars;
create table chnccp_msi_z.plus_chars
	as(select a.*, 
		CASE WHEN REGEXP_SIMILAR(left (right(b.identification_id,2),1), '[0-9]{1}','c')  = 1 then left (right(b.identification_id,2),1) 
		ELSE NULL end as gender,
		case when REGEXP_SIMILAR(right (left(b.identification_id,10),4), '[0-9]{4}','c')  = 1 then 2020-right (left(b.identification_id,10),4) 
		ELSE NULL end as age,
		b.date_created, EXTRACT(year FROM b.date_created) as year1 from chnccp_msi_z.plus_namelist a
		left join chnccp_dwh.dw_cust_auth_person b
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id)with data;

--age
drop table chnccp_msi_z.plus_chars_age;
create table chnccp_msi_z.plus_chars_age
	as(select home_store_id, auth_person_id, cust_no,
		CASE WHEN age < 18 THEN '<18'
		     WHEN age between 18 and 24 THEN '18-24'
		     WHEN age between 25 and 29 THEN '25-29'
		     WHEN age between 30 and 39 THEN '30-39'
		     WHEN age between 40 and 49 THEN '40-49'
		     WHEN age >= 50 THEN '>=50'
		     ELSE NULL END AS age_group from chnccp_msi_z.plus_chars)with data;

select age_group, count(distinct home_store_id||cust_no||auth_person_id) as people from chnccp_msi_z.plus_chars_age
group by age_group;

select count(*) from chnccp_msi_z.plus_chars_age;
select count(*) from chnccp_msi_z.plus_chars_age where age_group is NULL;
select count(*) from chnccp_msi_z.plus_chars_age where age_group is not NULL;

--gender
drop table chnccp_msi_z.plus_chars_gender;
create table chnccp_msi_z.plus_chars_gender
	as (select home_store_id, auth_person_id, cust_no,
		CASE WHEN gender in (0,2,4,6,8) THEN '女'
		     WHEN gender in (1,3,5,7,9) THEN '男'
		     ELSE '未知' END AS gender_group from chnccp_msi_z.plus_chars)with data;

select gender_group, count(distinct home_store_id||cust_no||auth_person_id) as people from chnccp_msi_z.plus_chars_gender
group by gender_group;

--register_date
drop table chnccp_msi_z.plus_chars_regyear;
create table chnccp_msi_z.plus_chars_regyear
	as(select home_store_id, cust_no, auth_person_id, year1 from chnccp_msi_z.plus_chars where year1 is NOT NULL)with data;

select year1, count(distinct home_store_id||cust_no||auth_person_id) as people from chnccp_msi_z.plus_chars_regyear
group by year1;

select count(*) from chnccp_msi_z.plus_chars where year1 is NULL;

--UMC:
select b.member_type, count(distinct a.auth_person_id||a.home_store_id||a.cust_no) as buyer from chnccp_msi_z.plus_namelist a 
left join chnccp_msi_z.mem_ref_umc_tag_act b
on a.auth_person_id = b.auth_person_id and a.home_store_id = b.home_store_id and a.cust_no = b.cust_no
group by b.member_type;

select sum(b.sell_val_gsp) /sum(b.tunit_qty*b.sell_qty_colli) from chnccp_msi_z.plus_namelist a 
join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b 
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
where b.date_of_day between '2019-06-07' and '2020-06-06';



--fan:
select b.fan_ind,count(distinct a.auth_person_id||a.home_store_id||a.cust_no) as buyer from chnccp_msi_z.flashsales a 
left join chnccp_msi_z.mem_ref_umc_tag_act b
on a.auth_person_id = b.auth_person_id and a.home_store_id = b.home_store_id and a.cust_no = b.cust_no
group by b.fan_ind;