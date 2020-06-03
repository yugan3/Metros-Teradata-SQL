-- sending group base
select a.campaign_type,a.type_id,a.gcn,a.coupon_type,a.wave_num,count(distinct a.home_store_id || a.cust_no || a.auth_person_id) as sending_base
from chnccp_crm.lifecycle_data a
where  a.gcn is not null 
group by 1,2,3,4,5
order by 5,1,2,3 ;


-- control base   
select a.campaign_type,a.type_id,a.wave_num,count(distinct a.home_store_id || a.cust_no || a.auth_person_id) as control_base
from  chnccp_crm.lifecycle_data a
where a.gcn is  null 
group by 1,2,3
order by 1,2,3;

-- sending ttl buyer
select a.campaign_type,a.type_id,a.gcn,a.coupon_type,a.wave_num
,count(distinct b.home_store_id || b.cust_no || b.auth_person_id) as buyer
,sum(b.sell_val_nsp)  as net_sales
,count (distinct b.home_store_id || b.cust_no || b.auth_person_id || b.date_of_day) as visits
,sum(b.sell_val_nsp- b.sell_val_nnbp)  as margin
from chnccp_crm.lifecycle_data a
inner  join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj  b
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
where b.fsd_ind = 'N' and b.wel_ind = 'N' and b.deli_ind = 'N' and b.bvs_ind = 'N' and b.pcr_ind = 'N'
and b.date_of_day between a.active_date  and a.until_date
and  a.gcn is not null 
group by 1,2,3,4,5
order by 5,1,2,3 ;

-- ttl redeemed
select a.campaign_type,a.type_id,a.gcn,a.coupon_type,a.wave_num
,count(distinct b.home_store_id || b.cust_no || b.auth_person_id) as buyer
,sum(b.sell_val_nsp)  as net_sales
,count (distinct b.home_store_id || b.cust_no || b.auth_person_id || b.date_of_day) as visits
,sum(b.sell_val_nsp- b.sell_val_nnbp)  as margin
from chnccp_crm.lifecycle_data a
inner  join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj  b
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
inner join  chnccp_dwh.dw_gcn_campaign_event  c
on STRTOK(a.epc, ':', 5)= c.sgcn_no = c.sgcn_no
where a.gcn is not null 
and b.fsd_ind = 'N' and b.wel_ind = 'N' and b.deli_ind = 'N' and b.bvs_ind = 'N' and b.pcr_ind = 'N'
and c.gcn_disposition = 'redeemed'
and b.date_of_day = c.gcn_event_date
group by 1,2,3,4,5
order by 5,1,2,3 ;

-- control buying
-- wave2
select a.campaign_type,a.type_id,a.wave_num
,count(distinct b.home_store_id || b.cust_no || b.auth_person_id) as buyer
,sum(b.sell_val_nsp)  as net_sales
,count (distinct b.home_store_id || b.cust_no || b.auth_person_id || b.date_of_day) as visits
,sum(b.sell_val_nsp- b.sell_val_nnbp)  as margin
from  chnccp_crm.lifecycle_data  a 
inner  join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj  b
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
--left  join ( select distinct a.home_store_id,a.cust_no,a.auth_person_id from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj a where a.date_of_day between '2020-04-12' and '2020-04-29') c
--on a.home_store_id = c.home_store_id and a.cust_no = c.cust_no and a.auth_person_id = c.auth_person_id
where  a.gcn is  null 
and b.fsd_ind = 'N' and b.wel_ind = 'N' and b.deli_ind = 'N' and b.bvs_ind = 'N' and b.pcr_ind = 'N'
and b.date_of_day between '2020-05-15' and '2020-05-29'
--and c.home_store_id is null
group by 1,2,3
order by 1,2,3 ;


drop table chnccp_crm.lifecycle_data;
create table chnccp_crm.lifecycle_data(
home_store_id INTEGER,
cust_no INTEGER,
auth_person_id INTEGER,
campaign_type CHAR(64),
type_id CHAR(64),
coupon_type CHAR(64),
wave_num INTEGER,
gcn CHAR(64),
epc VARCHAR(40),
active_date DATE,
until_date DATE);

-----------------------------
STRTOK(ziduan,':', 5) 字段以：来分列，选择第5个结果。计数从1开始。
----------------------------

--total redeemed
select a.campaign_type,a.type_id,a.gcn,a.coupon_type
,count(distinct b.home_store_id || b.cust_no || b.auth_person_id) as buyer
,sum(b.sell_val_nsp)  as net_sales
,count (distinct b.home_store_id || b.cust_no || b.auth_person_id || b.date_of_day) as visits
,sum(b.sell_val_nsp- b.sell_val_nnbp)  as margin
from chnccp_crm.lifecycle_data a
inner  join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj  b
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
inner join  chnccp_dwh.dw_gcn_campaign_event  c
on STRTOK(a.epc, ':', 5)= c.sgcn_no
where a.gcn is not null 
and b.fsd_ind = 'N' and b.wel_ind = 'N' and b.deli_ind = 'N' and b.bvs_ind = 'N' and b.pcr_ind = 'N'
and c.gcn_disposition = 'redeemed'
and b.date_of_day = c.gcn_event_date
group by 1,2,3,4
order by 4,1,2,3 ;

--total buying customer
select a.campaign_type,a.type_id,a.gcn,a.coupon_type
,count(distinct b.home_store_id || b.cust_no || b.auth_person_id) as buyer
,sum(b.sell_val_nsp)  as net_sales
,count (distinct b.home_store_id || b.cust_no || b.auth_person_id || b.date_of_day) as visits
,sum(b.sell_val_nsp- b.sell_val_nnbp)  as margin
from chnccp_crm.lifecycle_data a
inner  join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj  b
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
where b.fsd_ind = 'N' and b.wel_ind = 'N' and b.deli_ind = 'N' and b.bvs_ind = 'N' and b.pcr_ind = 'N'
and b.date_of_day between a.active_date  and a.until_date
and  a.gcn is not null 
group by 1,2,3,4
order by 4,1,2,3 ;

------------------------------------------------------------------------
-----------------------------control corrected---------------------------
drop table chnccp_msi_z.lifecycle_contro_1;
create table chnccp_msi_z.lifecycle_contro_1
	as(select a.home_store_id, a.cust_no, a.auth_person_id, a.type_id from  chnccp_crm.lifecycle_data  a 
		inner  join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj  b
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
        where a.gcn is null
        and b.date_of_day between '2020-04-15' and '2020-04-28'
        and b.fsd_ind = 'N' and b.wel_ind = 'N' and b.deli_ind = 'N' and b.bvs_ind = 'N' and b.pcr_ind = 'N'
        group by a.home_store_id, a.cust_no, a.auth_person_id, a.type_id)with data;

--wave2
drop table chnccp_msi_z.lifecycle_contro_2;
create table chnccp_msi_z.lifecycle_contro_2
	as(select distinct a.home_store_id, a.cust_no, a.auth_person_id, a.type_id from (select distinct home_store_id, cust_no, auth_person_id, type_id from chnccp_crm.lifecycle_data where gcn is NULL) a 
		left join chnccp_msi_z.lifecycle_contro_1 b
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		where b.cust_no is NULL)with data;


select a.type_id,count(distinct a.home_store_id || a.cust_no || a.auth_person_id) as control_base
from  chnccp_msi_z.lifecycle_contro_2 a
group by 1
order by 1;

select a.type_id,
,count(distinct b.home_store_id || b.cust_no || b.auth_person_id) as buyer
,sum(b.sell_val_nsp)  as net_sales
,count (distinct b.home_store_id || b.cust_no || b.auth_person_id || b.date_of_day) as visits
,sum(b.sell_val_nsp- b.sell_val_nnbp)  as margin
from  chnccp_msi_z.lifecycle_contro_2  a 
inner  join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj  b
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
where b.fsd_ind = 'N' and b.wel_ind = 'N' and b.deli_ind = 'N' and b.bvs_ind = 'N' and b.pcr_ind = 'N'
and b.date_of_day between '2020-04-29' and '2020-05-14'
group by 1
order by 1 ;

drop table chnccp_msi_z.lifecycle_contro_2_sales;
create table chnccp_msi_z.lifecycle_contro_2_sales
	as(select a.home_store_id, a.cust_no, a.auth_person_id, a.type_id from chnccp_msi_z.lifecycle_contro_2 a
		join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		where b.fsd_ind = 'N' and b.wel_ind = 'N' and b.deli_ind = 'N' and b.bvs_ind = 'N' and b.pcr_ind = 'N'
		and b.date_of_day between '2020-04-29' and '2020-05-14'
		group by a.home_store_id, a.cust_no, a.auth_person_id, a.type_id)with data;

--wave3
drop table chnccp_msi_z.lifecycle_contro_3;
create table chnccp_msi_z.lifecycle_contro_3
	as(select distinct a.home_store_id, a.cust_no, a.auth_person_id, a.type_id from chnccp_msi_z.lifecycle_contro_2 a 
		left join chnccp_msi_z.lifecycle_contro_2_sales b
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		where b.cust_no is NULL)with data;

select a.type_id,count(distinct a.home_store_id || a.cust_no || a.auth_person_id) as control_base
from  chnccp_msi_z.lifecycle_contro_3 a
group by 1
order by 1;

select a.type_id
,count(distinct b.home_store_id || b.cust_no || b.auth_person_id) as buyer
,sum(b.sell_val_nsp)  as net_sales
,count (distinct b.home_store_id || b.cust_no || b.auth_person_id || b.date_of_day) as visits
,sum(b.sell_val_nsp- b.sell_val_nnbp)  as margin
from  chnccp_msi_z.lifecycle_contro_3  a 
inner  join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj  b
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
where b.fsd_ind = 'N' and b.wel_ind = 'N' and b.deli_ind = 'N' and b.bvs_ind = 'N' and b.pcr_ind = 'N'
and b.date_of_day between '2020-05-15' and '2020-05-29'
group by 1
order by 1 ;


