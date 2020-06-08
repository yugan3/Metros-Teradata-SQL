drop table chnccp_msi_z.lifecycle_reactivation_data;
create table chnccp_msi_z.lifecycle_reactivation_data
	(home_store_id INTEGER,
	cust_no INTEGER,
	auth_person_id INTEGER,
	mobile VARCHAR(48),
	card_number VARCHAR(48),
	campaign_type CHAR(48),
	type_id INTEGER,
	coupon_type CHAR(48),
	wave_num INTEGER,
	trade_no CHAR(48),
	push_date DATE,
	csn CHAR(48),
	gcn CHAR(48),
	epc CHAR(48),
	coupon_use_status CHAR(48),
	coupon_send_time TIMESTAMP,
	active_date TIMESTAMP,
	until_date TIMESTAMP,
	vvv_from TIMESTAMP,
	vvv_until TIMESTAMP	);


select wave_number, type_id, coupon_type, push_date, until_date from chnccp_msi_z.lifecycle_reactivation_data
group by wave_number, type_id, coupon_type, push_date, until_date;




--------------------------DWX-----------------------
-- ttl
select a.campaign_type,a.type_id,a.gcn,a.coupon_type,count(distinct a.home_store_id || a.cust_no || a.auth_person_id) as sending_base
from chnccp_msi_z.lifecycle_reactivation_data a
where  a.coupon_use_status is not null and a.campaign_type = '5.14DWX'
group by 1,2,3,4
order by 4,1,2,3;

-- sending ttl buyer
select a.campaign_type,a.type_id,a.gcn,a.coupon_type
,count(distinct b.home_store_id || b.cust_no || b.auth_person_id) as buyer
,sum(b.sell_val_nsp) as net_sales
,count (distinct b.home_store_id || b.cust_no || b.auth_person_id || b.date_of_day) as visits
,sum(b.sell_val_nsp- b.sell_val_nnbp)  as margin
from chnccp_msi_z.lifecycle_reactivation_data a
inner  join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj  b
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
where b.fsd_ind = 'N' and b.wel_ind = 'N' and b.deli_ind = 'N' and b.bvs_ind = 'N' and b.pcr_ind = 'N'
and b.date_of_day between '2020-05-14' and '2020-06-03'
and a.coupon_use_status is not null and a.campaign_type = '5.14DWX'
group by 1,2,3,4
order by 1,2,3,4;

-- ttl redeemed
select a.campaign_type,a.type_id,a.gcn,a.coupon_type
,count(distinct b.home_store_id || b.cust_no || b.auth_person_id) as buyer
,sum(b.sell_val_nsp)  as net_sales
,count (distinct b.home_store_id || b.cust_no || b.auth_person_id || b.date_of_day) as visits
,sum(b.sell_val_nsp- b.sell_val_nnbp)  as margin
from chnccp_msi_z.lifecycle_reactivation_data  a
inner  join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj  b
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
inner join  chnccp_dwh.dw_gcn_campaign_event  c
on STRTOK(a.epc, ':', 5) = c.sgcn_no
where a.coupon_use_status is not null and a.campaign_type = '5.14DWX'
and b.fsd_ind = 'N' and b.wel_ind = 'N' and b.deli_ind = 'N' and b.bvs_ind = 'N' and b.pcr_ind = 'N'
and c.gcn_disposition = 'redeemed'
and b.date_of_day = c.gcn_event_date
group by 1,2,3,4
order by 1,2,3,4;


--control
select a.campaign_type,a.type_id,a.coupon_type, count(distinct a.home_store_id || a.cust_no || a.auth_person_id) as control_base
from chnccp_msi_z.lifecycle_reactivation_data a
where a.coupon_use_status is null
group by 1,2,3
order by 1,2,3;

--control
select a.campaign_type,a.type_id, a.coupon_type
,count(distinct b.home_store_id || b.cust_no || b.auth_person_id) as buyer
,sum(b.sell_val_nsp)  as net_sales
,count (distinct b.home_store_id || b.cust_no || b.auth_person_id || b.date_of_day) as visits
,sum(b.sell_val_nsp- b.sell_val_nnbp)  as margin
from chnccp_msi_z.lifecycle_reactivation_data a 
inner join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj  b
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
where a.coupon_use_status is null 
and b.fsd_ind = 'N' and b.wel_ind = 'N' and b.deli_ind = 'N' and b.bvs_ind = 'N' and b.pcr_ind = 'N'
and b.date_of_day between '2020-05-14' and '2020-06-03'
group by 1,2,3
order by 1,2,3;

------------------Reactivation------------------
-----total sending base
select a.campaign_type,a.type_id,a.gcn,a.coupon_type,
CASE WHEN CAST(a.active_date AS DATE) between '2020-05-15' and '2020-05-21' THEN 'wave1'
     WHEN CAST(a.active_date AS DATE) between '2020-05-22' and '2020-05-27' THEN 'wave2'END AS wave,
count(distinct a.home_store_id || a.cust_no || a.auth_person_id) as sending_base
from chnccp_msi_z.lifecycle_reactivation_data a
where  a.coupon_use_status is not null and a.campaign_type = 'reactivation'
group by 1,2,3,4
order by 1,4,2,3;

--wave1
-----ttl
select a.campaign_type,a.type_id,a.gcn,a.coupon_type
,count(distinct b.home_store_id || b.cust_no || b.auth_person_id) as buyer
,sum(b.sell_val_nsp)  as net_sales
,count (distinct b.home_store_id || b.cust_no || b.auth_person_id || b.date_of_day) as visits
,sum(b.sell_val_nsp- b.sell_val_nnbp)  as margin
from chnccp_msi_z.lifecycle_reactivation_data a
inner  join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj  b
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
where b.fsd_ind = 'N' and b.wel_ind = 'N' and b.deli_ind = 'N' and b.bvs_ind = 'N' and b.pcr_ind = 'N'
and CAST(a.active_date AS DATE) between '2020-05-15' and '2020-05-21'
and b.date_of_day between '2020-05-21' and '2020-06-03'
and a.coupon_use_status is not null and a.campaign_type = 'reactivation'
group by 1,2,3,4
order by 1,2,3,4;


--wave1
--ttl redeemed
select a.campaign_type,a.type_id,a.gcn,a.coupon_type
,count(distinct b.home_store_id || b.cust_no || b.auth_person_id) as buyer
,sum(b.sell_val_nsp) as net_sales
,count (distinct b.home_store_id || b.cust_no || b.auth_person_id || b.date_of_day) as visits
,sum(b.sell_val_nsp- b.sell_val_nnbp)  as margin
from chnccp_msi_z.lifecycle_reactivation_data  a
inner  join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj  b
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
inner join  chnccp_dwh.dw_gcn_campaign_event  c
on STRTOK(a.epc, ':', 5) = c.sgcn_no
where a.coupon_use_status is not null and a.campaign_type = 'reactivation'
and CAST(a.active_date AS DATE) between '2020-05-15' and '2020-05-21'
and b.fsd_ind = 'N' and b.wel_ind = 'N' and b.deli_ind = 'N' and b.bvs_ind = 'N' and b.pcr_ind = 'N'
and c.gcn_disposition = 'redeemed'
and b.date_of_day = c.gcn_event_date
group by 1,2,3,4
order by 1,2,3,4;


--control1
select a.campaign_type,a.type_id, a.coupon_type
,count(distinct b.home_store_id || b.cust_no || b.auth_person_id) as buyer
,sum(b.sell_val_nsp)  as net_sales
,count (distinct b.home_store_id || b.cust_no || b.auth_person_id || b.date_of_day) as visits
,sum(b.sell_val_nsp- b.sell_val_nnbp)  as margin
from chnccp_msi_z.lifecycle_reactivation_data a 
inner join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj  b
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
where a.coupon_use_status is null 
and b.fsd_ind = 'N' and b.wel_ind = 'N' and b.deli_ind = 'N' and b.bvs_ind = 'N' and b.pcr_ind = 'N'
and b.date_of_day between '2020-05-21' and '2020-06-03'
group by 1,2,3
order by 1,2,3;
------------------------
--wave2
-----ttl
select a.campaign_type,a.type_id,a.gcn,a.coupon_type
,count(distinct b.home_store_id || b.cust_no || b.auth_person_id) as buyer
,sum(b.sell_val_nsp)  as net_sales
,count (distinct b.home_store_id || b.cust_no || b.auth_person_id || b.date_of_day) as visits
,sum(b.sell_val_nsp- b.sell_val_nnbp)  as margin
from chnccp_msi_z.lifecycle_reactivation_data a
inner  join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj  b
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
where b.fsd_ind = 'N' and b.wel_ind = 'N' and b.deli_ind = 'N' and b.bvs_ind = 'N' and b.pcr_ind = 'N'
and CAST(a.active_date AS DATE) between '2020-05-22' and '2020-06-03'
and b.date_of_day between '2020-05-22' and '2020-06-03'
and a.coupon_use_status is not null and a.campaign_type = 'reactivation'
group by 1,2,3,4
order by 1,2,3,4;


--wave2
--ttl redeemed
select a.campaign_type,a.type_id,a.gcn,a.coupon_type
,count(distinct b.home_store_id || b.cust_no || b.auth_person_id) as buyer
,sum(b.sell_val_nsp) as net_sales
,count (distinct b.home_store_id || b.cust_no || b.auth_person_id || b.date_of_day) as visits
,sum(b.sell_val_nsp- b.sell_val_nnbp)  as margin
from chnccp_msi_z.lifecycle_reactivation_data  a
inner  join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj  b
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
inner join  chnccp_dwh.dw_gcn_campaign_event  c
on STRTOK(a.epc, ':', 5) = c.sgcn_no
where a.coupon_use_status is not null and a.campaign_type = 'reactivation'
and CAST(a.active_date AS DATE) between '2020-05-22' and '2020-06-03'
and b.fsd_ind = 'N' and b.wel_ind = 'N' and b.deli_ind = 'N' and b.bvs_ind = 'N' and b.pcr_ind = 'N'
and c.gcn_disposition = 'redeemed'
and b.date_of_day = c.gcn_event_date
group by 1,2,3,4
order by 1,2,3,4;


--control2
select a.campaign_type,a.type_id, a.coupon_type
,count(distinct b.home_store_id || b.cust_no || b.auth_person_id) as buyer
,sum(b.sell_val_nsp)  as net_sales
,count (distinct b.home_store_id || b.cust_no || b.auth_person_id || b.date_of_day) as visits
,sum(b.sell_val_nsp- b.sell_val_nnbp)  as margin
from chnccp_msi_z.lifecycle_reactivation_data a 
inner join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj  b
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
where a.coupon_use_status is null 
and b.fsd_ind = 'N' and b.wel_ind = 'N' and b.deli_ind = 'N' and b.bvs_ind = 'N' and b.pcr_ind = 'N'
and b.date_of_day between '2020-05-27' and '2020-06-03'
group by 1,2,3
order by 1,2,3;


