--points >= 2
select a.home_store_id,count(*) as points
from  chnccp_dwh.dw_mcrm_loy_member a
inner join chnccp_dwh.dw_mcrm_loy_mem_balance b
on a.loy_mem_row_id = b.loy_mem_row_id
where a.loy_mem_parent_ind = 0
and b.loy_mem_num_available_pts >= 2
group by a.home_store_id
order by a.home_store_id;



--雪碧
select a.store_id,count(distinct a.home_store_id || a.cust_no) as buyer
from chnccp_dwh.dw_cust_invoice_line a
inner join chnccp_dwh.dw_art_var_tu  b
on a.art_no =b.art_no and a.var_tu_key = b.var_tu_key
where  b.art_name like '%雪碧%'
and a.date_of_day between add_months( date-1,-12) and date - 1
group by a.store_id
order by  a.store_id;

--伊利巧乐兹绮炫比利时巧克力脆层+香草口味冰淇淋65g  /   伊利须尽欢胡萝卜橙子酸奶冰淇淋 65g
select a.store_id,count(distinct a.home_store_id || a.cust_no) as buyer
from chnccp_dwh.dw_cust_invoice_line a
inner join chnccp_dwh.dw_art_var_tu  b
on a.art_no =b.art_no and a.var_tu_key = b.var_tu_key
where  b.art_name like '%冰淇淋%'
and a.month_id = 201906 
group by a.store_id;

--巴利特小麦黑啤酒 500ml
select a.store_id,count(distinct a.home_store_id || a.cust_no) as buyer
from chnccp_dwh.dw_cust_invoice_line a
inner join chnccp_dwh.dw_art_var_tu  b
on a.art_no =b.art_no and a.var_tu_key = b.var_tu_key
where (b.art_name like '%黑啤%' OR  (b.demand_field_domain_id = 605 and b.pcg_main_cat_id = 454))
and a.month_id in (201905, 201906, 201907)
group by a.store_id;

--蒙牛纯甄果粒轻酪乳白桃+石榴味风味酸奶230g
select a.store_id,count(distinct a.home_store_id || a.cust_no) as buyer
from chnccp_dwh.dw_cust_invoice_line a
inner join chnccp_dwh.dw_art_var_tu  b
on a.art_no =b.art_no and a.var_tu_key = b.var_tu_key
where  b.art_name like '%酸奶%'
and a.date_of_day between add_months( date-1,-12) and date - 1
group by a.store_id
order by  a.store_id;

--鹅岛312小麦风味艾尔啤酒 355ml瓶装
select a.store_id,count(distinct a.home_store_id || a.cust_no) as buyer
from chnccp_dwh.dw_cust_invoice_line a
inner join chnccp_dwh.dw_art_var_tu  b
on a.art_no =b.art_no and a.var_tu_key = b.var_tu_key
where (b.art_name like '%鹅岛%' OR  (b.demand_field_domain_id = 605 and b.pcg_main_cat_id = 453))
and a.month_id in (201905, 201906, 201907)
group by a.store_id;

--PATAGONIA帕塔歌尼亚白啤CAN听装473ml 

select a.store_id,count(distinct a.home_store_id || a.cust_no) as buyer
from chnccp_dwh.dw_cust_invoice_line a
inner join chnccp_dwh.dw_art_var_tu  b
on a.art_no =b.art_no and a.var_tu_key = b.var_tu_key
where (b.art_name like '%帕塔歌尼亚%' OR  (b.demand_field_domain_id = 605 and b.pcg_main_cat_id = 452))
and a.month_id in (201905, 201906, 201907)
group by a.store_id;

--多芬白桃果香浓密沐浴泡泡 400ml
select a.store_id,count(distinct a.home_store_id || a.cust_no) as buyer
from chnccp_dwh.dw_cust_invoice_line a
inner join chnccp_dwh.dw_art_var_tu  b
on a.art_no =b.art_no and a.var_tu_key = b.var_tu_key
where b.art_name like '%多芬%沐浴%'
and a.date_of_day between add_months( date-1,-12) and date - 1
group by a.store_id;

--redeemed from weekly report