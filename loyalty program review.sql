--------------------------------total points redeemed
--from 2019-06-01 to 2020-05-31
SEL c.month_id,
SUM(CASE WHEN a.loy_pts_item_accrual_row_id IS NULL THEN a.loy_item_num_trans_pts ELSE 0 end ) AS pts_collected ,
SUM ( CASE WHEN a.loy_pts_item_accrual_row_id IS NOT NULL  AND a.loy_pts_item_type_cd = 66404 THEN loy_item_num_trans_pts ELSE 0 end ) AS  pts_used
--sum( case when a.loy_pts_item_accrual_row_id is not null  and a.loy_pts_item_type_cd = 66929 then loy_item_num_trans_pts else 0 end ) as  pts_expired
FROM chnccp_dwh.dw_mcrm_loy_pts_items a
INNER JOIN chnccp_dwh.dw_mcrm_loy_member b
ON a.loy_mem_row_id=b.loy_mem_row_id AND  b.loy_mem_parent_ind=0
INNER JOIN chnccp_dwh.dw_time_day c
ON a.loy_pts_item_trans_date=c.date_of_day
where c.month_id in(201906, 201907, 201908, 201909, 201910,201911,201912,202001,202002,202003,202004,202005)
group by c.month_id;


---------------------------------flash redemption
--duck
drop table chnccp_msi_z.flash_redemtpion_duck;
create table chnccp_msi_z.flash_redemtpion_duck
	as(select a.gcn_no, a.sgcn_no, a.gcn_event_date, a.gcn_disposition from chnccp_dwh.dw_gcn_campaign_event a
		join chnccp_msi_z.redemption b
		on a.gcn_no = b.campaign_id
		where b.art_name like '%小黄鸭%'
		)with data;

select gcn_no, 
CASE WHEN gcn_no = 6947890910047 THEN count(gcn_no)*2
     WHEN gcn_no = 6947890910054 THEN count(gcn_no)*2*2
     WHEN gcn_no = 6947890910061 THEN count(gcn_no)*2*3
     WHEN gcn_no = 6947890910078 THEN count(gcn_no)*2
     WHEN gcn_no = 6947890910085 THEN count(gcn_no)*2*2
     WHEN gcn_no = 6947890910108 THEN count(gcn_no)*2*3
     WHEN gcn_no = 6947890910115 THEN count(gcn_no)*2
     WHEN gcn_no = 6947890910122 THEN count(gcn_no)*2*2
     WHEN gcn_no = 6947890910139 THEN count(gcn_no)*2*3 END AS duck_redemption_points from chnccp_msi_z.flash_redemtpion_duck
     where gcn_disposition = 'redeemable'
     group by gcn_no;

--beer
drop table chnccp_msi_z.flash_redemtpion_beer;
create table chnccp_msi_z.flash_redemtpion_beer
	as(select a.gcn_no, a.sgcn_no, a.gcn_event_date, a.gcn_disposition from chnccp_dwh.dw_gcn_campaign_event a
		join chnccp_msi_z.redemption b
		on a.gcn_no = b.campaign_id
		where b.campaign_id in (6947890908723,6947890908730)
		)with data;

select gcn_no, 
CASE WHEN gcn_no = 6947890908723 THEN count(gcn_no)*2
     WHEN gcn_no = 6947890908730 THEN count(gcn_no)*2 END AS beer_redemption_points from chnccp_msi_z.flash_redemtpion_beer
     where gcn_disposition = 'redeemable'
     group by gcn_no;

---------------------------------KA redemption
--KA
drop table chnccp_msi_z.flash_redemtpion_KA;
create table chnccp_msi_z.flash_redemtpion_KA
	as(select a.gcn_no, a.sgcn_no, a.gcn_event_date, a.gcn_disposition from chnccp_dwh.dw_gcn_campaign_event a
		join chnccp_msi_z.redemption b
		on a.gcn_no = b.campaign_id
		where b."type" = 'KA'
		)with data;

select a.gcn_no, 
CASE WHEN a.gcn_no = 6947890909638 THEN count(a.gcn_no) *25
     WHEN a.gcn_no = 6947890909720 THEN count(a.gcn_no) *25
     WHEN a.gcn_no = 6947890909737 THEN count(a.gcn_no) *10
     WHEN a.gcn_no = 6947890909744 THEN count(a.gcn_no) *10
     WHEN a.gcn_no = 6947890909751 THEN count(a.gcn_no) *7
     WHEN a.gcn_no = 6947890909768 THEN count(a.gcn_no) *7
     WHEN a.gcn_no = 6947890909775 THEN count(a.gcn_no) *5
     WHEN a.gcn_no = 6947890909782 THEN count(a.gcn_no) *5
     WHEN a.gcn_no = 6947890910986 THEN count(a.gcn_no) *50
     WHEN a.gcn_no = 6947890911013 THEN count(a.gcn_no) *50
     WHEN a.gcn_no = 6947890910931 THEN count(a.gcn_no) *20
     WHEN a.gcn_no = 6947890910979 THEN count(a.gcn_no) *20
     WHEN a.gcn_no = 6947890910955 THEN count(a.gcn_no) *15
     WHEN a.gcn_no = 6947890910948 THEN count(a.gcn_no) *15
     WHEN a.gcn_no = 6947890911006 THEN count(a.gcn_no) *10
     WHEN a.gcn_no = 6947890910962 THEN count(a.gcn_no) *10 END AS KA_redemption_points from chnccp_msi_z.flash_redemtpion_KA a 
     where a.gcn_disposition = 'redeemable'
     group by a.gcn_no;


--KA invoice points:
select sum (
case 
when b.mikg_art_no=226093 and a.date_of_day = '2019-12-04' then a.sell_qty_colli *25
when b.mikg_art_no=226093 then a.sell_qty_colli *50
when b.mikg_art_no=226095  and a.date_of_day = '2019-12-04' then a.sell_qty_colli *25
when b.mikg_art_no=226095   then a.sell_qty_colli *50
when b.mikg_art_no=226096  and a.date_of_day = '2019-12-04' then a.sell_qty_colli *10
when b.mikg_art_no=226096   then a.sell_qty_colli *20
when b.mikg_art_no=226097  and a.date_of_day = '2019-12-04' then a.sell_qty_colli *10
when b.mikg_art_no=226097   then a.sell_qty_colli *20
when b.mikg_art_no=226098  and a.date_of_day = '2019-12-04' then a.sell_qty_colli *7
when b.mikg_art_no=226098  then  a.sell_qty_colli *15
when b.mikg_art_no=226099  and a.date_of_day = '2019-12-04' then a.sell_qty_colli *7
when b.mikg_art_no=226099   then a.sell_qty_colli *15
when b.mikg_art_no=226100  and a.date_of_day = '2019-12-04' then a.sell_qty_colli *5
when b.mikg_art_no=226100   then a.sell_qty_colli *10
when b.mikg_art_no=226101  and a.date_of_day = '2019-12-04' then a.sell_qty_colli *5
when b.mikg_art_no=226101  then a.sell_qty_colli *10
    else 0 end) as pionts_KA from chnccp_dwh.dw_cust_invoice_line a
join chnccp_dwh.dw_art_var_tu b
on a.art_no = b.art_no and a.var_tu_key = b.var_tu_key
where a.date_of_day between '2019-12-02' and '2020-05-31'
and b.mikg_art_no IN (226093,226095,226096,226097,226098,226099,226100,226101);

--duck invoice points:
select sum(
CASE WHEN a.cupr_action_id * 1000 + a.cupr_action_sequence_id = 195034150 THEN a.sell_qty_colli*2
 WHEN a.cupr_action_id * 1000 + a.cupr_action_sequence_id = 195034151 THEN a.sell_qty_colli*2*2
 WHEN a.cupr_action_id * 1000 + a.cupr_action_sequence_id = 195034152 THEN a.sell_qty_colli*2*3
 WHEN a.cupr_action_id * 1000 + a.cupr_action_sequence_id = 195034153 THEN a.sell_qty_colli*2
 WHEN a.cupr_action_id * 1000 + a.cupr_action_sequence_id = 195034154 THEN a.sell_qty_colli*2*2
 WHEN a.cupr_action_id * 1000 + a.cupr_action_sequence_id = 195034155 THEN a.sell_qty_colli*2*3
 WHEN a.cupr_action_id * 1000 + a.cupr_action_sequence_id = 195034157 THEN a.sell_qty_colli*2
 WHEN a.cupr_action_id * 1000 + a.cupr_action_sequence_id = 195034158 THEN a.sell_qty_colli*2*2
 WHEN a.cupr_action_id * 1000 + a.cupr_action_sequence_id = 195034159 THEN a.sell_qty_colli*2*3 ELSE 0 END) as points_duck from chnccp_dwh.dw_cust_invoice_line a
join chnccp_dwh.dw_art_var_tu b
on a.art_no = b.art_no and a.var_tu_key = b.var_tu_key
where a.date_of_day between '2019-12-24' and '2020-01-04'
and b.mikg_art_no IN (227268, 227267, 227269);

select sum(
CASE WHEN b.mikg_art_no = 227269 THEN a.sell_qty_colli*2
     WHEN b.mikg_art_no = 227268 THEN a.sell_qty_colli*10
     WHEN b.mikg_art_no = 227267 THEN a.sell_qty_colli*4
  ELSE 0 END) as points_duck from chnccp_dwh.dw_cust_invoice_line a
join chnccp_dwh.dw_art_var_tu b
on a.art_no = b.art_no and a.var_tu_key = b.var_tu_key
where a.date_of_day between '2019-12-24' and '2020-01-04'
and b.mikg_art_no IN (227268, 227267, 227269);

--beer:
select sum(
CASE WHEN b.mikg_art_no = 214604 THEN a.sell_qty_colli*2
     WHEN b.mikg_art_no = 220847 THEN a.sell_qty_colli*2
  ELSE 0 END) as points_beer from chnccp_dwh.dw_cust_invoice_line a
join chnccp_dwh.dw_art_var_tu b
on a.art_no = b.art_no and a.var_tu_key = b.var_tu_key
where a.date_of_day between '2019-09-24' and '2019-10-08'
and b.mikg_art_no IN (214604, 220847);

--maotia&huawei
select sum(
CASE WHEN b.mikg_art_no = 224338 THEN a.sell_qty_colli*1000
     WHEN b.mikg_art_no = 224189 THEN a.sell_qty_colli*2500
  ELSE 0 END) as points_maohua from chnccp_dwh.dw_cust_invoice_line a
join chnccp_dwh.dw_art_var_tu b
on a.art_no = b.art_no and a.var_tu_key = b.var_tu_key
where a.date_of_day between '2019-04-01' and '2020-05-31'
and b.mikg_art_no IN (224338, 224189);



---------------------------------Advance redemption
drop table chnccp_msi_z.Advance_redemtpion;
create table chnccp_msi_z.Advance_redemtpion
	as(select * from ((select a."time", a.art_name, a.mikg_art_no, sum(b.sell_qty_colli) as qty from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_dwh.dw_cust_invoice_line b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."time" ='20190401-20190930'
		and b.date_of_day between '2019-06-01' and '2019-09-30'
		group by a."time", a.art_name,a.mikg_art_no)
		Union 
		(select a."time", a.art_name,a.mikg_art_no, sum(b.sell_qty_colli) as qty from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_dwh.dw_cust_invoice_line b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."time" ='20191001-20200630'
		and b.date_of_day between '2019-10-01' and '2020-05-31'
		group by a."time", a.art_name,a.mikg_art_no)) a )with data;

select a.mikg_art_no, a.art_name, a."time" , b.qty*a.redemption_points as advace_redemption_points from chnccp_msi_z.redemption a 
join chnccp_msi_z.Advance_redemtpion b 
on a.mikg_art_no = b.mikg_art_no;



--maotai & huawei
drop table chnccp_msi_z.Advance_redemtpion_maoandhua;
create table chnccp_msi_z.Advance_redemtpion_maoandhua
	as(select a.gcn_no, a.sgcn_no, a.gcn_event_date, a.gcn_disposition from chnccp_dwh.dw_gcn_campaign_event a
		join chnccp_msi_z.redemption b
		on a.gcn_no = b.campaign_id
		where b.campaign_id in(6947890908877, 6947890908884, 6947890908877, 6947890910894)
		)with data;

select b.gcn_no, 
    CASE WHEN b.gcn_no in (6947890908877, 6947890908877) THEN count(b.gcn_no) *1000
         WHEN b.gcn_no in (6947890908884, 6947890910894) THEN count(b.gcn_no) *2500
         END AS redemption_points from chnccp_msi_z.Advance_redemtpion_maoandhua b 
         group by b.gcn_no;


---------------------------------Monthly redemption
drop table chnccp_msi_z.Monthly_redemption;
create table chnccp_msi_z.Monthly_redemption
	as(select tt.* from (
		(select a."time", a.art_name, a.mikg_art_no, sum(b.sell_qty_colli) as qty from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_dwh.dw_cust_invoice_line b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."time" ='201906'
		and b.date_of_day between '2019-06-01' and '2019-06-30'
		group by a."time", a.art_name, a.mikg_art_no)
		Union
		(select a."time", a.art_name, a.mikg_art_no, sum(b.sell_qty_colli) as qty from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_dwh.dw_cust_invoice_line b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."time" ='201907'
		and b.date_of_day between '2019-07-01' and '2019-07-31'
		group by a."time", a.art_name, a.mikg_art_no)
		Union
		(select a."time", a.art_name, a.mikg_art_no, sum(b.sell_qty_colli) as qty from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_dwh.dw_cust_invoice_line b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."time" ='201908'
		and b.date_of_day between '2019-08-01' and '2019-08-31'
		group by a."time", a.art_name, a.mikg_art_no)
		Union
		(select a."time", a.art_name, a.mikg_art_no, sum(b.sell_qty_colli) as qty from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_dwh.dw_cust_invoice_line b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."time" ='201909'
		and b.date_of_day between '2019-09-01' and '2019-09-30'
		group by a."time", a.art_name,  a.mikg_art_no)
		Union
		(select a."time", a.art_name, a.mikg_art_no, sum(b.sell_qty_colli) as qty from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_dwh.dw_cust_invoice_line b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."time" ='201910'
		and b.date_of_day between '2019-10-01' and '2019-10-31'
		group by a."time", a.art_name,  a.mikg_art_no)
		Union
		(select a."time", a.art_name, a.mikg_art_no, sum(b.sell_qty_colli) as qty from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_dwh.dw_cust_invoice_line b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."time" ='201911'
		and b.date_of_day between '2019-11-01' and '2019-11-30'
		group by a."time", a.art_name,  a.mikg_art_no)
		Union
		(select a."time", a.art_name, a.mikg_art_no, sum(b.sell_qty_colli) as qty from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_dwh.dw_cust_invoice_line b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."time" ='201912'
		and b.date_of_day between '2019-12-01' and '2019-12-31'
		group by a."time", a.art_name,  a.mikg_art_no)
		Union
		(select a."time", a.art_name, a.mikg_art_no, sum(b.sell_qty_colli) as qty from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_dwh.dw_cust_invoice_line b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."time" ='202001'
		and b.date_of_day between '2020-01-01' and '2020-01-31'
		group by a."time", a.art_name,  a.mikg_art_no)
		Union
        (select a."time", a.art_name, a.mikg_art_no, sum(b.sell_qty_colli) as qty from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_dwh.dw_cust_invoice_line b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."time" ='202002-03'
		and b.date_of_day between '2020-02-01' and '2020-03-31'
		group by a."time", a.art_name,  a.mikg_art_no)
		Union
		(select a."time", a.art_name, a.mikg_art_no, sum(b.sell_qty_colli) as qty from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_dwh.dw_cust_invoice_line b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."time" ='202004'
		and b.date_of_day between '2020-04-01' and '2020-04-30'
		group by a."time", a.art_name, a.mikg_art_no)
		Union
		(select a."time", a.art_name, a.mikg_art_no, sum(b.sell_qty_colli) as qty from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_dwh.dw_cust_invoice_line b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."time" ='202005'
		and b.date_of_day between '2020-05-01' and '2020-05-31'
		group by a."time", a.art_name, a.mikg_art_no)	)tt
		)with data;


select b.mikg_art_no, b.art_name, b."time", b.qty*a.redemption_points as monthly_redemption_points from chnccp_msi_z.Monthly_redemption b
left join chnccp_msi_z.redemption a 
on a.mikg_art_no = b.mikg_art_no;

---------------------------------------sales
--CY: 2019-06-01 to 2020-05-31
/*drop table chnccp_msi_z.LP_sales;
create table chnccp_msi_z.LP_sales
	as(
SELECT t.home_store_id, t.cust_no, t.auth_person_id, 
CASE WHEN net_sales/8 >= 40000 THEN '01) A'
     WHEN net_sales/8 >= 10000 AND net_sales/8 < 40000 THEN '02) B'
	 WHEN net_sales/8 >  0 AND net_sales/8 < 10000 THEN '03) C' ELSE '04) NN' END AS ABC_combined,
	 CASE WHEN net_sales/8 >= 250000 THEN '01) A1'
		  WHEN net_sales/8 >= 100000 AND net_sales/8 < 250000 THEN '02) A2'
		  WHEN net_sales/8 >= 70000 AND net_sales/8 < 100000 THEN '03) A3'
          WHEN net_sales/8 >= 40000 AND net_sales/8 < 70000  THEN '04) A4'
          WHEN net_sales/8 >= 30000 AND net_sales/8 < 40000 THEN '05) B1'
          WHEN net_sales/8 >= 20000 AND net_sales/8 < 30000 THEN '06) B2'
          WHEN net_sales/8 >= 15000 AND net_sales/8 < 20000 THEN '07) B3'
          WHEN net_sales/8 >= 10000 AND net_sales/8 < 15000 THEN '08) B4'
          WHEN net_sales/8 >= 6000  AND net_sales/8 < 10000 THEN '09) C1'
          WHEN net_sales/8 >= 4000  AND net_sales/8 < 6000  THEN '10) C2'
          WHEN net_sales/8 >= 2000  AND net_sales/8 < 4000  THEN '11) C3'
          WHEN net_sales/8 >= 1000  AND net_sales/8 < 2000  THEN '12) C4'
          WHEN net_sales/8 >= 500   AND net_sales/8 < 1000  THEN '13) C5'
          WHEN net_sales/8 >= 100   AND net_sales/8 < 500   THEN '14) C6'
          WHEN net_sales/8 >  0     AND net_sales/8 < 100   THEN '15) C7' ELSE '16) NN' END AS ABC,
          CASE WHEN c.cust_assort_section_id IS IN (1) THEN '1) HoReCa'
               WHEN c.cust_assort_section_id IS IN (3) THEN '2) Trader'
               WHEN c.cust_assort_section_id IS IN (5, 7) AND c.branch_id = 982 THEN '3) SCO - daypass'
               WHEN c.cust_assort_section_id IS IN (5, 7) AND c.branch_id IN (401,492,488,971,972,973,493) THEN '3) SCO - FoM'
               WHEN c.cust_assort_section_id IS IN (5, 7) AND c.branch_id NOT IN (401,492,488,971,972,982.973,493) THEN '3) SCO - w/o FoM'
               ELSE '4) Undefined' end as branch,
                        SUM(d.sell_val_nsp) AS net_sales, count(DISTINCT d.invoice_id) AS visit, SUM(d.sell_val_nsp) - SUM(d.sell_val_nnbp) AS front_margin
                        FROM chnccp_dwh.dw_mcrm_loy_member t 
                        left join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj d 
                        on d.home_store_id = t.home_store_id and t.cust_no = d.cust_no and d.auth_person_id = t.cust_no
                        left join chnccp_dwh.dw_customer b
                        on t.home_store_id = b.home_store_id and t.cust_no = b.cust_no
                        left join chnccp_dwh.dw_cust_branch c
                        on b.branch_id = c.branch_id
                        where d.date_of_day between '2019-06-01' and '2020-05-31'
                        and t.loy_mem_parent_ind = 0 AND t.loy_mem_join_date IS NOT NULL
                        group by t.home_store_id, t.cust_no, t.auth_person_id, branch
                        having net_sales > 0) with data;*/


---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------sales
---2019-06-01 to 2020-05-31
--with vcp
drop table chnccp_msi_z.LP_namelist;
create table chnccp_msi_z.LP_namelist
	as(select a.home_store_id, a.cust_no,a.auth_person_id,
		CASE WHEN (d.bvs_ind = 'N' AND d.pcr_ind = 'N' AND d.deli_ind = 'N' AND d.wel_ind = 'Y' AND (d.fsd_ind = 'Y' OR d.fsd_ind = 'N')) THEN '1) welfare cash and carry'
             WHEN (d.wel_ind = 'Y' AND (d.bvs_ind = 'Y' OR d.pcr_ind = 'Y' OR d.deli_ind = 'Y')) THEN '2) welfare deals'
             WHEN (d.wel_ind = 'N' AND d.fsd_ind = 'Y' ) THEN '3) fsd'
             WHEN (d.bvs_ind = 'N' AND d.pcr_ind = 'N' AND d.deli_ind = 'N' AND d.wel_ind = 'N' AND d.fsd_ind = 'N') THEN '4) o2o cash and carry'
             WHEN ((d.bvs_ind = 'Y'  OR d.pcr_ind = 'Y' OR d.deli_ind = 'Y' ) AND (d.wel_ind = 'N'  AND d.fsd_ind = 'N' )) THEN '5) o2o deals'
             ELSE '6) undefined' END AS vcp,
             CASE WHEN c.cust_assort_section_id IS IN (1) THEN '1) HoReCa'
                  WHEN c.cust_assort_section_id IS IN (3) THEN '2) Trader'
                  WHEN c.cust_assort_section_id IS IN (5, 7) AND c.branch_id = 982 THEN '3) SCO - daypass'
                  WHEN c.cust_assort_section_id IS IN (5, 7) AND c.branch_id IN (401,492,488,971,972,973,493) THEN '3) SCO - FoM'
                  WHEN c.cust_assort_section_id IS IN (5, 7) AND c.branch_id NOT IN (401,492,488,971,972,982.973,493) THEN '3) SCO - w/o FoM'
                  ELSE '4) Undefined' end as branch
               from chnccp_dwh.dw_mcrm_loy_member a
               join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj d
               on a.home_store_id = d.home_store_id and a.cust_no = d.cust_no and a.auth_person_id = d.auth_person_id
               join chnccp_dwh.dw_customer b
               on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no
               join chnccp_dwh.dw_cust_branch c
               on b.branch_id = c.branch_id
               where d.date_of_day between '2019-06-01' and '2020-05-31'
               and a.loy_mem_parent_ind = 0 and a.loy_mem_join_date is not null
               group by a.home_store_id, a.cust_no,a.auth_person_id,VCP, branch
               )with data;

--no vcp
drop table chnccp_msi_z.LP_namelist_1;
create table chnccp_msi_z.LP_namelist_1
	as(select a.home_store_id, a.cust_no,a.auth_person_id,
             CASE WHEN c.cust_assort_section_id IS IN (1) THEN '1) HoReCa'
                  WHEN c.cust_assort_section_id IS IN (3) THEN '2) Trader'
                  WHEN c.cust_assort_section_id IS IN (5, 7) AND c.branch_id = 982 THEN '3) SCO - daypass'
                  WHEN c.cust_assort_section_id IS IN (5, 7) AND c.branch_id IN (401,492,488,971,972,973,493) THEN '3) SCO - FoM'
                  WHEN c.cust_assort_section_id IS IN (5, 7) AND c.branch_id NOT IN (401,492,488,971,972,982.973,493) THEN '3) SCO - w/o FoM'
                  ELSE '4) Undefined' end as branch
               from chnccp_dwh.dw_mcrm_loy_member a
               join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj d
               on a.home_store_id = d.home_store_id and a.cust_no = d.cust_no and a.auth_person_id = d.auth_person_id
               join chnccp_dwh.dw_customer b
               on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no
               join chnccp_dwh.dw_cust_branch c
               on b.branch_id = c.branch_id
               where d.date_of_day between '2019-06-01' and '2020-05-31'
               and a.loy_mem_parent_ind = 0 and a.loy_mem_join_date is not null
               group by a.home_store_id, a.cust_no,a.auth_person_id, branch
               )with data;


drop table chnccp_msi_z.LP_namelist_abc;
create table chnccp_msi_z.LP_namelist_abc
	as(select a.home_store_id, a.cust_no, a.auth_person_id,
		CASE WHEN net_sales/8 >= 6000 THEN '01) A1-C1'
             WHEN net_sales/8 >= 500 AND net_sales/8 < 6000 THEN '02) C2-C5'
	         WHEN net_sales/8 >= 100 AND net_sales/8 < 500 THEN '03) C6' 
	         WHEN net_sales/8 > 0 AND net_sales/8 < 100 THEN '04) C7' ELSE '05) NN' END AS ABC_combined,
	         CASE WHEN net_sales/8 >= 250000 THEN '01) A1'
		          WHEN net_sales/8 >= 100000 AND net_sales/8 < 250000 THEN '02) A2'
		          WHEN net_sales/8 >= 70000 AND net_sales/8 < 100000 THEN '03) A3'
                  WHEN net_sales/8 >= 40000 AND net_sales/8 < 70000  THEN '04) A4'
                  WHEN net_sales/8 >= 30000 AND net_sales/8 < 40000 THEN '05) B1'
                  WHEN net_sales/8 >= 20000 AND net_sales/8 < 30000 THEN '06) B2'
                  WHEN net_sales/8 >= 15000 AND net_sales/8 < 20000 THEN '07) B3'
                  WHEN net_sales/8 >= 10000 AND net_sales/8 < 15000 THEN '08) B4'
                  WHEN net_sales/8 >= 6000  AND net_sales/8 < 10000 THEN '09) C1'
                  WHEN net_sales/8 >= 4000  AND net_sales/8 < 6000  THEN '10) C2'
                  WHEN net_sales/8 >= 2000  AND net_sales/8 < 4000  THEN '11) C3'
                  WHEN net_sales/8 >= 1000  AND net_sales/8 < 2000  THEN '12) C4'
                  WHEN net_sales/8 >= 500   AND net_sales/8 < 1000  THEN '13) C5'
                  WHEN net_sales/8 >= 100   AND net_sales/8 < 500   THEN '14) C6'
                  WHEN net_sales/8 >  0     AND net_sales/8 < 100   THEN '15) C7' ELSE '16) NN' END AS ABC,
                  SUM(a.sell_val_nsp) AS net_sales, count(DISTINCT a.invoice_id) AS visit, SUM(a.sell_val_nsp) - SUM(a.sell_val_nnbp) AS front_margin 
                  from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj a 
                  where a.date_of_day between '2019-06-01' and '2020-05-31'
                  group by a.home_store_id, a.cust_no, a.auth_person_id
                  having net_sales >0
                  )with data;

--with vcp
drop table chnccp_msi_z.LP_namelist_total;
create table chnccp_msi_z.LP_namelist_total
	as(select a.ABC_combined, a.ABC, b.VCP, b.branch, a.home_store_id, a.cust_no, a.auth_person_id, a.net_sales, a.visit, a.front_margin from chnccp_msi_z.LP_namelist b 
		join chnccp_msi_z.LP_namelist_abc a
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		)with data;

--no vcp
drop table chnccp_msi_z.LP_namelist_total_1;
create table chnccp_msi_z.LP_namelist_total_1
	as(select a.ABC_combined, a.ABC, b.branch, a.home_store_id, a.cust_no, a.auth_person_id, a.net_sales, a.visit, a.front_margin from chnccp_msi_z.LP_namelist_1 b 
		join chnccp_msi_z.LP_namelist_abc a
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		)with data;


---------------------------------------redemption
--total redemption points
drop table chnccp_msi_z.LP_namelist_points;
create table chnccp_msi_z.LP_namelist_points
	as(select a.home_store_id, a.cust_no, a.auth_person_id, 
		SUM(e.loy_mem_num_available_pts) as balance_points,
		SUM(CASE WHEN c.loy_pts_item_accrual_row_id IS NULL THEN c.loy_item_num_trans_pts ELSE 0 end ) AS pts_collected,
		SUM(CASE WHEN c.loy_pts_item_accrual_row_id IS NOT NULL AND c.loy_pts_item_type_cd = 66404 THEN loy_item_num_trans_pts ELSE 0 END) AS pts_used
		from chnccp_dwh.dw_mcrm_loy_member a 
		join chnccp_dwh.dw_mcrm_loy_pts_items c 
		on c.loy_mem_row_id = a.loy_mem_row_id
		join chnccp_dwh.dw_time_day d
		ON c.loy_pts_item_trans_date = d.date_of_day
		where d.month_id in(201906, 201907, 201908, 201909,201910, 201911, 201912, 202001, 202002, 202003, 202004, 202005, 202005)
		group by a.home_store_id, a.cust_no, a.auth_person_id
		)with data;


--monthly redemption
drop table chnccp_msi_z.LP_namelist_points_monthly;
create table chnccp_msi_z.LP_namelist_points_monthly
	as(select tt.home_store_id, tt.cust_no, tt.auth_person_id, sum(tt.points*a.redemption_points) as month_points from (
		(select b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no, sum(b.sell_qty_colli) as points from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key 
		where a."time" ='201906'
		and b.date_of_day between '2019-06-01' and '2019-06-30'
		group by b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no)
		Union 
		(select b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no, sum(b.sell_qty_colli) as points from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."time" ='201907'
		and b.date_of_day between '2019-07-01' and '2019-07-31'
		group by b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no)
		Union 
		(select b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no, sum(b.sell_qty_colli) as points from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."time" ='201908'
		and b.date_of_day between '2019-08-01' and '2019-08-31'
		group by b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no)
		Union 
		(select b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no, sum(b.sell_qty_colli) as points from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."time" ='201909'
		and b.date_of_day between '2019-09-01' and '2019-09-30'
		group by b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no)
		Union 
		(select b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no, sum(b.sell_qty_colli) as points from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."time" ='201910'
		and b.date_of_day between '2019-10-01' and '2019-10-31'
		group by b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no)
		Union 
		(select b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no, sum(b.sell_qty_colli) as points from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."time" ='201911'
		and b.date_of_day between '2019-11-01' and '2019-11-30'
		group by b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no)
		Union 
		(select b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no, sum(b.sell_qty_colli) as points from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."time" ='201912'
		and b.date_of_day between '2019-12-01' and '2019-12-31'
		group by b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no)
		Union 
		(select b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no, sum(b.sell_qty_colli) as points from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."time" ='202001'
		and b.date_of_day between '2020-01-01' and '2020-01-31'
		group by b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no)
		Union 
        (select b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no, sum(b.sell_qty_colli) as points from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."time" ='202002-03'
		and b.date_of_day between '2020-02-01' and '2020-03-31'
		group by b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no)
		Union 
		(select b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no, sum(b.sell_qty_colli) as points from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."time" ='202004'
		and b.date_of_day between '2020-04-01' and '2020-04-30'
		group by b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no)
		Union 
		(select b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no, sum(b.sell_qty_colli) as points from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."time" ='202005'
		and b.date_of_day between '2020-05-01' and '2020-05-31'
		group by b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no) )tt
        join chnccp_msi_z.redemption a
        on a.mikg_art_no = tt.mikg_art_no
        group by tt.home_store_id, tt.cust_no, tt.auth_person_id
		)with data;

--advance redemption
drop table chnccp_msi_z.LP_namelist_points_advance;
create table chnccp_msi_z.LP_namelist_points_advance
	as(select tt.home_store_id, tt.cust_no, tt.auth_person_id, sum(tt.advance_points*a.redemption_points) as advance_points from ((select b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no, sum(b.sell_qty_colli) as advance_points from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c  
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."time" ='20190401-20190930'
		and b.date_of_day between '2019-06-01' and '2019-09-30'
		group by b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no)
		Union 
		(select b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no, sum(b.sell_qty_colli ) as advance_points from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."time" ='20191001-20200630'
		and b.date_of_day between '2019-10-01' and '2020-05-31'
		group by b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no)) tt 
	    join chnccp_msi_z.redemption a 
	    on a.mikg_art_no = tt.mikg_art_no
	    group by tt.home_store_id, tt.cust_no, tt.auth_person_id)with data;

--flash redemption
drop table chnccp_msi_z.LP_namelist_points_flash;
create table chnccp_msi_z.LP_namelist_points_flash
	as(select tt.home_store_id, tt.cust_no, tt.auth_person_id, sum(points_duck) as flash_points from ( (select a.home_store_id, a.cust_no, a.auth_person_id, b.mikg_art_no, 
		CASE WHEN b.mikg_art_no = 227269 THEN a.sell_qty_colli*2
             WHEN b.mikg_art_no = 227268 THEN a.sell_qty_colli*10
             WHEN b.mikg_art_no = 227267 THEN a.sell_qty_colli*4 ELSE 0 END as points_duck from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj a
	         join chnccp_dwh.dw_art_var_tu b
	         on a.art_no = b.art_no and a.var_tu_key = b.var_tu_key
	         where a.date_of_day between '2019-12-24' and '2020-01-04'
	         and b.mikg_art_no IN (227268, 227267, 227269))
	   Union ALL
	   (select a.home_store_id, a.cust_no, a.auth_person_id, b.mikg_art_no, 
		CASE WHEN b.mikg_art_no = 214604 THEN a.sell_qty_colli*2
             WHEN b.mikg_art_no = 220847 THEN a.sell_qty_colli*2 ELSE 0 END as points_duck from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj a
	         join chnccp_dwh.dw_art_var_tu b
	         on a.art_no = b.art_no and a.var_tu_key = b.var_tu_key
	         where a.date_of_day between '2019-09-24' and '2019-10-08'
             and b.mikg_art_no IN (214604, 220847))	)tt
	group by tt.home_store_id, tt.cust_no, tt.auth_person_id)with data;

--KA redemption

drop table chnccp_msi_z.LP_namelist_points_KA;
create table chnccp_msi_z.LP_namelist_points_KA
	as(select a.home_store_id, a.cust_no, a.auth_person_id,
		sum(case when b.mikg_art_no=226093 and a.date_of_day = '2019-12-04' then a.sell_qty_colli *25
		when b.mikg_art_no=226093 then a.sell_qty_colli *50
		when b.mikg_art_no=226095  and a.date_of_day = '2019-12-04' then a.sell_qty_colli *25
		when b.mikg_art_no=226095   then a.sell_qty_colli *50
		when b.mikg_art_no=226096  and a.date_of_day = '2019-12-04' then a.sell_qty_colli *10
		when b.mikg_art_no=226096   then a.sell_qty_colli *20
		when b.mikg_art_no=226097  and a.date_of_day = '2019-12-04' then a.sell_qty_colli *10
		when b.mikg_art_no=226097   then a.sell_qty_colli *20
		when b.mikg_art_no=226098  and a.date_of_day = '2019-12-04' then a.sell_qty_colli *7
		when b.mikg_art_no=226098  then  a.sell_qty_colli *15
		when b.mikg_art_no=226099  and a.date_of_day = '2019-12-04' then a.sell_qty_colli *7
		when b.mikg_art_no=226099   then a.sell_qty_colli *15
		when b.mikg_art_no=226100  and a.date_of_day = '2019-12-04' then a.sell_qty_colli *5
		when b.mikg_art_no=226100   then a.sell_qty_colli *10
		when b.mikg_art_no=226101  and a.date_of_day = '2019-12-04' then a.sell_qty_colli *5
		when b.mikg_art_no=226101  then a.sell_qty_colli *10 else 0 end) as pionts_KA from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj a
        join chnccp_dwh.dw_art_var_tu b
        on a.art_no = b.art_no and a.var_tu_key = b.var_tu_key
        where a.date_of_day between '2019-12-02' and '2020-05-31'
        and b.mikg_art_no IN (226093,226095,226096,226097,226098,226099,226100,226101)
        group by a.home_store_id, a.cust_no, a.auth_person_id)with data;



--total redemption
drop table chnccp_msi_z.LP_namelist_points_total;
create table chnccp_msi_z.LP_namelist_points_total
	as(select a.*, b.month_points, c.advance_points, d.flash_points, e.pionts_KA as KA_points from chnccp_msi_z.LP_namelist_points a 
		left join chnccp_msi_z.LP_namelist_points_monthly b 
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		left join chnccp_msi_z.LP_namelist_points_advance c
		on a.home_store_id = c.home_store_id and a.cust_no = c.cust_no and a.auth_person_id = c.auth_person_id
		left join chnccp_msi_z.LP_namelist_points_flash d 
		on a.home_store_id = d.home_store_id and a.cust_no = d.cust_no and a.auth_person_id = d.auth_person_id
		left join chnccp_msi_z.LP_namelist_points_KA e 
		on a.home_store_id = e.home_store_id and a.cust_no = e.cust_no and a.auth_person_id = e.auth_person_id)with data;

--balance points
drop table chnccp_msi_z.LP_namelist_points_balance;
create table chnccp_msi_z.LP_namelist_points_balance
	as(select a.home_store_id, a.cust_no, a.auth_person_id, sum(b.loy_mem_num_available_pts) as balance_points from chnccp_dwh.dw_mcrm_loy_member a 
		join chnccp_dwh.dw_mcrm_loy_mem_balance b
		on a.loy_mem_row_id = b.loy_mem_row_id
		group by a.home_store_id, a.cust_no, a.auth_person_id
		)with data;

--sales and redemption
--vcp
/*drop table chnccp_msi_z.LP_sales_and_redemption;
create table chnccp_msi_z.LP_sales_and_redemption
	as(select a.*, b.pts_collected, b.pts_used, b.month_points, b.advance_points, b.flash_points, b.KA_points from chnccp_msi_z.LP_namelist_total a 
		left join chnccp_msi_z.LP_namelist_points_total b
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		)with data;

select ABC, sum(net_sales) as  sales, avg(visit) as visit, sum(front_margin) as front_margin, count(distinct home_store_id||cust_no||auth_person_id) as cust, 
sum(pts_collected) as collected_points, count(distinct CASE WHEN pts_collected >0 THEN home_store_id||cust_no||auth_person_id ELSE NULL END) as collected_cust,
sum(pts_used) as pts_used, count(distinct CASE WHEN pts_used >0 THEN home_store_id||cust_no||auth_person_id ELSE NULL END) as used_cust,
sum(month_points) as month_points, sum(advance_points) as advance_points, sum(flash_points) as flash_points, sum(KA_points) as KA_points from chnccp_msi_z.LP_sales_and_redemption
group by ABC
order by ABC;*/

--1 no vcp
drop table chnccp_msi_z.LP_sales_and_redemption_1;
create table chnccp_msi_z.LP_sales_and_redemption_1
	as(select a.*, c.balance_points, b.pts_collected, b.pts_used, b.month_points, b.advance_points, b.flash_points, b.KA_points from chnccp_msi_z.LP_namelist_total_1 a 
		left join chnccp_msi_z.LP_namelist_points_total b
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		left join chnccp_msi_z.LP_namelist_points_balance c 
		on c.home_store_id = a.home_store_id and a.cust_no = c.cust_no and a.auth_person_id = c.auth_person_id
		)with data;

select ABC, ABC_combined, branch, sum(net_sales) as  sales, sum(visit) as visit, sum(front_margin) as front_margin, count(distinct home_store_id||cust_no||auth_person_id) as cust, 
sum(pts_collected) as collected_points, count(distinct CASE WHEN pts_collected >0 THEN home_store_id||cust_no||auth_person_id ELSE NULL END) as collected_cust,
sum(month_points)+sum(advance_points)+sum(flash_points)+sum(KA_points) as pts_used, count(distinct CASE WHEN pts_used >0 THEN home_store_id||cust_no||auth_person_id ELSE NULL END) as used_cust,
sum(month_points) as month_points, sum(advance_points) as advance_points, sum(flash_points) as flash_points, sum(KA_points) as KA_points,
count(distinct CASE WHEN a.month_points > 0 THEN a.home_store_id||a.cust_no||a.auth_person_id ELSE NULL END) as month_points_user,
count(distinct CASE WHEN a.advance_points > 0 THEN a.home_store_id||a.cust_no||a.auth_person_id ELSE NULL END) as advance_points_user,
count(distinct CASE WHEN a.flash_points > 0 THEN a.home_store_id||a.cust_no||a.auth_person_id ELSE NULL END) as flash_points_user,
count(distinct CASE WHEN a.KA_points > 0 THEN a.home_store_id||a.cust_no||a.auth_person_id ELSE NULL END) as KA_points_user,
sum(balance_points) as balance_points,
count(distinct CASE WHEN a.balance_points > 0 THEN a.home_store_id||a.cust_no||a.auth_person_id ELSE NULL END) as balance_points_user
from chnccp_msi_z.LP_sales_and_redemption_1 a
group by ABC, ABC_combined, branch
order by ABC, ABC_combined, branch;

--invoice number
select ABC_combined, count(distinct CASE WHEN (a.month_points > 0) OR ( a.advance_points > 0) OR (a.flash_points > 0) OR (a.KA_points > 0 ) THEN home_store_id||cust_no||auth_person_id ELSE NULL END) as ttl_redem_invoice 
from chnccp_msi_z.LP_sales_and_redemption_1 a
group by ABC_combined
order by ABC_combined;

--no consumption but with redemption
select sum(a.pts_collected) as collected_points, count(distinct CASE WHEN pts_collected >0 THEN a.home_store_id||a.cust_no||a.auth_person_id ELSE NULL END) as collected_cust,
sum(a.month_points)+sum(a.advance_points)+sum(a.flash_points)+sum(a.KA_points) as pts_used, count(distinct CASE WHEN a.pts_used >0 THEN a.home_store_id||a.cust_no||a.auth_person_id ELSE NULL END) as used_cust,
sum(a.month_points) as month_points, sum(a.advance_points) as advance_points, sum(a.flash_points) as flash_points, sum(a.KA_points) as KA_points,
count(distinct CASE WHEN a.month_points > 0 THEN a.home_store_id||a.cust_no||a.auth_person_id ELSE NULL END) as month_points_user,
count(distinct CASE WHEN a.advance_points > 0 THEN a.home_store_id||a.cust_no||a.auth_person_id ELSE NULL END) as advance_points_user,
count(distinct CASE WHEN a.flash_points > 0 THEN a.home_store_id||a.cust_no||a.auth_person_id ELSE NULL END) as flash_points_user,
count(distinct CASE WHEN a.KA_points > 0 THEN a.home_store_id||a.cust_no||a.auth_person_id ELSE NULL END) as KA_points_user
from chnccp_msi_z.LP_namelist_points_total a 
left join chnccp_msi_z.LP_namelist_total_1 b
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
where b.cust_no is NULL;

--invoice check
select count(distinct CASE WHEN (a.month_points > 0) OR ( a.advance_points > 0) OR (a.flash_points > 0) OR (a.KA_points > 0 ) THEN a.home_store_id||a.cust_no||a.auth_person_id ELSE NULL END) as ttl_redem_invoice
from chnccp_msi_z.LP_namelist_points_total a 
left join chnccp_msi_z.LP_namelist_total_1 b
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
where b.cust_no is NULL;

--no consumption balance points
select sum(balance_points) as balance_points, count(distinct CASE WHEN balance_points >0 THEN a.home_store_id||a.cust_no||a.auth_person_id ELSE NULL END) as balance_points_cust
from chnccp_msi_z.LP_namelist_points_balance a
left join chnccp_msi_z.LP_namelist_total_1 b
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
where b.cust_no is NULL;


--total collect channel
drop table chnccp_msi_z.LP_namelist_points_collectchannel;
create table chnccp_msi_z.LP_namelist_points_collectchannel
	as(select a.home_store_id, a.cust_no, a.auth_person_id, 
		SUM(c.loy_item_num_trans_pts) AS pts_collected,
		CASE WHEN c.loy_pts_item_prom_id = '4-B0R7EYUD' THEN 'big_invoice'
		     WHEN c.loy_pts_item_prom_id = '4-B0R7EYGJ' THEN 'basic'
             WHEN c.loy_pts_item_prom_id = '2-F6VMWGY' THEN 'welcome' 
             ELSE 'frequency' END AS channel
		from chnccp_dwh.dw_mcrm_loy_member a 
		join chnccp_dwh.dw_mcrm_loy_pts_items c 
		on c.loy_mem_row_id = a.loy_mem_row_id
		join chnccp_dwh.dw_time_day d
		ON c.loy_pts_item_trans_date = d.date_of_day
		where d.month_id in(201906, 201907, 201908, 201909,201910, 201911, 201912, 202001, 202002, 202003, 202004, 202005, 202005)
		and c.loy_pts_item_accrual_row_id IS NULL
		group by a.home_store_id, a.cust_no, a.auth_person_id, channel
		)with data;

select a.ABC_combined, b.channel, count(distinct b.home_store_id||b.cust_no||b.auth_person_id) as buyer, sum(b.pts_collected) as points_collected from  chnccp_msi_z.LP_sales_and_redemption_1 a 
join chnccp_msi_z.LP_namelist_points_collectchannel b 
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
group by a.ABC_combined, b.channel
order by a.ABC_combined, b.channel;

select b.channel, count(distinct b.home_store_id||b.cust_no||b.auth_person_id) as buyer, sum(pts_collected)	as points_collected
from chnccp_msi_z.LP_namelist_points_collectchannel b
left join  chnccp_msi_z.LP_sales_and_redemption_1 a
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
where a.cust_no is NULL
group by b.channel
order by b.channel;

--------------------------------------------------------------------------------------------------------------------------------
---------------------------------------sales
---2018-06-01 to 2019-05-31
--vcp
/*drop table chnccp_msi_z.LP_namelist_PY;
create table chnccp_msi_z.LP_namelist_PY
	as(select a.home_store_id, a.cust_no,a.auth_person_id,
		CASE WHEN (d.bvs_ind = 'N' AND d.pcr_ind = 'N' AND d.deli_ind = 'N' AND d.wel_ind = 'Y' AND (d.fsd_ind = 'Y' OR d.fsd_ind = 'N')) THEN '1) welfare cash and carry'
             WHEN (d.wel_ind = 'Y' AND (d.bvs_ind = 'Y' OR d.pcr_ind = 'Y' OR d.deli_ind = 'Y')) THEN '2) welfare deals'
             WHEN (d.wel_ind = 'N' AND d.fsd_ind = 'Y' ) THEN '3) fsd'
             WHEN (d.bvs_ind = 'N' AND d.pcr_ind = 'N' AND d.deli_ind = 'N' AND d.wel_ind = 'N' AND d.fsd_ind = 'N') THEN '4) o2o cash and carry'
             WHEN ((d.bvs_ind = 'Y'  OR d.pcr_ind = 'Y' OR d.deli_ind = 'Y' ) AND (d.wel_ind = 'N'  AND d.fsd_ind = 'N' )) THEN '5) o2o deals'
             ELSE '6) undefined' END AS vcp,
             CASE WHEN c.cust_assort_section_id IS IN (1) THEN '1) HoReCa'
                  WHEN c.cust_assort_section_id IS IN (3) THEN '2) Trader'
                  WHEN c.cust_assort_section_id IS IN (5, 7) AND c.branch_id = 982 THEN '3) SCO - daypass'
                  WHEN c.cust_assort_section_id IS IN (5, 7) AND c.branch_id IN (401,492,488,971,972,973,493) THEN '3) SCO - FoM'
                  WHEN c.cust_assort_section_id IS IN (5, 7) AND c.branch_id NOT IN (401,492,488,971,972,982.973,493) THEN '3) SCO - w/o FoM'
                  ELSE '4) Undefined' end as branch
               from chnccp_dwh.dw_mcrm_loy_member a
               join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj d
               on a.home_store_id = d.home_store_id and a.cust_no = d.cust_no and a.auth_person_id = d.auth_person_id
               join chnccp_dwh.dw_customer b
               on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no
               join chnccp_dwh.dw_cust_branch c
               on b.branch_id = c.branch_id
               where d.date_of_day between '2018-06-01' and '2020-05-31'
               and a.loy_mem_parent_ind = 0 and a.loy_mem_join_date is not null
               group by a.home_store_id, a.cust_no,a.auth_person_id,VCP, branch
               )with data;*/

--no vcp
drop table chnccp_msi_z.LP_namelist_1_PY;
create table chnccp_msi_z.LP_namelist_1_PY
	as(select a.home_store_id, a.cust_no,a.auth_person_id,
             CASE WHEN c.cust_assort_section_id IS IN (1) THEN '1) HoReCa'
                  WHEN c.cust_assort_section_id IS IN (3) THEN '2) Trader'
                  WHEN c.cust_assort_section_id IS IN (5, 7) AND c.branch_id = 982 THEN '3) SCO - daypass'
                  WHEN c.cust_assort_section_id IS IN (5, 7) AND c.branch_id IN (401,492,488,971,972,973,493) THEN '3) SCO - FoM'
                  WHEN c.cust_assort_section_id IS IN (5, 7) AND c.branch_id NOT IN (401,492,488,971,972,982.973,493) THEN '3) SCO - w/o FoM'
                  ELSE '4) Undefined' end as branch
               from chnccp_dwh.dw_mcrm_loy_member a
               join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj d
               on a.home_store_id = d.home_store_id and a.cust_no = d.cust_no and a.auth_person_id = d.auth_person_id
               join chnccp_dwh.dw_customer b
               on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no
               join chnccp_dwh.dw_cust_branch c
               on b.branch_id = c.branch_id
               where d.date_of_day between '2018-06-01' and '2019-05-31'
               and a.loy_mem_parent_ind = 0 and a.loy_mem_join_date is not null
               group by a.home_store_id, a.cust_no,a.auth_person_id, branch
               )with data;


drop table chnccp_msi_z.LP_namelist_abc_PY;
create table chnccp_msi_z.LP_namelist_abc_PY
	as(select a.home_store_id, a.cust_no, a.auth_person_id,
		CASE WHEN net_sales/8 >= 6000 THEN '01) A1-C1'
             WHEN net_sales/8 >= 500 AND net_sales/8 < 6000 THEN '02) C2-C5'
	         WHEN net_sales/8 >= 100 AND net_sales/8 < 500 THEN '03) C6' 
	         WHEN net_sales/8 > 0 AND net_sales/8 < 100 THEN '04) C7' ELSE '05) NN' END AS ABC_combined,
	         CASE WHEN net_sales/8 >= 250000 THEN '01) A1'
		          WHEN net_sales/8 >= 100000 AND net_sales/8 < 250000 THEN '02) A2'
		          WHEN net_sales/8 >= 70000 AND net_sales/8 < 100000 THEN '03) A3'
                  WHEN net_sales/8 >= 40000 AND net_sales/8 < 70000  THEN '04) A4'
                  WHEN net_sales/8 >= 30000 AND net_sales/8 < 40000 THEN '05) B1'
                  WHEN net_sales/8 >= 20000 AND net_sales/8 < 30000 THEN '06) B2'
                  WHEN net_sales/8 >= 15000 AND net_sales/8 < 20000 THEN '07) B3'
                  WHEN net_sales/8 >= 10000 AND net_sales/8 < 15000 THEN '08) B4'
                  WHEN net_sales/8 >= 6000  AND net_sales/8 < 10000 THEN '09) C1'
                  WHEN net_sales/8 >= 4000  AND net_sales/8 < 6000  THEN '10) C2'
                  WHEN net_sales/8 >= 2000  AND net_sales/8 < 4000  THEN '11) C3'
                  WHEN net_sales/8 >= 1000  AND net_sales/8 < 2000  THEN '12) C4'
                  WHEN net_sales/8 >= 500   AND net_sales/8 < 1000  THEN '13) C5'
                  WHEN net_sales/8 >= 100   AND net_sales/8 < 500   THEN '14) C6'
                  WHEN net_sales/8 >  0     AND net_sales/8 < 100   THEN '15) C7' ELSE '16) NN' END AS ABC,
                  SUM(a.sell_val_nsp) AS net_sales, count(DISTINCT a.invoice_id) AS visit, SUM(a.sell_val_nsp) - SUM(a.sell_val_nnbp) AS front_margin 
                  from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj a 
                  where a.date_of_day between '2018-06-01' and '2019-05-31'
                  group by a.home_store_id, a.cust_no, a.auth_person_id
                  having net_sales >0
                  )with data;

--vcp
/*drop table chnccp_msi_z.LP_namelist_total_PY;
create table chnccp_msi_z.LP_namelist_total_PY
	as(select a.ABC_combined, a.ABC, b.VCP, b.branch, a.home_store_id, a.cust_no, a.auth_person_id, a.net_sales, a.visit, a.front_margin from chnccp_msi_z.LP_namelist b 
		join chnccp_msi_z.LP_namelist_abc a
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		)with data;*/

drop table chnccp_msi_z.LP_namelist_total_1_PY;
create table chnccp_msi_z.LP_namelist_total_1_PY
	as(select a.ABC_combined, a.ABC, b.branch, a.home_store_id, a.cust_no, a.auth_person_id, a.net_sales, a.visit, a.front_margin from chnccp_msi_z.LP_namelist_1_PY b 
		join chnccp_msi_z.LP_namelist_abc_PY a
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		)with data;


---------------------------------------redemption
--total redemption points
drop table chnccp_msi_z.LP_namelist_points_PY;
create table chnccp_msi_z.LP_namelist_points_PY
	as(select a.home_store_id, a.cust_no, a.auth_person_id, 
		SUM(CASE WHEN c.loy_pts_item_accrual_row_id IS NULL THEN c.loy_item_num_trans_pts ELSE 0 end ) AS pts_collected,
		SUM(CASE WHEN c.loy_pts_item_accrual_row_id IS NOT NULL AND c.loy_pts_item_type_cd = 66404 THEN loy_item_num_trans_pts ELSE 0 END) AS pts_used
		from chnccp_dwh.dw_mcrm_loy_member a 
		join chnccp_dwh.dw_mcrm_loy_pts_items c 
		on c.loy_mem_row_id = a.loy_mem_row_id
		join chnccp_dwh.dw_time_day d
		ON c.loy_pts_item_trans_date = d.date_of_day
		where d.month_id in(201806, 201807, 201808, 201809,201810, 201811, 201812, 201901, 201902, 201903, 201904, 201905, 201905)
		group by a.home_store_id, a.cust_no, a.auth_person_id
		)with data;


--monthly redemption
drop table chnccp_msi_z.LP_namelist_points_monthly_PY;
create table chnccp_msi_z.LP_namelist_points_monthly_PY
	as(select tt.home_store_id, tt.cust_no, tt.auth_person_id, sum(tt.points*a.redemption_points) as month_points from (
		(select b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no, sum(b.sell_qty_colli) as points from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key 
		where a."time" ='201806'
		and b.date_of_day between '2018-06-01' and '2018-06-30'
		group by b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no)
		Union 
		(select b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no, sum(b.sell_qty_colli) as points from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."time" ='201807'
		and b.date_of_day between '2018-07-01' and '2018-07-31'
		group by b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no)
		Union 
		(select b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no, sum(b.sell_qty_colli) as points from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."time" ='201808'
		and b.date_of_day between '2018-08-01' and '2018-08-31'
		group by b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no)
		Union 
		(select b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no, sum(b.sell_qty_colli) as points from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."time" ='201809'
		and b.date_of_day between '2018-09-01' and '2018-09-30'
		group by b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no)
		Union 
		(select b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no, sum(b.sell_qty_colli) as points from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."time" ='201810'
		and b.date_of_day between '2018-10-01' and '2018-10-31'
		group by b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no)
		Union 
		(select b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no, sum(b.sell_qty_colli) as points from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."time" ='201811'
		and b.date_of_day between '2018-11-01' and '2018-11-30'
		group by b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no)
		Union 
		(select b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no, sum(b.sell_qty_colli) as points from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."time" ='201812'
		and b.date_of_day between '2018-12-01' and '2018-12-31'
		group by b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no)
		Union 
		(select b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no, sum(b.sell_qty_colli) as points from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."time" ='201901'
		and b.date_of_day between '2019-01-01' and '2019-01-31'
		group by b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no)
		Union 
        (select b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no, sum(b.sell_qty_colli) as points from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."time" ='202019-03'
		and b.date_of_day between '2019-02-01' and '2019-03-31'
		group by b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no)
		Union 
		(select b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no, sum(b.sell_qty_colli) as points from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."time" ='201904'
		and b.date_of_day between '2019-04-01' and '2019-04-30'
		group by b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no)
		Union 
		(select b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no, sum(b.sell_qty_colli) as points from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."time" ='201905'
		and b.date_of_day between '2019-05-01' and '2019-05-31'
		group by b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no) )tt
        join chnccp_msi_z.redemption a
        on a.mikg_art_no = tt.mikg_art_no
        group by tt.home_store_id, tt.cust_no, tt.auth_person_id
		)with data;

--advance redemption
drop table chnccp_msi_z.LP_namelist_points_advance_PY;
create table chnccp_msi_z.LP_namelist_points_advance_PY
	as(select tt.home_store_id, tt.cust_no, tt.auth_person_id, sum(tt.advance_points*a.redemption_points) as advance_points from ((select b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no, sum(b.sell_qty_colli) as advance_points from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c  
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."time" ='20180401-20180930'
		and b.date_of_day between '2018-06-01' and '2018-09-30'
		group by b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no)
		Union 
		(select b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no, sum(b.sell_qty_colli ) as advance_points from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."time" ='20181001-20190331'
		and b.date_of_day between '2018-10-01' and '2019-03-31'
		group by b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no)
        Union
		(select b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no, sum(b.sell_qty_colli ) as advance_points from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."time" ='20190401-20190930'
		and b.date_of_day between '2019-04-01' and '2019-05-31'
		group by b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no)  )tt 
	    join chnccp_msi_z.redemption a 
	    on a.mikg_art_no = tt.mikg_art_no
	    group by tt.home_store_id, tt.cust_no, tt.auth_person_id)with data;

--flash redemption
drop table chnccp_msi_z.LP_namelist_points_flash_PY;
create table chnccp_msi_z.LP_namelist_points_flash_PY
	as(select tt.home_store_id, tt.cust_no, tt.auth_person_id, sum(tt.flash_points*a.redemption_points) as flash_points from (
	    (select b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no, sum(b.sell_qty_colli ) as flash_points from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."type" = '世界杯兑换'
		and a."time" ='20180621-20180718'
		and b.date_of_day between '2018-06-21' and '2018-07-18'
		group by b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no))tt
	    join chnccp_msi_z.redemption a 
	    on a.mikg_art_no = tt.mikg_art_no
	    group by tt.home_store_id, tt.cust_no, tt.auth_person_id)with data;

--KA redemption
drop table chnccp_msi_z.LP_namelist_points_KA_PY;
create table chnccp_msi_z.LP_namelist_points_KA_PY
	as(select tt.home_store_id, tt.cust_no, tt.auth_person_id, sum(tt.KA_points*a.redemption_points) as KA_points from (
	    (select b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no, sum(b.sell_qty_colli ) as KA_points from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."type" = 'Emsa' and a.art_name like'%爱慕莎%'
		and a."time" ='20180830-20190102'
		and b.date_of_day between '2018-08-30' and '2019-01-02'
		group by b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no)
		Union
		(select b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no, sum(b.sell_qty_colli ) as KA_points from chnccp_msi_z.redemption a 
		join chnccp_dwh.dw_art_var_tu c 
		on a.mikg_art_no = c.mikg_art_no
		join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b
		on c.art_no = b.art_no  and b.var_tu_key = c.var_tu_key
		where a."type" = 'Neoflam餐厨'
		and a."time" ='20180621-20180815'
		and b.date_of_day between '2018-06-21' and '2018-08-15'
		group by b.home_store_id, b.cust_no, b.auth_person_id, a.mikg_art_no))tt
	    join chnccp_msi_z.redemption a 
	    on a.mikg_art_no = tt.mikg_art_no
	    group by tt.home_store_id, tt.cust_no, tt.auth_person_id)with data;



--total redemption
drop table chnccp_msi_z.LP_namelist_points_total_PY;
create table chnccp_msi_z.LP_namelist_points_total_PY
	as(select a.*, b.month_points, c.advance_points, d.flash_points, e.KA_points from chnccp_msi_z.LP_namelist_points_PY a 
		left join chnccp_msi_z.LP_namelist_points_monthly_PY b 
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		left join chnccp_msi_z.LP_namelist_points_advance_PY c
		on a.home_store_id = c.home_store_id and a.cust_no = c.cust_no and a.auth_person_id = c.auth_person_id
		left join chnccp_msi_z.LP_namelist_points_flash_PY d 
		on a.home_store_id = d.home_store_id and a.cust_no = d.cust_no and a.auth_person_id = d.auth_person_id
		left join chnccp_msi_z.LP_namelist_points_KA_PY e 
		on a.home_store_id = e.home_store_id and a.cust_no = e.cust_no and a.auth_person_id = e.auth_person_id)with data;

--sales and redemption

--vcp
/*drop table chnccp_msi_z.LP_sales_and_redemption;
create table chnccp_msi_z.LP_sales_and_redemption
	as(select a.*, b.pts_collected, b.pts_used, b.month_points, b.advance_points, b.flash_points, b.KA_points from chnccp_msi_z.LP_namelist_total a 
		left join chnccp_msi_z.LP_namelist_points_total b
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		)with data;

select ABC, sum(net_sales) as  sales, avg(visit) as visit, sum(front_margin) as front_margin, count(distinct home_store_id||cust_no||auth_person_id) as cust, 
sum(pts_collected) as collected_points, count(distinct CASE WHEN pts_collected >0 THEN home_store_id||cust_no||auth_person_id ELSE NULL END) as collected_cust,
sum(pts_used) as pts_used, count(distinct CASE WHEN pts_used >0 THEN home_store_id||cust_no||auth_person_id ELSE NULL END) as used_cust,
sum(month_points) as month_points, sum(advance_points) as advance_points, sum(flash_points) as flash_points, sum(KA_points) as KA_points from chnccp_msi_z.LP_sales_and_redemption
group by ABC
order by ABC;*/


--no vcp
drop table chnccp_msi_z.LP_sales_and_redemption_PY_1;
create table chnccp_msi_z.LP_sales_and_redemption_PY_1
	as(select a.*, c.balance_points, b.pts_collected, b.pts_used, b.month_points, b.advance_points, b.flash_points, b.KA_points from chnccp_msi_z.LP_namelist_total_1_PY a 
		left join chnccp_msi_z.LP_namelist_points_total_PY b
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		left join chnccp_msi_z.LP_namelist_points_balance_PY c 
		on c.home_store_id = a.home_store_id and c.cust_no = a.cust_no and c.auth_person_id = a.auth_person_id
		)with data;

select ABC, ABC_combined, branch, sum(net_sales) as  sales, sum(visit) as visit, sum(front_margin) as front_margin, count(distinct home_store_id||cust_no||auth_person_id) as cust, 
sum(pts_collected) as collected_points, count(distinct CASE WHEN pts_collected >0 THEN home_store_id||cust_no||auth_person_id ELSE NULL END) as collected_cust,
sum(month_points)+sum(advance_points)+sum(flash_points)+sum(KA_points) as pts_used, count(distinct CASE WHEN pts_used >0 THEN home_store_id||cust_no||auth_person_id ELSE NULL END) as used_cust,
sum(month_points) as month_points, sum(advance_points) as advance_points, sum(flash_points) as flash_points, sum(KA_points) as KA_points,
count(distinct CASE WHEN a.month_points > 0 THEN a.home_store_id||a.cust_no||a.auth_person_id ELSE NULL END) as month_points_user,
count(distinct CASE WHEN a.advance_points > 0 THEN a.home_store_id||a.cust_no||a.auth_person_id ELSE NULL END) as advance_points_user,
count(distinct CASE WHEN a.flash_points > 0 THEN a.home_store_id||a.cust_no||a.auth_person_id ELSE NULL END) as flash_points_user,
count(distinct CASE WHEN a.KA_points > 0 THEN a.home_store_id||a.cust_no||a.auth_person_id ELSE NULL END) as KA_points_user,
sum(balance_points) as balance_points,
count(distinct CASE WHEN a.balance_points > 0 THEN a.home_store_id||a.cust_no||a.auth_person_id ELSE NULL END) as balance_points_user
from chnccp_msi_z.LP_sales_and_redemption_PY_1 a
group by ABC, ABC_combined, branch
order by ABC, ABC_combined, branch;

select ABC_combined, count(distinct CASE WHEN (a.month_points > 0) OR ( a.advance_points > 0) OR (a.flash_points > 0) OR (a.KA_points > 0 ) THEN home_store_id||cust_no||auth_person_id ELSE NULL END) as ttl_redem_invoice 
from chnccp_msi_z.LP_sales_and_redemption_PY_1 a
group by ABC_combined
order by ABC_combined;

--no consumption but redemption
select sum(a.pts_collected) as collected_points, count(distinct CASE WHEN pts_collected >0 THEN a.home_store_id||a.cust_no||a.auth_person_id ELSE NULL END) as collected_cust,
sum(a.month_points)+sum(a.advance_points)+sum(a.flash_points)+sum(a.KA_points) as pts_used, count(distinct CASE WHEN a.pts_used >0 THEN a.home_store_id||a.cust_no||a.auth_person_id ELSE NULL END) as used_cust,
sum(a.month_points) as month_points, sum(a.advance_points) as advance_points, sum(a.flash_points) as other_points, sum(a.KA_points) as KA_points,
count(distinct CASE WHEN a.month_points > 0 THEN a.home_store_id||a.cust_no||a.auth_person_id ELSE NULL END) as month_points_user,
count(distinct CASE WHEN a.advance_points > 0 THEN a.home_store_id||a.cust_no||a.auth_person_id ELSE NULL END) as advance_points_user,
count(distinct CASE WHEN a.flash_points > 0 THEN a.home_store_id||a.cust_no||a.auth_person_id ELSE NULL END) as flash_points_user,
count(distinct CASE WHEN a.KA_points > 0 THEN a.home_store_id||a.cust_no||a.auth_person_id ELSE NULL END) as KA_points_user
from chnccp_msi_z.LP_namelist_points_total_PY a 
left join chnccp_msi_z.LP_namelist_total_1_PY b
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
where b.cust_no is NULL;

--invoice check
select count(distinct CASE WHEN (a.month_points > 0) OR ( a.advance_points > 0) OR (a.flash_points > 0) OR (a.KA_points > 0 ) THEN a.home_store_id||a.cust_no||a.auth_person_id ELSE NULL END) as ttl_redem_invoice
from chnccp_msi_z.LP_namelist_points_total_PY a 
left join chnccp_msi_z.LP_namelist_total_1_PY b
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
where b.cust_no is NULL;
