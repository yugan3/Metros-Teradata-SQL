--选品

-- ttl customer / umc+

-- potention/ umc+   
drop table chnccp_msi_z.abby_potentioal_umc;
create table chnccp_msi_z.abby_potentioal_umc
as (
select distinct a.home_store_id,a.cust_no,a.auth_person_id
from (
select a.home_store_id,a.cust_no,a.auth_person_id  from  chnccp_crm.UMC_scoring_result a 
group by 1,2,3
having max(cast(Tencent_Model_Plan4_Score as float)) >= 8
union
select a.home_store_id,a.cust_no,a.auth_person_id
from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj a
where a.date_of_day between '2019-07-01' and '2019-07-31'
and a.fsd_ind = 'N' and a.wel_ind = 'N' and a.deli_ind = 'N' and a.bvs_ind = 'N' and a.pcr_ind = 'N'
group by 1,2,3
having sum(sell_val_gsp) / count(distinct a.invoice_id) between 400 and 1000
) a
) with data;

-- ttl buyer
drop table chnccp_msi_z.abby_py;
create table chnccp_msi_z.abby_py
as (
select a.home_store_id,a.cust_no,a.auth_person_id
,sum( a.sell_val_gsp) as gross_sales
,1.0000 * count(distinct a.invoice_id)  as fre
from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj  a
inner join chnccp_dwh.dw_customer b
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no
inner join  chnccp_msi_z.abby_potentioal_umc c --inner join conditon for umc+ users
on a.home_store_id = c.home_store_id and a.cust_no = c.cust_no and a.auth_person_id = c.auth_person_id--inner join conditon for umc+ users
where a.wel_ind = 'N' and a.fsd_ind = 'N' and a.pcr_ind = 'N' and a.bvs_ind = 'N' and a.deli_ind = 'N'
and a.store_id in (20,59,11,40,41,54,60,62,66,67,76,105,179)
and a.date_of_day between  '2019-07-01' and '2019-07-31'
and b.branch_id in (401,492,488,971,972)
group by 1,2,3
) with data;

--64,830
select count(distinct a.home_store_id || a.cust_no || a.auth_person_id) as buyer
from chnccp_msi_z.abby_py a;

-- pcg_main_cat_id
drop table chnccp_msi_z.abby_pcg_main_cat_py;
create table chnccp_msi_z.abby_pcg_main_cat_py
as (
select c.fnf_desc,c.demand_field_domain_id,c.demand_field_domain_desc
,c.pcg_main_cat_id, c.pcg_main_cat_desc
,0 as art_no,0 as mikg_art_no, 'total' as art_name
,count(distinct a.home_store_id || a.cust_no || a.auth_person_id) as buyer
,1.0000 * count(distinct a.home_store_id || a.cust_no || a.auth_person_id) / 55316 as buyer_pene
,sum( b.sell_val_gsp) as gross_sales
,0 as sales_pene
,1.0000 * count(distinct b.invoice_id) / count(distinct a.home_store_id || a.cust_no || a.auth_person_id)  as fre
,sum( sell_val_gsp)/count(distinct invoice_id) as cat_basket
,sum( sell_val_gsp)/sum(sell_qty_colli) as sales_price
,sum( sell_val_nsp - sell_val_nnbp) / sum(sell_val_nsp) as actual_margin
from chnccp_msi_z.abby_py a
inner join  chnccp_fls.view_frank_auth_person_invoice_line_channel_adj  b
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
inner join chnccp_dwh.dw_art_var_tu c
on b.art_no = c.art_no and b.var_tu_key = c.var_tu_key
where b.wel_ind = 'N' and b.fsd_ind = 'N' and b.pcr_ind = 'N' and b.bvs_ind = 'N' and b.deli_ind = 'N'
and b.store_id in (20,59,11,40,41,54,60,62,66,67,76,105,179)
and b.date_of_day between  '2019-07-01' and '2019-07-31'
group by 1,2,3,4,5,6,7,8
having sum(sell_qty_colli) > 0 and sum(sell_val_nsp) > 0
) with data;

-- mikg_art_no_ wallet 
drop table chnccp_msi_z.abby_art_py_wallet_py;
create table chnccp_msi_z.abby_art_py_wallet_py
as (
select a.mikg_art_no
,sum( b.sell_val_gsp)/ count(distinct b.invoice_id) as ttl_order_basket
,sum(a.gross_sales)/sum( b.sell_val_gsp) as wallet_pene
from (
	select c.fnf_desc,c.demand_field_domain_id,c.demand_field_domain_desc,c.pcg_main_cat_id, c.pcg_main_cat_desc,c.art_no,c.mikg_art_no, c.art_name
	,b.home_store_id,b.cust_no,b.auth_person_id
	,b.invoice_id
	,sum( b.sell_val_gsp) as gross_sales
	from  chnccp_msi_z.abby_py a
	inner join  chnccp_fls.view_frank_auth_person_invoice_line_channel_adj  b
	on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
	inner join chnccp_dwh.dw_art_var_tu c
	on b.art_no = c.art_no and b.var_tu_key = c.var_tu_key
	where b.wel_ind = 'N' and b.fsd_ind = 'N' and b.pcr_ind = 'N' and b.bvs_ind = 'N' and b.deli_ind = 'N'
	and b.store_id in (20,59,11,40,41,54,60,62,66,67,76,105,179)
	and b.date_of_day between '2019-07-01' and '2019-07-31'
	group by 1,2,3,4,5,6,7,8,9,10,11,12
) a
inner join chnccp_dwh.dw_cust_invoice  b
on a.invoice_id = b.invoice_id
group by 1
having sum( b.sell_val_gsp) > 0
) with data;

-- mikg_art_no
drop table chnccp_msi_z.abby_art_py;
create table chnccp_msi_z.abby_art_py
as (
select c.fnf_desc,c.demand_field_domain_id,c.demand_field_domain_desc
,c.pcg_main_cat_id, c.pcg_main_cat_desc
,c.art_no,c.mikg_art_no, c.art_name
,count(distinct a.home_store_id || a.cust_no || a.auth_person_id) as buyer
,1.0000 * count(distinct a.home_store_id || a.cust_no || a.auth_person_id) / 283917 as buyer_pene
,sum( b.sell_val_gsp) as gross_sales
,0 as sales_pene
,1.0000 * count(distinct b.invoice_id) / count(distinct a.home_store_id || a.cust_no || a.auth_person_id)  as fre
,sum( sell_val_gsp)/count(distinct invoice_id) as cat_basket
,sum( sell_val_gsp)/sum(sell_qty_colli) as sales_price
,sum( sell_val_nsp - sell_val_nnbp) / sum(sell_val_nsp) as actual_margin
from chnccp_msi_z.abby_py  a
inner join  chnccp_fls.view_frank_auth_person_invoice_line_channel_adj  b
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
inner join chnccp_dwh.dw_art_var_tu c
on b.art_no = c.art_no and b.var_tu_key = c.var_tu_key
where b.wel_ind = 'N' and b.fsd_ind = 'N' and b.pcr_ind = 'N' and b.bvs_ind = 'N' and b.deli_ind = 'N'
and b.store_id in (20,59,11,40,41,54,60,62,66,67,76,105,179)
and b.date_of_day between '2019-07-01' and '2019-07-31'
group by 1,2,3,4,5,6,7,8
having sum(sell_qty_colli) > 0 and sum(sell_val_nsp) > 0
) with data;

	select a.fnf_desc,a.demand_field_domain_id,a.demand_field_domain_desc
	,a.pcg_main_cat_id, a.pcg_main_cat_desc
	,a.art_no,a.mikg_art_no, a.art_name
	,a.buyer,a.buyer_pene
	,a.gross_sales,a.gross_sales / b.gross_sales as sales_pene
	,a.fre,a.cat_basket,c.ttl_order_basket,c.wallet_pene,a.sales_price,a.actual_margin
	from chnccp_msi_z.abby_art_py a
	left join chnccp_msi_z.abby_pcg_main_cat_py b
	on a.pcg_main_cat_id = b.pcg_main_cat_id
	left join  chnccp_msi_z.abby_art_py_wallet_py c
	on a.mikg_art_no = c.mikg_art_no
	where a.demand_field_domain_id not in (447,635,599)
	order by a.buyer desc;


