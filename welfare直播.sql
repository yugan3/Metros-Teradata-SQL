----------------------------------------------------------------------------Welfare-------------------------------------------------------------
--given namelist
drop table chnccp_msi_z.welfare;
create table chnccp_msi_z.welfare
	(home_store_id INTEGER,
	 cust_no INTEGER,
	 "type" CHAR(24)
		);

--actual namlist
drop table chnccp_msi_z.welfare_namelist;
create table chnccp_msi_z.welfare_namelist
	as (select a.home_store_id, a.cust_no, b.auth_person_id, b.auth_person_short_name, a."type" as member, c.mobile_phone_no from chnccp_msi_z.welfare a 
		left join chnccp_dwh.dw_cust_auth_person b 
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no
		left join chnccp_dwh.dw_cust_address c 
		on a.home_store_id = c.home_store_id and a.cust_no = c.cust_no and b.auth_person_id = c.auth_person_id)with data;

--SMS namelist:211503
drop table chnccp_msi_z.welfare_namelist_SMS;
create table chnccp_msi_z.welfare_namelist_SMS
	as(select a.*, sum(b.sell_val_gsp) /sum(b.tunit_qty*b.sell_qty_colli) as spending, max(b.date_of_day) as recency, count(distinct b.date_of_day) as frequency from chnccp_msi_z.welfare_namelist a 
		left join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b 
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		where length(a.mobile_phone_no) = 11 
		group by a.home_store_id, a.cust_no, a.auth_person_id, a.auth_person_short_name, a."member", a.mobile_phone_no
		having sum(b.tunit_qty*b.sell_qty_colli)>0 and recency between '2019-06-10' and '2020-06-09'
		)with data;

select count(distinct home_store_id||cust_no||auth_person_id) from chnccp_msi_z.welfare_namelist_SMS;

