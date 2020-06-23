select o.item_id,i.title,i.price/100 price
        ,sum(o.payment)/100 amt,sum(case when o.payment>0 then o.num else 0 end) qty
        ,count(distinct case when o.payment>0 then o.buyer_id else null end) buyer,
        count(case when o.payment>0 then o.buyer_id else null end) orders
    from eorder.trades t 
    left join eorder.orders o 
    on t.id=o.trade_id
    left join eproduct.items i 
    on o.item_id=i.id
    where t.created_at>='2020-06-09 12:00:00' 
    group by 1,2,3;


drop table falshsales_0610;
create table falshsales_0610
    as(select t.buyer_id, CAST(split_part(t.buyer_id, '_', 1) as INTEGER) as home_store_id, CAST(split_part(t.buyer_id, '_', 2) as INTEGER) as cust_no, CAST(split_part(t.buyer_id, '_', 3) as INTEGER) as auth_person_id, o.item_id, i.title, i.price/100 as price, o.payment/100 as sales, o.num as qty, o.type as deliver_type, t.app_id as falshsales from eorder.trades t 
left join eorder.orders o 
on t.id=o.trade_id
left join eproduct.items i 
on o.item_id=i.id
where t.created_at>='2020-06-09 12:00:00');

select item_id, title, price,  sum(sales) as sales, sum(case when sales > 0 then qty ELSE 0 END) as qty, count(CASE WHEN sales > 0 THEN buyer_id ELSE NULL END) AS orders, count(distinct CASE WHEN sales > 0 THEN buyer_id ELSE NULL END) as buyer
from falshsales_0610
group by item_id, title, price;

----------------------------------------------
-----------------------1----------------------

--subtotal
select deliver_type, count(distinct buyer_id) as buyer, sum(sales) as sales, count(buyer_id) as orders, sum(qty) as qty from falshsales_0610
where sales > 0
group by deliver_type;

--total
select count(distinct buyer_id) as buyer, sum(sales) as sales, count(buyer_id) as orders, sum(qty) as qty from falshsales_0610
where sales > 0;


---art_name search
select mikg_art_no, art_name, art_name_tl from chnccp_dwh.dw_art_var_tu 
where mikg_art_no in(234660,233957,234560,964120,223042,80795,136874,212267,233502,233104,217350);

---create table in Teradata
drop table chnccp_msi_z.falshsales_0610;
create table chnccp_msi_z.falshsales_0610
    (buyer_id VARCHAR(20),
        home_store_id INTEGER,
        cust_no INTEGER,
        auth_person_id INTEGER,
        item_id INTEGER,
        art_name VARCHAR(20),
        price INTEGER,
        sales INTEGER,
        qty INTEGER,
        deliver_type VARCHAR(10),
        falshsales VARCHAR(10)
        );

--pick-up qty
SELECT b.mikg_art_no,
sum(a.sell_qty_colli) as qty
,sum(a.sell_val_gsp) as gross_sales
,count(distinct a.invoice_id) as orders
,count(distinct a.home_store_id || a.cust_no|| a.auth_person_id)  as buyer
,sum(a.sell_val_nsp) as net_sales
FROM chnccp_fls.view_frank_auth_person_invoice_line a
INNER JOIN chnccp_dwh.dw_art_var_tu b
    ON a.art_no =b.art_no 
    AND a.var_tu_key = b.var_tu_Key
WHERE a.date_of_day BETWEEN '2020-06-12' and  '2020-06-16' --对应发货的时间
    AND b.mikg_art_no IN (233502, 233104, 217350) --subsys no 自提的商品编号
    AND
a.cupr_action_id * 1000 + a.cupr_action_sequence_id IN (205035590, 205035591, 205035592)
group by b.mikg_art_no;

--cross basket
drop table chnccp_msi_z.pickup_namelist;
create table chnccp_msi_z.pickup_namelist
    as(select home_store_id, cust_no, auth_person_id from chnccp_crm.flash_sale --格式原因，用此表替换
        where deliver_type = 'pickup' and campaign_type = 20200610
        group by home_store_id, cust_no, auth_person_id
        )with data;

select sum(b.sell_val_gsp) as sales from chnccp_msi_z.pickup_namelist a 
join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj  b 
on a.cust_no = b.cust_no and a.home_store_id = b.home_store_id and a.auth_person_id = b.auth_person_id
join chnccp_dwh.dw_art_var_tu c 
on c.art_no = b.art_no and c.var_tu_key = b.var_tu_key
where b.date_of_day between '2020-06-12' and '2020-06-16'
and c.mikg_art_no not in (233502, 233104, 217350);

--前台毛利：所有自提订单用户的(nsp-nnbp)/nsp --nsp: 1,010,400.5300 --nnbp: 935,686.6663
select sum(b.sell_val_nsp) as nsp, sum(b.sell_val_nnbp) as nnbp from chnccp_msi_z.pickup_namelist a 
join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj  b 
on a.cust_no = b.cust_no and a.home_store_id = b.home_store_id and a.auth_person_id = b.auth_person_id
join chnccp_dwh.dw_art_var_tu c 
on c.art_no = b.art_no and c.var_tu_key = b.var_tu_key
where b.date_of_day between between '2020-06-12' and '2020-06-16';

--fullfilment pick-up customer: 5974
select sum(a.sell_qty_colli) as qty
,sum(a.sell_val_gsp) as gross_sales
,count(distinct a.invoice_id) as orders
,count(distinct a.home_store_id || a.cust_no|| a.auth_person_id)  as buyer
,sum(a.sell_val_nsp) as net_sales
FROM chnccp_fls.view_frank_auth_person_invoice_line a
INNER JOIN chnccp_dwh.dw_art_var_tu b
    ON a.art_no =b.art_no 
    AND a.var_tu_key = b.var_tu_Key
WHERE a.date_of_day BETWEEN '2020-06-12' and '2020-06-16' --对应发货的时间
    AND b.mikg_art_no IN (233502, 233104, 217350)  --subsys no 自提的商品编号
    AND
a.cupr_action_id * 1000 + a.cupr_action_sequence_id IN (205035590, 205035591, 205035592);
---------------------------------------------
---------------------2-----------------------
select campaign_id, count(distinct home_store_id||cust_no||auth_person_id) as uv from chnccp_msi_z.first_channel_userinfo where campaign_id = '20200610'
group by campaign_id;

---------------------------------------------
---------------------3-----------------------
--age and gender
drop table chnccp_msi_z.ganyu_temp_ageandgender;
create table chnccp_msi_z.ganyu_temp_ageandgender
    as( select a.home_store_id, a.auth_person_id, a.cust_no, a.deliver_type,
        CASE WHEN REGEXP_SIMILAR(left (right(b.identification_id,2),1), '[0-9]{1}','c')  = 1 then left (right(b.identification_id,2),1) 
        ELSE NULL end as gender,
        case when REGEXP_SIMILAR(right (left(b.identification_id,10),4), '[0-9]{4}','c')  = 1 then 2020-right (left(b.identification_id,10),4) 
        ELSE NULL end as age
        from chnccp_msi_z.falshsales_0610 a 
        left join chnccp_dwh.dw_cust_auth_person b 
        on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
        where a.sales > 0 )with data;

--total age 
select distinct home_store_id, cust_no, auth_person_id, age from chnccp_msi_z.ganyu_temp_ageandgender;
--type age
select deliver_type, home_store_id, cust_no, auth_person_id, age from chnccp_msi_z.ganyu_temp_ageandgender
where age between 1 and 100;

--agegroup
drop table chnccp_msi_z.ganyu_temp_age;
create table chnccp_msi_z.ganyu_temp_age
    as( select deliver_type, home_store_id, auth_person_id, cust_no,
        CASE WHEN age < 18 THEN '<18'
             WHEN age between 18 and 24 THEN '18-24'
             WHEN age between 25 and 29 THEN '25-29'
             WHEN age between 30 and 39 THEN '30-39'
             WHEN age between 40 and 49 THEN '40-49'
             WHEN age >= 50 THEN '>=50'
             ELSE NULL END AS age_group from chnccp_msi_z.ganyu_temp_ageandgender )with data;

select deliver_type, age_group, count(distinct home_store_id||auth_person_id||cust_no) from chnccp_msi_z.ganyu_temp_age
group by 1,2
order by 1,2;

select age_group,count(distinct home_store_id||auth_person_id||cust_no) as total from chnccp_msi_z.ganyu_temp_age
group by 1
order by 1;

--gendergroup
drop table chnccp_msi_z.ganyu_temp_gender;
create table chnccp_msi_z.ganyu_temp_gender
    as( select deliver_type, home_store_id, auth_person_id, cust_no,
        CASE WHEN gender in (0,2,4,6,8) THEN '女'
             WHEN gender in (1,3,5,7,9) THEN '男'
             ELSE '未知' END AS gender_group from chnccp_msi_z.ganyu_temp_ageandgender )with data;

select deliver_type, gender_group, count(distinct home_store_id||cust_no||auth_person_id) as people from chnccp_msi_z.ganyu_temp_gender
group by deliver_type, gender_group
order by deliver_type, gender_group;

select gender_group, count(distinct home_store_id||cust_no||auth_person_id) as people from chnccp_msi_z.ganyu_temp_gender
group by gender_group
order by gender_group;

--profile
drop table chnccp_msi_z.flashsales;
create table chnccp_msi_z.flashsales
    as(select home_store_id, cust_no, auth_person_id, deliver_type from chnccp_msi_z.falshsales_0610
        where sales > 0
        group by home_store_id, cust_no, auth_person_id, deliver_type
        )with data;

--UMC+
select a.deliver_type, b.member_type, count(distinct a.auth_person_id||a.home_store_id||a.cust_no) as buyer from chnccp_msi_z.flashsales a 
left join chnccp_msi_z.mem_ref_umc_tag_act b 
on a.auth_person_id = b.auth_person_id and a.home_store_id = b.home_store_id and a.cust_no = b.cust_no
group by 1,2
order by 1,2;

select b.member_type, count(distinct a.auth_person_id||a.home_store_id||a.cust_no) as buyer from chnccp_msi_z.flashsales a 
left join chnccp_msi_z.mem_ref_umc_tag_act b
on a.auth_person_id = b.auth_person_id and a.home_store_id = b.home_store_id and a.cust_no = b.cust_no
group by 1;

--fan
select a.deliver_type, b.fan_ind, count(distinct a.auth_person_id||a.home_store_id||a.cust_no) as buyer from chnccp_msi_z.flashsales a 
left join chnccp_msi_z.mem_ref_umc_tag_act b 
on a.auth_person_id = b.auth_person_id and a.home_store_id = b.home_store_id and a.cust_no = b.cust_no
group by 1,2
order by 1,2;

select b.fan_ind,count(distinct a.auth_person_id||a.home_store_id||a.cust_no) as buyer from chnccp_msi_z.flashsales a 
left join chnccp_msi_z.mem_ref_umc_tag_act b
on a.auth_person_id = b.auth_person_id and a.home_store_id = b.home_store_id and a.cust_no = b.cust_no
group by 1;

--lifecycle
-----------
--以5.26为活动日期--
--new
drop table chnccp_msi_z.ganyu_temp_lifecycle_new;
create table chnccp_msi_z.ganyu_temp_lifecycle_new
    as(select a.deliver_type, a.home_store_id , a.cust_no, a.auth_person_id, 'new' as lifecycle
        from chnccp_msi_z.flashsales a 
        join chnccp_dwh.dw_cust_invoice b 
        on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
        group by a.deliver_type, a.home_store_id , a.cust_no, a.auth_person_id
        having min(b.date_of_day)>='2020-06-09' )with data;

select deliver_type, lifecycle, count(distinct auth_person_id||home_store_id||cust_no) from chnccp_msi_z.ganyu_temp_lifecycle_new
group by deliver_type,lifecycle;

select lifecycle, count(distinct home_store_id||cust_no||auth_person_id) from chnccp_msi_z.ganyu_temp_lifecycle_new
group by lifecycle;

--activation and reactivation
drop table chnccp_msi_z.ganyu_temp_lifecycle_activation;
create table chnccp_msi_z.ganyu_temp_lifecycle_activation
    as(select t1.deliver_type, t1.home_store_id , t1.cust_no, t1.auth_person_id,
        CASE WHEN max(b.date_of_day)between '2020-03-09' and '2020-06-08' THEN 'Regular'
             ELSE 'reactivation' END AS lifecycle
        from (select a.* from chnccp_msi_z.flashsales a left join chnccp_msi_z.ganyu_temp_lifecycle_new b on b.auth_person_id = a.auth_person_id and b.cust_no = a.cust_no and b.home_store_id = a.home_store_id where b.cust_no is NULL) t1
        left join chnccp_dwh.dw_cust_invoice b 
        on t1.home_store_id = b.home_store_id and t1.cust_no = b.cust_no and t1.auth_person_id = b.auth_person_id
        where b.date_of_day <='2020-06-08'
        group by t1.deliver_type, t1.home_store_id, t1.cust_no, t1.auth_person_id
        )with data;


select deliver_type, lifecycle, count(distinct auth_person_id||home_store_id||cust_no) from chnccp_msi_z.ganyu_temp_lifecycle_activation
group by 1,2;
select lifecycle, count(distinct auth_person_id||home_store_id||cust_no) from chnccp_msi_z.ganyu_temp_lifecycle_activation
group by 1;

--total 
select count(distinct auth_person_id||home_store_id||cust_no) from chnccp_msi_z.ganyu_temp_lifecycle_new;
select lifecycle, count(distinct auth_person_id||home_store_id||cust_no) from chnccp_msi_z.ganyu_temp_lifecycle_activation
group by lifecycle;


----------------------------------------------
-----------------------4----------------------

--uv
select CASE WHEN channel = '20051304A01MPY000' THEN 'pop-up'
            WHEN channel = '20051312A01WPY000' THEN 'posting'
            WHEN channel = '20051314A01LSY000' THEN 'liveshow'
            WHEN channel = '20051316A01BTY000' THEN 'sharing'
            ELSE 'other' END AS channel_in, count(distinct home_store_id||cust_no||auth_person_id) as uv from chnccp_msi_z.first_channel_userinfo
            where campaign_id = '20200610'
            group by channel_in;

--sales
select CASE WHEN a.channel = '20051304A01MPY000' THEN 'pop-up'
            WHEN a.channel = '20051312A01WPY000' THEN 'posting'
            WHEN a.channel = '20051314A01LSY000' THEN 'liveshow'
            WHEN a.channel = '20051316A01BTY000' THEN 'sharing'
            ELSE 'other' END AS channel_in, 
            count(distinct b.home_store_id||b.cust_no||b.auth_person_id) as buyer, sum(b.qty) as quantity, sum(b.sales) as sales from chnccp_msi_z.falshsales_0610 b 
            left join chnccp_msi_z.first_channel_userinfo a 
            on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
            where a.campaign_id = '20200610' and b.sales > 0
            group by channel_in;


select count(distinct home_store_id||cust_no||auth_person_id) as non_track from chnccp_msi_z.first_channel_userinfo where campaign_id = '20200610';
-----------------------------------------------
--------------------5--------------------------
--liveshow
drop table chnccp_msi_z.liveshow;
create table chnccp_msi_z.liveshow as (
    select a.home_store_id, a.cust_no, a.auth_person_id, a.sales, a.qty, a.deliver_type, a.art_name,
    CASE WHEN b.cust_no is NOT NULL THEN 1 ELSE 0 END AS liveshow from (select * from chnccp_msi_z.falshsales_0610 where sales > 0) a
    left join (select distinct home_store_id, cust_no, auth_person_id from chnccp_msi_z.liveshow_userinfo_all where campaign_id = '20200610') b
    on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id )with data;

select liveshow, count(distinct home_store_id||cust_no||auth_person_id) as buyer, count(home_store_id||cust_no||auth_person_id) as orders, sum(qty) as quantity, sum(sales) as sales from chnccp_msi_z.liveshow 
group by liveshow;

select count(distinct home_store_id||cust_no||auth_person_id) as uv from chnccp_msi_z.liveshow_userinfo_all where campaign_id = '20200610';

