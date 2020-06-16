----------------------------------------------------------------B1G1F-----------------------------------------------------------------------------
-------------part1
---------ttl
--CY
select count(distinct home_store_id||cust_no||auth_person_id) as buyer, sum(sell_val_gsp) as sales, count(distinct invoice_id) as invoice, 
sum(sell_val_nsp-sell_val_nnbp) as front_margin, sum(sell_val_gsp)/count(distinct invoice_id) as basket, (sum(sell_val_nsp-sell_val_nnbp)/sum(sell_val_nsp)) as marginrate
from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj
where date_of_day between '2020-06-04' and '2020-06-07'
and wel_ind = 'N' 
and fsd_ind = 'N' 
and deli_ind = 'N' 
and bvs_ind = 'N' 
and pcr_ind = 'N';

--participating

drop table chnccp_msi_z.participating_namelist;
create table chnccp_msi_z.participating_namelist
	as(select home_store_id, cust_no, auth_person_id, distinct invoice_id, sell_val_gsp, sell_val_nnbp, sell_val_nsp from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj
		where date_of_day between '2020-06-04' and '2020-06-07'
		and wel_ind = 'N' 
		and fsd_ind = 'N' 
		and deli_ind = 'N' 
		and bvs_ind = 'N' 
		and pcr_ind = 'N'
		and art_no in (167979,174407,214154,495638,203803,188061,138277,205809,150916,996346,61582,53447,995796,210187,210188,128538,199298,199299,208896,208898,208900,147656,549789,186665,204661,192544,192541,177291,199441,199439,59551,59552,192623,182502,139433,197314,197315,197321,197320,173805,18947,115184,182009,182012,215372,215371,196043,177636,212083,212086,200391,201270,129909,168622,175898,190361,190362,203718,189444,189445,189446,136626,189372,186463,187651,187652,187649,187650,177088,191756,191755,177089,210660,213832,716185,211108,203731,203732,155822,155823,155824,155825,155826,205725,167348,207195,212660,214295,214301,214302,201411,201413,201415,188544,201578,188543,173998,173999,213720,171653,185613,185614,199013,198857,199760,102345,99170,99182,99088,185457,538624,86407,86403,163590,207596,207597,199206,209576,209577,508133,204703,202116,197991,161641,214786,156586,208918,34046,198250,197647,214500,215412,171124,203380,43669,43671,170237,214384,214380,213807,146635,207975,186545,559934,559936,215345,214990,215252,214619,213114,213114,213115,213115)
		)with data;

select count(distinct b.home_store_id||b.cust_no||b.auth_person_id) as buyer, sum(b.sell_val_gsp) as sales, count(distinct b.invoice_id) as invoice, 
(sum(b.sell_val_nsp-b.sell_val_nnbp)) as front_margin, sum(b.sell_val_gsp)/count(distinct b.invoice_id) as basket, 
(sum(b.sell_val_nsp-b.sell_val_nnbp))/sum(b.sell_val_nsp) as front_margin_rate from (select distinct invoice_id from chnccp_msi_z.participating_namelist) a 
join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b 
on a.invoice_id = b.invoice_id
where b.date_of_day between '2020-06-04' and '2020-06-07'
and b.wel_ind = 'N' 
and b.fsd_ind = 'N' 
and b.deli_ind = 'N' 
and b.bvs_ind = 'N' 
and b.pcr_ind = 'N';


--promotion and cross
select sum(CASE WHEN b.art_no in (167979,174407,214154,495638,203803,188061,138277,205809,150916,996346,61582,53447,995796,210187,210188,128538,199298,199299,208896,208898,208900,147656,549789,186665,204661,192544,192541,177291,199441,199439,59551,59552,192623,182502,139433,197314,197315,197321,197320,173805,18947,115184,182009,182012,215372,215371,196043,177636,212083,212086,200391,201270,129909,168622,175898,190361,190362,203718,189444,189445,189446,136626,189372,186463,187651,187652,187649,187650,177088,191756,191755,177089,210660,213832,716185,211108,203731,203732,155822,155823,155824,155825,155826,205725,167348,207195,212660,214295,214301,214302,201411,201413,201415,188544,201578,188543,173998,173999,213720,171653,185613,185614,199013,198857,199760,102345,99170,99182,99088,185457,538624,86407,86403,163590,207596,207597,199206,209576,209577,508133,204703,202116,197991,161641,214786,156586,208918,34046,198250,197647,214500,215412,171124,203380,43669,43671,170237,214384,214380,213807,146635,207975,186545,559934,559936,215345,214990,215252,214619,213114,213114,213115,213115)THEN b.sell_val_gsp ELSE NULL END) as salesp, 
      sum (CASE WHEN b.art_no in (167979,174407,214154,495638,203803,188061,138277,205809,150916,996346,61582,53447,995796,210187,210188,128538,199298,199299,208896,208898,208900,147656,549789,186665,204661,192544,192541,177291,199441,199439,59551,59552,192623,182502,139433,197314,197315,197321,197320,173805,18947,115184,182009,182012,215372,215371,196043,177636,212083,212086,200391,201270,129909,168622,175898,190361,190362,203718,189444,189445,189446,136626,189372,186463,187651,187652,187649,187650,177088,191756,191755,177089,210660,213832,716185,211108,203731,203732,155822,155823,155824,155825,155826,205725,167348,207195,212660,214295,214301,214302,201411,201413,201415,188544,201578,188543,173998,173999,213720,171653,185613,185614,199013,198857,199760,102345,99170,99182,99088,185457,538624,86407,86403,163590,207596,207597,199206,209576,209577,508133,204703,202116,197991,161641,214786,156586,208918,34046,198250,197647,214500,215412,171124,203380,43669,43671,170237,214384,214380,213807,146635,207975,186545,559934,559936,215345,214990,215252,214619,213114,213114,213115,213115)THEN  (b.sell_val_nsp-b.sell_val_nnbp)ELSE NULL END) as salesp,
      sum (CASE WHEN b.art_no in (167979,174407,214154,495638,203803,188061,138277,205809,150916,996346,61582,53447,995796,210187,210188,128538,199298,199299,208896,208898,208900,147656,549789,186665,204661,192544,192541,177291,199441,199439,59551,59552,192623,182502,139433,197314,197315,197321,197320,173805,18947,115184,182009,182012,215372,215371,196043,177636,212083,212086,200391,201270,129909,168622,175898,190361,190362,203718,189444,189445,189446,136626,189372,186463,187651,187652,187649,187650,177088,191756,191755,177089,210660,213832,716185,211108,203731,203732,155822,155823,155824,155825,155826,205725,167348,207195,212660,214295,214301,214302,201411,201413,201415,188544,201578,188543,173998,173999,213720,171653,185613,185614,199013,198857,199760,102345,99170,99182,99088,185457,538624,86407,86403,163590,207596,207597,199206,209576,209577,508133,204703,202116,197991,161641,214786,156586,208918,34046,198250,197647,214500,215412,171124,203380,43669,43671,170237,214384,214380,213807,146635,207975,186545,559934,559936,215345,214990,215252,214619,213114,213114,213115,213115)THEN  (b.sell_val_nsp)ELSE NULL END) as salesnsp,
      sum( CASE WHEN b.art_no not in (167979,174407,214154,495638,203803,188061,138277,205809,150916,996346,61582,53447,995796,210187,210188,128538,199298,199299,208896,208898,208900,147656,549789,186665,204661,192544,192541,177291,199441,199439,59551,59552,192623,182502,139433,197314,197315,197321,197320,173805,18947,115184,182009,182012,215372,215371,196043,177636,212083,212086,200391,201270,129909,168622,175898,190361,190362,203718,189444,189445,189446,136626,189372,186463,187651,187652,187649,187650,177088,191756,191755,177089,210660,213832,716185,211108,203731,203732,155822,155823,155824,155825,155826,205725,167348,207195,212660,214295,214301,214302,201411,201413,201415,188544,201578,188543,173998,173999,213720,171653,185613,185614,199013,198857,199760,102345,99170,99182,99088,185457,538624,86407,86403,163590,207596,207597,199206,209576,209577,508133,204703,202116,197991,161641,214786,156586,208918,34046,198250,197647,214500,215412,171124,203380,43669,43671,170237,214384,214380,213807,146635,207975,186545,559934,559936,215345,214990,215252,214619,213114,213114,213115,213115)THEN b.sell_val_gsp ELSE NULL END) as salesc, 
      sum (CASE WHEN b.art_no not in (167979,174407,214154,495638,203803,188061,138277,205809,150916,996346,61582,53447,995796,210187,210188,128538,199298,199299,208896,208898,208900,147656,549789,186665,204661,192544,192541,177291,199441,199439,59551,59552,192623,182502,139433,197314,197315,197321,197320,173805,18947,115184,182009,182012,215372,215371,196043,177636,212083,212086,200391,201270,129909,168622,175898,190361,190362,203718,189444,189445,189446,136626,189372,186463,187651,187652,187649,187650,177088,191756,191755,177089,210660,213832,716185,211108,203731,203732,155822,155823,155824,155825,155826,205725,167348,207195,212660,214295,214301,214302,201411,201413,201415,188544,201578,188543,173998,173999,213720,171653,185613,185614,199013,198857,199760,102345,99170,99182,99088,185457,538624,86407,86403,163590,207596,207597,199206,209576,209577,508133,204703,202116,197991,161641,214786,156586,208918,34046,198250,197647,214500,215412,171124,203380,43669,43671,170237,214384,214380,213807,146635,207975,186545,559934,559936,215345,214990,215252,214619,213114,213114,213115,213115)THEN (b.sell_val_nsp-b.sell_val_nnbp) ELSE NULL END) as salesc,
      count(distinct  CASE WHEN b.art_no not in (167979,174407,214154,495638,203803,188061,138277,205809,150916,996346,61582,53447,995796,210187,210188,128538,199298,199299,208896,208898,208900,147656,549789,186665,204661,192544,192541,177291,199441,199439,59551,59552,192623,182502,139433,197314,197315,197321,197320,173805,18947,115184,182009,182012,215372,215371,196043,177636,212083,212086,200391,201270,129909,168622,175898,190361,190362,203718,189444,189445,189446,136626,189372,186463,187651,187652,187649,187650,177088,191756,191755,177089,210660,213832,716185,211108,203731,203732,155822,155823,155824,155825,155826,205725,167348,207195,212660,214295,214301,214302,201411,201413,201415,188544,201578,188543,173998,173999,213720,171653,185613,185614,199013,198857,199760,102345,99170,99182,99088,185457,538624,86407,86403,163590,207596,207597,199206,209576,209577,508133,204703,202116,197991,161641,214786,156586,208918,34046,198250,197647,214500,215412,171124,203380,43669,43671,170237,214384,214380,213807,146635,207975,186545,559934,559936,215345,214990,215252,214619,213114,213114,213115,213115)THEN b.invoice_id ELSE NULL END) as invoice 
      sum (CASE WHEN b.art_no not in (167979,174407,214154,495638,203803,188061,138277,205809,150916,996346,61582,53447,995796,210187,210188,128538,199298,199299,208896,208898,208900,147656,549789,186665,204661,192544,192541,177291,199441,199439,59551,59552,192623,182502,139433,197314,197315,197321,197320,173805,18947,115184,182009,182012,215372,215371,196043,177636,212083,212086,200391,201270,129909,168622,175898,190361,190362,203718,189444,189445,189446,136626,189372,186463,187651,187652,187649,187650,177088,191756,191755,177089,210660,213832,716185,211108,203731,203732,155822,155823,155824,155825,155826,205725,167348,207195,212660,214295,214301,214302,201411,201413,201415,188544,201578,188543,173998,173999,213720,171653,185613,185614,199013,198857,199760,102345,99170,99182,99088,185457,538624,86407,86403,163590,207596,207597,199206,209576,209577,508133,204703,202116,197991,161641,214786,156586,208918,34046,198250,197647,214500,215412,171124,203380,43669,43671,170237,214384,214380,213807,146635,207975,186545,559934,559936,215345,214990,215252,214619,213114,213114,213115,213115)THEN (b.sell_val_nsp) ELSE NULL END) as salescnsp,
      from (select distinct invoice_id from chnccp_msi_z.participating_namelist) a 
      join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b
      on a.invoice_id = b.invoice_id
      and b.wel_ind = 'N' 
      and b.fsd_ind = 'N' 
      and b.deli_ind = 'N' 
      and b.bvs_ind = 'N' 
      and b.pcr_ind = 'N';


-------
--PY 2019-06-06 to 2019-06-09
select count(distinct home_store_id||cust_no||auth_person_id) as buyer, sum(sell_val_gsp) as sales, count(distinct invoice_id) as invoice, 
sum(sell_val_nsp-sell_val_nnbp) as front_margin, sum(sell_val_gsp)/count(distinct invoice_id) as basket, (sum(sell_val_nsp-sell_val_nnbp)/sum(sell_val_nsp)) as marginrate
from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj
where date_of_day between '2019-06-06' and '2019-06-09'
and wel_ind = 'N' 
and fsd_ind = 'N' 
and deli_ind = 'N' 
and bvs_ind = 'N' 
and pcr_ind = 'N';

--participating
drop table chnccp_msi_z.participating_namelist_PY_1;
create table chnccp_msi_z.participating_namelist_PY_1
	as(select home_store_id, cust_no, auth_person_id, invoice_id, sell_val_gsp, sell_val_nnbp, sell_val_nsp from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj
		where date_of_day between '2019-06-06' and '2019-06-09'
		and wel_ind = 'N' 
		and fsd_ind = 'N' 
		and deli_ind = 'N' 
		and bvs_ind = 'N' 
		and pcr_ind = 'N'
		and art_no in (167979,174407,214154,495638,203803,188061,138277,205809,150916,996346,61582,53447,995796,210187,210188,128538,199298,199299,208896,208898,208900,147656,549789,186665,204661,192544,192541,177291,199441,199439,59551,59552,192623,182502,139433,197314,197315,197321,197320,173805,18947,115184,182009,182012,215372,215371,196043,177636,212083,212086,200391,201270,129909,168622,175898,190361,190362,203718,189444,189445,189446,136626,189372,186463,187651,187652,187649,187650,177088,191756,191755,177089,210660,213832,716185,211108,203731,203732,155822,155823,155824,155825,155826,205725,167348,207195,212660,214295,214301,214302,201411,201413,201415,188544,201578,188543,173998,173999,213720,171653,185613,185614,199013,198857,199760,102345,99170,99182,99088,185457,538624,86407,86403,163590,207596,207597,199206,209576,209577,508133,204703,202116,197991,161641,214786,156586,208918,34046,198250,197647,214500,215412,171124,203380,43669,43671,170237,214384,214380,213807,146635,207975,186545,559934,559936,215345,214990,215252,214619,213114,213114,213115,213115)
		)with data;

select count(distinct b.home_store_id||b.cust_no||b.auth_person_id) as buyer, sum(b.sell_val_gsp) as netsales, count(distinct b.invoice_id) as invoice, 
sum(b.sell_val_nsp-b.sell_val_nnbp) as front_margin, sum(b.sell_val_gsp)/count(distinct b.invoice_id) as basket, (sum(b.sell_val_nsp-b.sell_val_nnbp)/sum(b.sell_val_nsp)) as marginrate
from (select distinct invoice_id from chnccp_msi_z.participating_namelist_PY_1) a 
join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b 
on a.invoice_id = b.invoice_id
where b.date_of_day between '2019-06-06' and '2019-06-09'
and b.wel_ind = 'N' 
and b.fsd_ind = 'N' 
and b.deli_ind = 'N' 
and b.bvs_ind = 'N' 
and b.pcr_ind = 'N';

--promotion and cross
select sum(CASE WHEN b.art_no in (167979,174407,214154,495638,203803,188061,138277,205809,150916,996346,61582,53447,995796,210187,210188,128538,199298,199299,208896,208898,208900,147656,549789,186665,204661,192544,192541,177291,199441,199439,59551,59552,192623,182502,139433,197314,197315,197321,197320,173805,18947,115184,182009,182012,215372,215371,196043,177636,212083,212086,200391,201270,129909,168622,175898,190361,190362,203718,189444,189445,189446,136626,189372,186463,187651,187652,187649,187650,177088,191756,191755,177089,210660,213832,716185,211108,203731,203732,155822,155823,155824,155825,155826,205725,167348,207195,212660,214295,214301,214302,201411,201413,201415,188544,201578,188543,173998,173999,213720,171653,185613,185614,199013,198857,199760,102345,99170,99182,99088,185457,538624,86407,86403,163590,207596,207597,199206,209576,209577,508133,204703,202116,197991,161641,214786,156586,208918,34046,198250,197647,214500,215412,171124,203380,43669,43671,170237,214384,214380,213807,146635,207975,186545,559934,559936,215345,214990,215252,214619,213114,213114,213115,213115)THEN b.sell_val_gsp ELSE NULL END) as salesp, 
      sum (CASE WHEN b.art_no in (167979,174407,214154,495638,203803,188061,138277,205809,150916,996346,61582,53447,995796,210187,210188,128538,199298,199299,208896,208898,208900,147656,549789,186665,204661,192544,192541,177291,199441,199439,59551,59552,192623,182502,139433,197314,197315,197321,197320,173805,18947,115184,182009,182012,215372,215371,196043,177636,212083,212086,200391,201270,129909,168622,175898,190361,190362,203718,189444,189445,189446,136626,189372,186463,187651,187652,187649,187650,177088,191756,191755,177089,210660,213832,716185,211108,203731,203732,155822,155823,155824,155825,155826,205725,167348,207195,212660,214295,214301,214302,201411,201413,201415,188544,201578,188543,173998,173999,213720,171653,185613,185614,199013,198857,199760,102345,99170,99182,99088,185457,538624,86407,86403,163590,207596,207597,199206,209576,209577,508133,204703,202116,197991,161641,214786,156586,208918,34046,198250,197647,214500,215412,171124,203380,43669,43671,170237,214384,214380,213807,146635,207975,186545,559934,559936,215345,214990,215252,214619,213114,213114,213115,213115)THEN  (b.sell_val_nsp-b.sell_val_nnbp)ELSE NULL END) as salesp,
      sum (CASE WHEN b.art_no in (167979,174407,214154,495638,203803,188061,138277,205809,150916,996346,61582,53447,995796,210187,210188,128538,199298,199299,208896,208898,208900,147656,549789,186665,204661,192544,192541,177291,199441,199439,59551,59552,192623,182502,139433,197314,197315,197321,197320,173805,18947,115184,182009,182012,215372,215371,196043,177636,212083,212086,200391,201270,129909,168622,175898,190361,190362,203718,189444,189445,189446,136626,189372,186463,187651,187652,187649,187650,177088,191756,191755,177089,210660,213832,716185,211108,203731,203732,155822,155823,155824,155825,155826,205725,167348,207195,212660,214295,214301,214302,201411,201413,201415,188544,201578,188543,173998,173999,213720,171653,185613,185614,199013,198857,199760,102345,99170,99182,99088,185457,538624,86407,86403,163590,207596,207597,199206,209576,209577,508133,204703,202116,197991,161641,214786,156586,208918,34046,198250,197647,214500,215412,171124,203380,43669,43671,170237,214384,214380,213807,146635,207975,186545,559934,559936,215345,214990,215252,214619,213114,213114,213115,213115)THEN  (b.sell_val_nsp)ELSE NULL END) as salesnsp,
      sum( CASE WHEN b.art_no not in (167979,174407,214154,495638,203803,188061,138277,205809,150916,996346,61582,53447,995796,210187,210188,128538,199298,199299,208896,208898,208900,147656,549789,186665,204661,192544,192541,177291,199441,199439,59551,59552,192623,182502,139433,197314,197315,197321,197320,173805,18947,115184,182009,182012,215372,215371,196043,177636,212083,212086,200391,201270,129909,168622,175898,190361,190362,203718,189444,189445,189446,136626,189372,186463,187651,187652,187649,187650,177088,191756,191755,177089,210660,213832,716185,211108,203731,203732,155822,155823,155824,155825,155826,205725,167348,207195,212660,214295,214301,214302,201411,201413,201415,188544,201578,188543,173998,173999,213720,171653,185613,185614,199013,198857,199760,102345,99170,99182,99088,185457,538624,86407,86403,163590,207596,207597,199206,209576,209577,508133,204703,202116,197991,161641,214786,156586,208918,34046,198250,197647,214500,215412,171124,203380,43669,43671,170237,214384,214380,213807,146635,207975,186545,559934,559936,215345,214990,215252,214619,213114,213114,213115,213115)THEN b.sell_val_gsp ELSE NULL END) as salesc, 
      sum (CASE WHEN b.art_no not in (167979,174407,214154,495638,203803,188061,138277,205809,150916,996346,61582,53447,995796,210187,210188,128538,199298,199299,208896,208898,208900,147656,549789,186665,204661,192544,192541,177291,199441,199439,59551,59552,192623,182502,139433,197314,197315,197321,197320,173805,18947,115184,182009,182012,215372,215371,196043,177636,212083,212086,200391,201270,129909,168622,175898,190361,190362,203718,189444,189445,189446,136626,189372,186463,187651,187652,187649,187650,177088,191756,191755,177089,210660,213832,716185,211108,203731,203732,155822,155823,155824,155825,155826,205725,167348,207195,212660,214295,214301,214302,201411,201413,201415,188544,201578,188543,173998,173999,213720,171653,185613,185614,199013,198857,199760,102345,99170,99182,99088,185457,538624,86407,86403,163590,207596,207597,199206,209576,209577,508133,204703,202116,197991,161641,214786,156586,208918,34046,198250,197647,214500,215412,171124,203380,43669,43671,170237,214384,214380,213807,146635,207975,186545,559934,559936,215345,214990,215252,214619,213114,213114,213115,213115)THEN (b.sell_val_nsp-b.sell_val_nnbp) ELSE NULL END) as salesc,
      count(distinct  CASE WHEN b.art_no not in (167979,174407,214154,495638,203803,188061,138277,205809,150916,996346,61582,53447,995796,210187,210188,128538,199298,199299,208896,208898,208900,147656,549789,186665,204661,192544,192541,177291,199441,199439,59551,59552,192623,182502,139433,197314,197315,197321,197320,173805,18947,115184,182009,182012,215372,215371,196043,177636,212083,212086,200391,201270,129909,168622,175898,190361,190362,203718,189444,189445,189446,136626,189372,186463,187651,187652,187649,187650,177088,191756,191755,177089,210660,213832,716185,211108,203731,203732,155822,155823,155824,155825,155826,205725,167348,207195,212660,214295,214301,214302,201411,201413,201415,188544,201578,188543,173998,173999,213720,171653,185613,185614,199013,198857,199760,102345,99170,99182,99088,185457,538624,86407,86403,163590,207596,207597,199206,209576,209577,508133,204703,202116,197991,161641,214786,156586,208918,34046,198250,197647,214500,215412,171124,203380,43669,43671,170237,214384,214380,213807,146635,207975,186545,559934,559936,215345,214990,215252,214619,213114,213114,213115,213115)THEN b.invoice_id ELSE NULL END) as invoice,
      sum (CASE WHEN b.art_no not in (167979,174407,214154,495638,203803,188061,138277,205809,150916,996346,61582,53447,995796,210187,210188,128538,199298,199299,208896,208898,208900,147656,549789,186665,204661,192544,192541,177291,199441,199439,59551,59552,192623,182502,139433,197314,197315,197321,197320,173805,18947,115184,182009,182012,215372,215371,196043,177636,212083,212086,200391,201270,129909,168622,175898,190361,190362,203718,189444,189445,189446,136626,189372,186463,187651,187652,187649,187650,177088,191756,191755,177089,210660,213832,716185,211108,203731,203732,155822,155823,155824,155825,155826,205725,167348,207195,212660,214295,214301,214302,201411,201413,201415,188544,201578,188543,173998,173999,213720,171653,185613,185614,199013,198857,199760,102345,99170,99182,99088,185457,538624,86407,86403,163590,207596,207597,199206,209576,209577,508133,204703,202116,197991,161641,214786,156586,208918,34046,198250,197647,214500,215412,171124,203380,43669,43671,170237,214384,214380,213807,146635,207975,186545,559934,559936,215345,214990,215252,214619,213114,213114,213115,213115)THEN (b.sell_val_nsp) ELSE NULL END) as salesc,
      from (select distinct invoice_id from chnccp_msi_z.participating_namelist_PY_1) a 
      join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b
      on a.invoice_id = b.invoice_id
      where b.date_of_day between '2019-06-06' and '2019-06-09'
      and b.wel_ind = 'N' 
      and b.fsd_ind = 'N' 
      and b.deli_ind = 'N' 
      and b.bvs_ind = 'N' 
      and b.pcr_ind = 'N';

--------------part2
--CY
drop table chnccp_msi_z.B1G1F_namelist;
create table chnccp_msi_z.B1G1F_namelist
	as(select home_store_id, cust_no, auth_person_id from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj
        where date_of_day between '2020-06-04' and '2020-06-07'
        and wel_ind = 'N' 
        and fsd_ind = 'N' 
        and deli_ind = 'N' 
        and bvs_ind = 'N' 
        and pcr_ind = 'N'
        group by home_store_id, cust_no, auth_person_id
		)with data;

--lifecycle
drop table chnccp_msi_z.B1G1F_namelist_new;
create table chnccp_msi_z.B1G1F_namelist_new
	as(select a.*, b.date_created from chnccp_msi_z.B1G1F_namelist a 
		left join chnccp_dwh.dw_cust_auth_person b 
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		where b.date_created between '2020-06-04' and '2020-06-07'
		)with data;

select count(*) from chnccp_msi_z.B1G1F_namelist_new;

drop table chnccp_msi_z.B1G1F_namelist_lifecycle;
create table chnccp_msi_z.B1G1F_namelist_lifecycle
	as(select a.* from chnccp_msi_z.B1G1F_namelist a
		left join chnccp_msi_z.B1G1F_namelist_new b 
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		where b.cust_no is NULL
		)with data;

--regular
select count(distinct b.home_store_id||b.cust_no||b.auth_person_id) from chnccp_msi_z.B1G1F_namelist_lifecycle t1
left join chnccp_dwh.dw_cust_invoice b 
on t1.home_store_id = b.home_store_id and t1.cust_no = b.cust_no and t1.auth_person_id = b.auth_person_id
where b.date_of_day < '2020-06-04'
having max(b.date_of_day)between '2020-03-04' and '2020-06-03';

---------------------------------
--CY
drop table chnccp_msi_z.B1G1F_namelist_new;
create table chnccp_msi_z.B1G1F_namelist_new
	as(select a.*, b.date_created from chnccp_msi_z.participating_namelist a 
		left join chnccp_dwh.dw_cust_auth_person b 
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		where b.date_created between '2020-06-04' and '2020-06-07'
		)with data;

select count(*) from chnccp_msi_z.B1G1F_namelist_new;

drop table chnccp_msi_z.B1G1F_namelist_lifecycle;
create table chnccp_msi_z.B1G1F_namelist_lifecycle
	as(select a.* from chnccp_msi_z.participating_namelist a
		left join chnccp_msi_z.B1G1F_namelist_new b 
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		where b.cust_no is NULL
		)with data;

--regular
select count(distinct b.home_store_id||b.cust_no||b.auth_person_id) from chnccp_msi_z.B1G1F_namelist_lifecycle t1
left join chnccp_dwh.dw_cust_invoice b 
on t1.home_store_id = b.home_store_id and t1.cust_no = b.cust_no and t1.auth_person_id = b.auth_person_id
where b.date_of_day < '2020-06-04'
having max(b.date_of_day)between '2020-03-04' and '2020-06-03';

--------------tag
select count(distinct a.home_store_id||a.cust_no||a.auth_person_id) as UMC from chnccp_msi_z.participating_namelist a 
join chnccp_msi_z.mem_ref_lifecycle_tag_hist b 
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
where b.calc_yearmonth = 201907
and b.cy_sales between 400 and 1000;

--UMC & potential
drop table chnccp_msi_z.B1G1F_namelist_umcpotential;
create table chnccp_msi_z.B1G1F_namelist_umcpotential 
as(select a.home_store_id, a.cust_no, a.auth_person_id from 
((select a.home_store_id, a.cust_no, a.auth_person_id from chnccp_msi_z.participating_namelist a 
join chnccp_msi_z.mem_ref_umc_tag_act b 
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
where b.member_type = 'UMC+')
Union
(select a.home_store_id, a.cust_no, a.auth_person_id from chnccp_msi_z.participating_namelist a 
join chnccp_crm.UMC_scoring_result b 
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
having sum(b.Tencent_Model_Plan4_Score)>=8 
group by a.home_store_id, a.cust_no, a.auth_person_id)
)a )with data;

select count(*) from chnccp_msi_z.B1G1F_namelist_umcpotential;

--fan
select count(distinct a.home_store_id||a.cust_no||a.auth_person_id) as fan from chnccp_msi_z.participating_namelist a 
join chnccp_msi_z.mem_ref_umc_tag_act b
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
where b.fan_ind = 'Y';

-------------------------------
--PY
drop table chnccp_msi_z.participating_namelist;
create table chnccp_msi_z.participating_namelist
	as(select home_store_id, cust_no, auth_person_id from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj
		where date_of_day between '2019-06-06' and '2019-06-09'
		and wel_ind = 'N' 
		and fsd_ind = 'N' 
		and deli_ind = 'N' 
		and bvs_ind = 'N' 
		and pcr_ind = 'N'
		and art_no in (167979,174407,214154,495638,203803,188061,138277,205809,150916,996346,61582,53447,995796,210187,210188,128538,199298,199299,208896,208898,208900,147656,549789,186665,204661,192544,192541,177291,199441,199439,59551,59552,192623,182502,139433,197314,197315,197321,197320,173805,18947,115184,182009,182012,215372,215371,196043,177636,212083,212086,200391,201270,129909,168622,175898,190361,190362,203718,189444,189445,189446,136626,189372,186463,187651,187652,187649,187650,177088,191756,191755,177089,210660,213832,716185,211108,203731,203732,155822,155823,155824,155825,155826,205725,167348,207195,212660,214295,214301,214302,201411,201413,201415,188544,201578,188543,173998,173999,213720,171653,185613,185614,199013,198857,199760,102345,99170,99182,99088,185457,538624,86407,86403,163590,207596,207597,199206,209576,209577,508133,204703,202116,197991,161641,214786,156586,208918,34046,198250,197647,214500,215412,171124,203380,43669,43671,170237,214384,214380,213807,146635,207975,186545,559934,559936,215345,214990,215252,214619,213114,213114,213115,213115)
		group by home_store_id, cust_no, auth_person_id
		)with data;

drop table chnccp_msi_z.B1G1F_namelist_new;
create table chnccp_msi_z.B1G1F_namelist_new
	as(select a.*, b.date_created from chnccp_msi_z.participating_namelist a 
		left join chnccp_dwh.dw_cust_auth_person b 
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		where b.date_created between '2019-06-06' and '2019-06-09'
		)with data;

select count(*) from chnccp_msi_z.B1G1F_namelist_new;

drop table chnccp_msi_z.B1G1F_namelist_lifecycle;
create table chnccp_msi_z.B1G1F_namelist_lifecycle
	as(select a.* from chnccp_msi_z.participating_namelist a
		left join chnccp_msi_z.B1G1F_namelist_new b 
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		where b.cust_no is NULL
		)with data;

--regular
select count(distinct b.home_store_id||b.cust_no||b.auth_person_id) from chnccp_msi_z.B1G1F_namelist_lifecycle t1
left join chnccp_dwh.dw_cust_invoice b 
on t1.home_store_id = b.home_store_id and t1.cust_no = b.cust_no and t1.auth_person_id = b.auth_person_id
where b.date_of_day < '2019-06-06'
having max(b.date_of_day)between '2019-03-06' and '2019-06-05';

--------------tag
select count(distinct a.home_store_id||a.cust_no||a.auth_person_id) as UMC from chnccp_msi_z.participating_namelist a 
join chnccp_msi_z.mem_ref_umc_tag_act b 
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
where b.member_type = 'UMC+' ;

--UMC & potential
drop table chnccp_msi_z.B1G1F_namelist_umcpotential;
create table chnccp_msi_z.B1G1F_namelist_umcpotential 
as(select a.home_store_id, a.cust_no, a.auth_person_id from 
((select a.home_store_id, a.cust_no, a.auth_person_id from chnccp_msi_z.participating_namelist a 
join chnccp_msi_z.mem_ref_umc_tag_act b 
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
where b.member_type = 'UMC+')
Union
(select a.home_store_id, a.cust_no, a.auth_person_id from chnccp_msi_z.participating_namelist a 
join chnccp_crm.UMC_scoring_result b 
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
having sum(b.Tencent_Model_Plan4_Score)>=8 
group by a.home_store_id, a.cust_no, a.auth_person_id)
)a )with data;

select count(*) from chnccp_msi_z.B1G1F_namelist_umcpotential;

--fan
select count(distinct a.home_store_id||a.cust_no||a.auth_person_id) as fan from chnccp_msi_z.participating_namelist a 
join chnccp_msi_z.mem_ref_umc_tag_act b
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
where b.fan_ind = 'Y';

-----------------------------------------------
----------tag
--UMC
select count(distinct a.home_store_id||a.cust_no||a.auth_person_id) as UMC from chnccp_msi_z.B1G1F_namelist a 
join chnccp_msi_z.mem_ref_umc_tag_act b 
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
where b.member_type = 'UMC+' ;

--UMC & potential
drop table chnccp_msi_z.B1G1F_namelist_umcpotential;
create table chnccp_msi_z.B1G1F_namelist_umcpotential 
as(select a.home_store_id, a.cust_no, a.auth_person_id from 
((select a.home_store_id, a.cust_no, a.auth_person_id from chnccp_msi_z.B1G1F_namelist a 
join chnccp_msi_z.mem_ref_umc_tag_act b 
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
where b.member_type = 'UMC+')
Union
(select a.home_store_id, a.cust_no, a.auth_person_id from chnccp_msi_z.B1G1F_namelist a 
join chnccp_crm.UMC_scoring_result b 
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
having sum(b.Tencent_Model_Plan4_Score)>=8 
group by a.home_store_id, a.cust_no, a.auth_person_id)
)a )with data;

select count(*) from chnccp_msi_z.B1G1F_namelist_umcpotential;

--fan
select count(distinct a.home_store_id||a.cust_no||a.auth_person_id) as fan from chnccp_msi_z.B1G1F_namelist a 
join chnccp_msi_z.mem_ref_umc_tag_act b
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
where b.fan_ind = 'Y';


--------------------
--PY
drop table chnccp_msi_z.B1G1F_namelist_PY;
create table chnccp_msi_z.B1G1F_namelist_PY
	as(select home_store_id, cust_no, auth_person_id from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj
        where date_of_day between '2019-06-06' and '2019-06-09'
        and wel_ind = 'N' 
        and fsd_ind = 'N' 
        and deli_ind = 'N' 
        and bvs_ind = 'N' 
        and pcr_ind = 'N'
        group by home_store_id, cust_no, auth_person_id
		)with data;

--lifecycle
drop table chnccp_msi_z.B1G1F_namelist_new_PY;
create table chnccp_msi_z.B1G1F_namelist_new_PY
	as(select a.*, b.date_created from chnccp_msi_z.B1G1F_namelist a 
		left join chnccp_dwh.dw_cust_auth_person b 
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		where b.date_created between '2019-06-06' and '2019-06-09'
		)with data;

select count(*) from chnccp_msi_z.B1G1F_namelist_new;

drop table chnccp_msi_z.B1G1F_namelist_lifecycle_PY;
create table chnccp_msi_z.B1G1F_namelist_lifecycle_PY
	as(select a.* from chnccp_msi_z.B1G1F_namelist a
		left join chnccp_msi_z.B1G1F_namelist_new b 
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		where b.cust_no is NULL
		)with data;

--reactivation
select count(distinct b.home_store_id||b.cust_no||b.auth_person_id) from chnccp_msi_z.B1G1F_namelist_lifecycle_PY t1
left join chnccp_dwh.dw_cust_invoice b 
on t1.home_store_id = b.home_store_id and t1.cust_no = b.cust_no and t1.auth_person_id = b.auth_person_id
where b.date_of_day < '2019-06-06'
having max(b.date_of_day)between '2019-03-06' and '2019-06-05';


----------tag
--UMC rolling 12 months
select count(distinct a.home_store_id||a.cust_no||a.auth_person_id) as UMC from chnccp_msi_z.participating_namelist_PY_1 a 
join chnccp_msi_z.mem_ref_lifecycle_tag_hist b
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
where b.cy_sales between 400 and 1000
and b.calc_yearmonth = 201907;

--UMC & potential
drop table chnccp_msi_z.B1G1F_namelist_umcpotential;
create table chnccp_msi_z.B1G1F_namelist_umcpotential 
as(select a.home_store_id, a.cust_no, a.auth_person_id from 
((select a.home_store_id, a.cust_no, a.auth_person_id from chnccp_msi_z.participating_namelist_PY_1 a 
join chnccp_msi_z.mem_ref_lifecycle_tag_hist b
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
where b.cy_sales between 400 and 1000
and b.calc_yearmonth = 201907)
Union
(select a.home_store_id, a.cust_no, a.auth_person_id from chnccp_msi_z.participating_namelist_PY_1 a 
join chnccp_crm.UMC_scoring_result b 
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
having sum(b.Tencent_Model_Plan4_Score)>=8 
group by a.home_store_id, a.cust_no, a.auth_person_id)
)a )with data;

select count(*) from chnccp_msi_z.B1G1F_namelist_umcpotential;

--fan
select count(distinct a.home_store_id||a.cust_no||a.auth_person_id) as fan from chnccp_msi_z.participating_namelist_PY_1 a 
join chnccp_msi_z.mem_ref_lifecycle_tag_hist b
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
where b.cy_visits_grp = '3) >=8 visits';


------------------------part3 SMS
--------------------------------------------------S1G1F namelist-----------------------------------------------
-------UMC group
drop table chnccp_msi_z.B1G1F_seg2_nolastmonth_both_UMC_noday_final_UMC_control;
create table chnccp_msi_z.B1G1F_seg2_nolastmonth_both_UMC_noday_final_UMC_control
	as(select * from chnccp_msi_z.B1G1F_seg2_nolastmonth_both_UMC_noday_final
		where UMC = 'UMC' sample 13560
		)with data;

drop table chnccp_msi_z.B1G1F_seg2_nolastmonth_both_UMC_noday_final_UMC_sending;
create table chnccp_msi_z.B1G1F_seg2_nolastmonth_both_UMC_noday_final_UMC_sending
	as(select a.* from chnccp_msi_z.B1G1F_seg2_nolastmonth_both_UMC_noday_final a
		left join chnccp_msi_z.B1G1F_seg2_nolastmonth_both_UMC_noday_final_UMC_control b 
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		where b.cust_no is NULL and a.UMC = 'UMC'
		)with data;

-------Other group
drop table chnccp_msi_z.B1G1F_seg2_nolastmonth_both_UMC_noday_final_other_control;
create table chnccp_msi_z.B1G1F_seg2_nolastmonth_both_UMC_noday_final_other_control
	as(select * from chnccp_msi_z.B1G1F_seg2_nolastmonth_both_UMC_noday_final
		where UMC = 'Other' sample 30112
		)with data;

drop table chnccp_msi_z.B1G1F_seg2_nolastmonth_both_UMC_noday_final_other_sending;
create table chnccp_msi_z.B1G1F_seg2_nolastmonth_both_UMC_noday_final_other_sending
	as(select a.* from chnccp_msi_z.B1G1F_seg2_nolastmonth_both_UMC_noday_final a
		left join chnccp_msi_z.B1G1F_seg2_nolastmonth_both_UMC_noday_final_other_control b 
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		where b.cust_no is NULL and a.UMC = 'Other' 
		)with data;


-------total 
--sending
drop table chnccp_msi_z.B1G1F_seg2_nolastmonth_both_UMC_noday_final_group;
create table chnccp_msi_z.B1G1F_seg2_nolastmonth_both_UMC_noday_final_group
	as(select a.* from
		((select 'sending' as sending, 'umc' as umc,  home_store_id, cust_no, auth_person_id from chnccp_msi_z.B1G1F_seg2_nolastmonth_both_UMC_noday_final_UMC_sending)
		Union
		(select 'sending' as sending, 'other' as umc, home_store_id, cust_no, auth_person_id from chnccp_msi_z.B1G1F_seg2_nolastmonth_both_UMC_noday_final_other_sending)
		Union
		(select 'control' as sending, 'umc' as umc, home_store_id, cust_no, auth_person_id from chnccp_msi_z.B1G1F_seg2_nolastmonth_both_UMC_noday_final_UMC_control)
		Union
		(select 'control' as sending, 'other' as umc,home_store_id, cust_no, auth_person_id from chnccp_msi_z.B1G1F_seg2_nolastmonth_both_UMC_noday_final_other_control)) a
		)with data;


--buying rate
select sending, count(distinct a.home_store_id||a.cust_no||a.auth_person_id) as total from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj a 
join chnccp_msi_z.B1G1F_seg2_nolastmonth_both_UMC_noday_final_group b 
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
where a.date_of_day between '2020-06-05' and '2020-06-07'
and a.wel_ind = 'N' 
and a.fsd_ind = 'N' 
and a.deli_ind = 'N' 
and a.bvs_ind = 'N' 
and a.pcr_ind = 'N'
group by sending;

select umc, sending, count(distinct a.home_store_id||a.cust_no||a.auth_person_id) as total from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj a 
join chnccp_msi_z.B1G1F_seg2_nolastmonth_both_UMC_noday_final_group b 
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
where a.date_of_day between '2020-06-05' and '2020-06-07'
and a.wel_ind = 'N' 
and a.fsd_ind = 'N' 
and a.deli_ind = 'N' 
and a.bvs_ind = 'N' 
and a.pcr_ind = 'N'
group by umc, sending;


select umc, sending, count(distinct a.home_store_id||a.cust_no||a.auth_person_id) as buyer, sum(b.sell_val_gsp) as netsales, count(distinct invoice_id) as invoice, 
sum(b.sell_val_nsp-b.sell_val_nnbp) as front_margin, sum(b.sell_val_gsp)/count(distinct b.invoice_id) as basket, (sum(b.sell_val_nsp-b.sell_val_nnbp)/sum(b.sell_val_nsp)) as marginrate
from chnccp_msi_z.B1G1F_seg2_nolastmonth_both_UMC_noday_final_group a 
join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b 
on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
where b.date_of_day between '2020-06-05' and '2020-06-07'
and b.wel_ind = 'N' 
and b.fsd_ind = 'N' 
and b.deli_ind = 'N' 
and b.bvs_ind = 'N' 
and b.pcr_ind = 'N'
group by umc, sending
order by umc, sending;


--participating
drop table chnccp_msi_z.participating_namelist_group;
create table chnccp_msi_z.participating_namelist_group
	as(select b.*, a.invoice_id from chnccp_fls.view_frank_auth_person_invoice_line_channel_adj a 
		join chnccp_msi_z.B1G1F_seg2_nolastmonth_both_UMC_noday_final_group b
		on a.home_store_id = b.home_store_id and a.cust_no = b.cust_no and a.auth_person_id = b.auth_person_id
		where a.date_of_day between '2020-06-05' and '2020-06-07'
		and a.wel_ind = 'N' 
		and a.fsd_ind = 'N' 
		and a.deli_ind = 'N' 
		and a.bvs_ind = 'N' 
		and a.pcr_ind = 'N'
		and a.art_no in (167979,174407,214154,495638,203803,188061,138277,205809,150916,996346,61582,53447,995796,210187,210188,128538,199298,199299,208896,208898,208900,147656,549789,186665,204661,192544,192541,177291,199441,199439,59551,59552,192623,182502,139433,197314,197315,197321,197320,173805,18947,115184,182009,182012,215372,215371,196043,177636,212083,212086,200391,201270,129909,168622,175898,190361,190362,203718,189444,189445,189446,136626,189372,186463,187651,187652,187649,187650,177088,191756,191755,177089,210660,213832,716185,211108,203731,203732,155822,155823,155824,155825,155826,205725,167348,207195,212660,214295,214301,214302,201411,201413,201415,188544,201578,188543,173998,173999,213720,171653,185613,185614,199013,198857,199760,102345,99170,99182,99088,185457,538624,86407,86403,163590,207596,207597,199206,209576,209577,508133,204703,202116,197991,161641,214786,156586,208918,34046,198250,197647,214500,215412,171124,203380,43669,43671,170237,214384,214380,213807,146635,207975,186545,559934,559936,215345,214990,215252,214619,213114,213114,213115,213115)
		group by b.home_store_id, b.cust_no, b.auth_person_id, a.invoice_id, b.umc, b.sending
		)with data;


select c.sending, count(distinct b.home_store_id||b.cust_no||b.auth_person_id) as buyer, sum(b.sell_val_gsp) as sales, count(distinct b.invoice_id) as invoice, 
(sum(b.sell_val_nsp-b.sell_val_nnbp)) as front_margin, sum(b.sell_val_gsp)/count(distinct b.invoice_id) as basket, 
(sum(b.sell_val_nsp-b.sell_val_nnbp))/sum(b.sell_val_nsp) as front_margin_rate from (select distinct invoice_id from chnccp_msi_z.participating_namelist_group) a 
join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b 
on a.invoice_id = b.invoice_id
where b.date_of_day between '2020-06-05' and '2020-06-07'
and b.wel_ind = 'N' 
and b.fsd_ind = 'N' 
and b.deli_ind = 'N' 
and b.bvs_ind = 'N' 
and b.pcr_ind = 'N';


--promotion and cross
--sending
select c.sending, sum(CASE WHEN b.art_no in (167979,174407,214154,495638,203803,188061,138277,205809,150916,996346,61582,53447,995796,210187,210188,128538,199298,199299,208896,208898,208900,147656,549789,186665,204661,192544,192541,177291,199441,199439,59551,59552,192623,182502,139433,197314,197315,197321,197320,173805,18947,115184,182009,182012,215372,215371,196043,177636,212083,212086,200391,201270,129909,168622,175898,190361,190362,203718,189444,189445,189446,136626,189372,186463,187651,187652,187649,187650,177088,191756,191755,177089,210660,213832,716185,211108,203731,203732,155822,155823,155824,155825,155826,205725,167348,207195,212660,214295,214301,214302,201411,201413,201415,188544,201578,188543,173998,173999,213720,171653,185613,185614,199013,198857,199760,102345,99170,99182,99088,185457,538624,86407,86403,163590,207596,207597,199206,209576,209577,508133,204703,202116,197991,161641,214786,156586,208918,34046,198250,197647,214500,215412,171124,203380,43669,43671,170237,214384,214380,213807,146635,207975,186545,559934,559936,215345,214990,215252,214619,213114,213114,213115,213115)THEN b.sell_val_gsp ELSE NULL END) as salesp, 
      sum (CASE WHEN b.art_no in (167979,174407,214154,495638,203803,188061,138277,205809,150916,996346,61582,53447,995796,210187,210188,128538,199298,199299,208896,208898,208900,147656,549789,186665,204661,192544,192541,177291,199441,199439,59551,59552,192623,182502,139433,197314,197315,197321,197320,173805,18947,115184,182009,182012,215372,215371,196043,177636,212083,212086,200391,201270,129909,168622,175898,190361,190362,203718,189444,189445,189446,136626,189372,186463,187651,187652,187649,187650,177088,191756,191755,177089,210660,213832,716185,211108,203731,203732,155822,155823,155824,155825,155826,205725,167348,207195,212660,214295,214301,214302,201411,201413,201415,188544,201578,188543,173998,173999,213720,171653,185613,185614,199013,198857,199760,102345,99170,99182,99088,185457,538624,86407,86403,163590,207596,207597,199206,209576,209577,508133,204703,202116,197991,161641,214786,156586,208918,34046,198250,197647,214500,215412,171124,203380,43669,43671,170237,214384,214380,213807,146635,207975,186545,559934,559936,215345,214990,215252,214619,213114,213114,213115,213115)THEN  (b.sell_val_nsp-b.sell_val_nnbp)ELSE NULL END) as frontmarginp,
      count(distinct  CASE WHEN b.art_no in (167979,174407,214154,495638,203803,188061,138277,205809,150916,996346,61582,53447,995796,210187,210188,128538,199298,199299,208896,208898,208900,147656,549789,186665,204661,192544,192541,177291,199441,199439,59551,59552,192623,182502,139433,197314,197315,197321,197320,173805,18947,115184,182009,182012,215372,215371,196043,177636,212083,212086,200391,201270,129909,168622,175898,190361,190362,203718,189444,189445,189446,136626,189372,186463,187651,187652,187649,187650,177088,191756,191755,177089,210660,213832,716185,211108,203731,203732,155822,155823,155824,155825,155826,205725,167348,207195,212660,214295,214301,214302,201411,201413,201415,188544,201578,188543,173998,173999,213720,171653,185613,185614,199013,198857,199760,102345,99170,99182,99088,185457,538624,86407,86403,163590,207596,207597,199206,209576,209577,508133,204703,202116,197991,161641,214786,156586,208918,34046,198250,197647,214500,215412,171124,203380,43669,43671,170237,214384,214380,213807,146635,207975,186545,559934,559936,215345,214990,215252,214619,213114,213114,213115,213115)THEN b.invoice_id ELSE NULL END) as invoicep,
      sum (CASE WHEN b.art_no in (167979,174407,214154,495638,203803,188061,138277,205809,150916,996346,61582,53447,995796,210187,210188,128538,199298,199299,208896,208898,208900,147656,549789,186665,204661,192544,192541,177291,199441,199439,59551,59552,192623,182502,139433,197314,197315,197321,197320,173805,18947,115184,182009,182012,215372,215371,196043,177636,212083,212086,200391,201270,129909,168622,175898,190361,190362,203718,189444,189445,189446,136626,189372,186463,187651,187652,187649,187650,177088,191756,191755,177089,210660,213832,716185,211108,203731,203732,155822,155823,155824,155825,155826,205725,167348,207195,212660,214295,214301,214302,201411,201413,201415,188544,201578,188543,173998,173999,213720,171653,185613,185614,199013,198857,199760,102345,99170,99182,99088,185457,538624,86407,86403,163590,207596,207597,199206,209576,209577,508133,204703,202116,197991,161641,214786,156586,208918,34046,198250,197647,214500,215412,171124,203380,43669,43671,170237,214384,214380,213807,146635,207975,186545,559934,559936,215345,214990,215252,214619,213114,213114,213115,213115)THEN  (b.sell_val_nsp)ELSE NULL END) as salespnsp,
      count(distinct CASE WHEN b.art_no in (167979,174407,214154,495638,203803,188061,138277,205809,150916,996346,61582,53447,995796,210187,210188,128538,199298,199299,208896,208898,208900,147656,549789,186665,204661,192544,192541,177291,199441,199439,59551,59552,192623,182502,139433,197314,197315,197321,197320,173805,18947,115184,182009,182012,215372,215371,196043,177636,212083,212086,200391,201270,129909,168622,175898,190361,190362,203718,189444,189445,189446,136626,189372,186463,187651,187652,187649,187650,177088,191756,191755,177089,210660,213832,716185,211108,203731,203732,155822,155823,155824,155825,155826,205725,167348,207195,212660,214295,214301,214302,201411,201413,201415,188544,201578,188543,173998,173999,213720,171653,185613,185614,199013,198857,199760,102345,99170,99182,99088,185457,538624,86407,86403,163590,207596,207597,199206,209576,209577,508133,204703,202116,197991,161641,214786,156586,208918,34046,198250,197647,214500,215412,171124,203380,43669,43671,170237,214384,214380,213807,146635,207975,186545,559934,559936,215345,214990,215252,214619,213114,213114,213115,213115)THEN c.home_store_id||c.cust_no||c.auth_person_id ELSE NULL END) as buyerp,
      sum( CASE WHEN b.art_no not in (167979,174407,214154,495638,203803,188061,138277,205809,150916,996346,61582,53447,995796,210187,210188,128538,199298,199299,208896,208898,208900,147656,549789,186665,204661,192544,192541,177291,199441,199439,59551,59552,192623,182502,139433,197314,197315,197321,197320,173805,18947,115184,182009,182012,215372,215371,196043,177636,212083,212086,200391,201270,129909,168622,175898,190361,190362,203718,189444,189445,189446,136626,189372,186463,187651,187652,187649,187650,177088,191756,191755,177089,210660,213832,716185,211108,203731,203732,155822,155823,155824,155825,155826,205725,167348,207195,212660,214295,214301,214302,201411,201413,201415,188544,201578,188543,173998,173999,213720,171653,185613,185614,199013,198857,199760,102345,99170,99182,99088,185457,538624,86407,86403,163590,207596,207597,199206,209576,209577,508133,204703,202116,197991,161641,214786,156586,208918,34046,198250,197647,214500,215412,171124,203380,43669,43671,170237,214384,214380,213807,146635,207975,186545,559934,559936,215345,214990,215252,214619,213114,213114,213115,213115)THEN b.sell_val_gsp ELSE NULL END) as salesc, 
      sum (CASE WHEN b.art_no not in (167979,174407,214154,495638,203803,188061,138277,205809,150916,996346,61582,53447,995796,210187,210188,128538,199298,199299,208896,208898,208900,147656,549789,186665,204661,192544,192541,177291,199441,199439,59551,59552,192623,182502,139433,197314,197315,197321,197320,173805,18947,115184,182009,182012,215372,215371,196043,177636,212083,212086,200391,201270,129909,168622,175898,190361,190362,203718,189444,189445,189446,136626,189372,186463,187651,187652,187649,187650,177088,191756,191755,177089,210660,213832,716185,211108,203731,203732,155822,155823,155824,155825,155826,205725,167348,207195,212660,214295,214301,214302,201411,201413,201415,188544,201578,188543,173998,173999,213720,171653,185613,185614,199013,198857,199760,102345,99170,99182,99088,185457,538624,86407,86403,163590,207596,207597,199206,209576,209577,508133,204703,202116,197991,161641,214786,156586,208918,34046,198250,197647,214500,215412,171124,203380,43669,43671,170237,214384,214380,213807,146635,207975,186545,559934,559936,215345,214990,215252,214619,213114,213114,213115,213115)THEN (b.sell_val_nsp-b.sell_val_nnbp) ELSE NULL END) as frontmarginc,
      count(distinct  CASE WHEN b.art_no not in (167979,174407,214154,495638,203803,188061,138277,205809,150916,996346,61582,53447,995796,210187,210188,128538,199298,199299,208896,208898,208900,147656,549789,186665,204661,192544,192541,177291,199441,199439,59551,59552,192623,182502,139433,197314,197315,197321,197320,173805,18947,115184,182009,182012,215372,215371,196043,177636,212083,212086,200391,201270,129909,168622,175898,190361,190362,203718,189444,189445,189446,136626,189372,186463,187651,187652,187649,187650,177088,191756,191755,177089,210660,213832,716185,211108,203731,203732,155822,155823,155824,155825,155826,205725,167348,207195,212660,214295,214301,214302,201411,201413,201415,188544,201578,188543,173998,173999,213720,171653,185613,185614,199013,198857,199760,102345,99170,99182,99088,185457,538624,86407,86403,163590,207596,207597,199206,209576,209577,508133,204703,202116,197991,161641,214786,156586,208918,34046,198250,197647,214500,215412,171124,203380,43669,43671,170237,214384,214380,213807,146635,207975,186545,559934,559936,215345,214990,215252,214619,213114,213114,213115,213115)THEN b.invoice_id ELSE NULL END) as invoicec,
      sum (CASE WHEN b.art_no not in (167979,174407,214154,495638,203803,188061,138277,205809,150916,996346,61582,53447,995796,210187,210188,128538,199298,199299,208896,208898,208900,147656,549789,186665,204661,192544,192541,177291,199441,199439,59551,59552,192623,182502,139433,197314,197315,197321,197320,173805,18947,115184,182009,182012,215372,215371,196043,177636,212083,212086,200391,201270,129909,168622,175898,190361,190362,203718,189444,189445,189446,136626,189372,186463,187651,187652,187649,187650,177088,191756,191755,177089,210660,213832,716185,211108,203731,203732,155822,155823,155824,155825,155826,205725,167348,207195,212660,214295,214301,214302,201411,201413,201415,188544,201578,188543,173998,173999,213720,171653,185613,185614,199013,198857,199760,102345,99170,99182,99088,185457,538624,86407,86403,163590,207596,207597,199206,209576,209577,508133,204703,202116,197991,161641,214786,156586,208918,34046,198250,197647,214500,215412,171124,203380,43669,43671,170237,214384,214380,213807,146635,207975,186545,559934,559936,215345,214990,215252,214619,213114,213114,213115,213115)THEN (b.sell_val_nsp) ELSE NULL END) as salescnsp,
      count(distinct CASE WHEN not b.art_no in (167979,174407,214154,495638,203803,188061,138277,205809,150916,996346,61582,53447,995796,210187,210188,128538,199298,199299,208896,208898,208900,147656,549789,186665,204661,192544,192541,177291,199441,199439,59551,59552,192623,182502,139433,197314,197315,197321,197320,173805,18947,115184,182009,182012,215372,215371,196043,177636,212083,212086,200391,201270,129909,168622,175898,190361,190362,203718,189444,189445,189446,136626,189372,186463,187651,187652,187649,187650,177088,191756,191755,177089,210660,213832,716185,211108,203731,203732,155822,155823,155824,155825,155826,205725,167348,207195,212660,214295,214301,214302,201411,201413,201415,188544,201578,188543,173998,173999,213720,171653,185613,185614,199013,198857,199760,102345,99170,99182,99088,185457,538624,86407,86403,163590,207596,207597,199206,209576,209577,508133,204703,202116,197991,161641,214786,156586,208918,34046,198250,197647,214500,215412,171124,203380,43669,43671,170237,214384,214380,213807,146635,207975,186545,559934,559936,215345,214990,215252,214619,213114,213114,213115,213115)THEN c.home_store_id||c.cust_no||c.auth_person_id ELSE NULL END) as buyerc
      from (select distinct invoice_id from chnccp_msi_z.participating_namelist_group) a 
      join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b
      on a.invoice_id = b.invoice_id
      join (select sending, home_store_id, cust_no, auth_person_id from chnccp_msi_z.participating_namelist_group group by sending, home_store_id, cust_no, auth_person_id) c 
      on b.home_store_id = c.home_store_id and b.cust_no = c.cust_no and b.auth_person_id = c.auth_person_id
      and b.wel_ind = 'N' 
      and b.fsd_ind = 'N' 
      and b.deli_ind = 'N' 
      and b.bvs_ind = 'N' 
      and b.pcr_ind = 'N'
      group by c.sending;

--umc and sending

select c.umc, c.sending, sum(CASE WHEN b.art_no in (167979,174407,214154,495638,203803,188061,138277,205809,150916,996346,61582,53447,995796,210187,210188,128538,199298,199299,208896,208898,208900,147656,549789,186665,204661,192544,192541,177291,199441,199439,59551,59552,192623,182502,139433,197314,197315,197321,197320,173805,18947,115184,182009,182012,215372,215371,196043,177636,212083,212086,200391,201270,129909,168622,175898,190361,190362,203718,189444,189445,189446,136626,189372,186463,187651,187652,187649,187650,177088,191756,191755,177089,210660,213832,716185,211108,203731,203732,155822,155823,155824,155825,155826,205725,167348,207195,212660,214295,214301,214302,201411,201413,201415,188544,201578,188543,173998,173999,213720,171653,185613,185614,199013,198857,199760,102345,99170,99182,99088,185457,538624,86407,86403,163590,207596,207597,199206,209576,209577,508133,204703,202116,197991,161641,214786,156586,208918,34046,198250,197647,214500,215412,171124,203380,43669,43671,170237,214384,214380,213807,146635,207975,186545,559934,559936,215345,214990,215252,214619,213114,213114,213115,213115)THEN b.sell_val_gsp ELSE NULL END) as salesp, 
      sum (CASE WHEN b.art_no in (167979,174407,214154,495638,203803,188061,138277,205809,150916,996346,61582,53447,995796,210187,210188,128538,199298,199299,208896,208898,208900,147656,549789,186665,204661,192544,192541,177291,199441,199439,59551,59552,192623,182502,139433,197314,197315,197321,197320,173805,18947,115184,182009,182012,215372,215371,196043,177636,212083,212086,200391,201270,129909,168622,175898,190361,190362,203718,189444,189445,189446,136626,189372,186463,187651,187652,187649,187650,177088,191756,191755,177089,210660,213832,716185,211108,203731,203732,155822,155823,155824,155825,155826,205725,167348,207195,212660,214295,214301,214302,201411,201413,201415,188544,201578,188543,173998,173999,213720,171653,185613,185614,199013,198857,199760,102345,99170,99182,99088,185457,538624,86407,86403,163590,207596,207597,199206,209576,209577,508133,204703,202116,197991,161641,214786,156586,208918,34046,198250,197647,214500,215412,171124,203380,43669,43671,170237,214384,214380,213807,146635,207975,186545,559934,559936,215345,214990,215252,214619,213114,213114,213115,213115)THEN  (b.sell_val_nsp-b.sell_val_nnbp)ELSE NULL END) as frontmarginp,
      count(distinct  CASE WHEN b.art_no in (167979,174407,214154,495638,203803,188061,138277,205809,150916,996346,61582,53447,995796,210187,210188,128538,199298,199299,208896,208898,208900,147656,549789,186665,204661,192544,192541,177291,199441,199439,59551,59552,192623,182502,139433,197314,197315,197321,197320,173805,18947,115184,182009,182012,215372,215371,196043,177636,212083,212086,200391,201270,129909,168622,175898,190361,190362,203718,189444,189445,189446,136626,189372,186463,187651,187652,187649,187650,177088,191756,191755,177089,210660,213832,716185,211108,203731,203732,155822,155823,155824,155825,155826,205725,167348,207195,212660,214295,214301,214302,201411,201413,201415,188544,201578,188543,173998,173999,213720,171653,185613,185614,199013,198857,199760,102345,99170,99182,99088,185457,538624,86407,86403,163590,207596,207597,199206,209576,209577,508133,204703,202116,197991,161641,214786,156586,208918,34046,198250,197647,214500,215412,171124,203380,43669,43671,170237,214384,214380,213807,146635,207975,186545,559934,559936,215345,214990,215252,214619,213114,213114,213115,213115)THEN b.invoice_id ELSE NULL END) as invoicep,
      sum (CASE WHEN b.art_no in (167979,174407,214154,495638,203803,188061,138277,205809,150916,996346,61582,53447,995796,210187,210188,128538,199298,199299,208896,208898,208900,147656,549789,186665,204661,192544,192541,177291,199441,199439,59551,59552,192623,182502,139433,197314,197315,197321,197320,173805,18947,115184,182009,182012,215372,215371,196043,177636,212083,212086,200391,201270,129909,168622,175898,190361,190362,203718,189444,189445,189446,136626,189372,186463,187651,187652,187649,187650,177088,191756,191755,177089,210660,213832,716185,211108,203731,203732,155822,155823,155824,155825,155826,205725,167348,207195,212660,214295,214301,214302,201411,201413,201415,188544,201578,188543,173998,173999,213720,171653,185613,185614,199013,198857,199760,102345,99170,99182,99088,185457,538624,86407,86403,163590,207596,207597,199206,209576,209577,508133,204703,202116,197991,161641,214786,156586,208918,34046,198250,197647,214500,215412,171124,203380,43669,43671,170237,214384,214380,213807,146635,207975,186545,559934,559936,215345,214990,215252,214619,213114,213114,213115,213115)THEN  (b.sell_val_nsp)ELSE NULL END) as salespnsp,
      count(distinct CASE WHEN b.art_no in (167979,174407,214154,495638,203803,188061,138277,205809,150916,996346,61582,53447,995796,210187,210188,128538,199298,199299,208896,208898,208900,147656,549789,186665,204661,192544,192541,177291,199441,199439,59551,59552,192623,182502,139433,197314,197315,197321,197320,173805,18947,115184,182009,182012,215372,215371,196043,177636,212083,212086,200391,201270,129909,168622,175898,190361,190362,203718,189444,189445,189446,136626,189372,186463,187651,187652,187649,187650,177088,191756,191755,177089,210660,213832,716185,211108,203731,203732,155822,155823,155824,155825,155826,205725,167348,207195,212660,214295,214301,214302,201411,201413,201415,188544,201578,188543,173998,173999,213720,171653,185613,185614,199013,198857,199760,102345,99170,99182,99088,185457,538624,86407,86403,163590,207596,207597,199206,209576,209577,508133,204703,202116,197991,161641,214786,156586,208918,34046,198250,197647,214500,215412,171124,203380,43669,43671,170237,214384,214380,213807,146635,207975,186545,559934,559936,215345,214990,215252,214619,213114,213114,213115,213115)THEN c.home_store_id||c.cust_no||c.auth_person_id ELSE NULL END) as buyerp,
      sum( CASE WHEN b.art_no not in (167979,174407,214154,495638,203803,188061,138277,205809,150916,996346,61582,53447,995796,210187,210188,128538,199298,199299,208896,208898,208900,147656,549789,186665,204661,192544,192541,177291,199441,199439,59551,59552,192623,182502,139433,197314,197315,197321,197320,173805,18947,115184,182009,182012,215372,215371,196043,177636,212083,212086,200391,201270,129909,168622,175898,190361,190362,203718,189444,189445,189446,136626,189372,186463,187651,187652,187649,187650,177088,191756,191755,177089,210660,213832,716185,211108,203731,203732,155822,155823,155824,155825,155826,205725,167348,207195,212660,214295,214301,214302,201411,201413,201415,188544,201578,188543,173998,173999,213720,171653,185613,185614,199013,198857,199760,102345,99170,99182,99088,185457,538624,86407,86403,163590,207596,207597,199206,209576,209577,508133,204703,202116,197991,161641,214786,156586,208918,34046,198250,197647,214500,215412,171124,203380,43669,43671,170237,214384,214380,213807,146635,207975,186545,559934,559936,215345,214990,215252,214619,213114,213114,213115,213115)THEN b.sell_val_gsp ELSE NULL END) as salesc, 
      sum (CASE WHEN b.art_no not in (167979,174407,214154,495638,203803,188061,138277,205809,150916,996346,61582,53447,995796,210187,210188,128538,199298,199299,208896,208898,208900,147656,549789,186665,204661,192544,192541,177291,199441,199439,59551,59552,192623,182502,139433,197314,197315,197321,197320,173805,18947,115184,182009,182012,215372,215371,196043,177636,212083,212086,200391,201270,129909,168622,175898,190361,190362,203718,189444,189445,189446,136626,189372,186463,187651,187652,187649,187650,177088,191756,191755,177089,210660,213832,716185,211108,203731,203732,155822,155823,155824,155825,155826,205725,167348,207195,212660,214295,214301,214302,201411,201413,201415,188544,201578,188543,173998,173999,213720,171653,185613,185614,199013,198857,199760,102345,99170,99182,99088,185457,538624,86407,86403,163590,207596,207597,199206,209576,209577,508133,204703,202116,197991,161641,214786,156586,208918,34046,198250,197647,214500,215412,171124,203380,43669,43671,170237,214384,214380,213807,146635,207975,186545,559934,559936,215345,214990,215252,214619,213114,213114,213115,213115)THEN (b.sell_val_nsp-b.sell_val_nnbp) ELSE NULL END) as frontmarginc,
      count(distinct  CASE WHEN b.art_no not in (167979,174407,214154,495638,203803,188061,138277,205809,150916,996346,61582,53447,995796,210187,210188,128538,199298,199299,208896,208898,208900,147656,549789,186665,204661,192544,192541,177291,199441,199439,59551,59552,192623,182502,139433,197314,197315,197321,197320,173805,18947,115184,182009,182012,215372,215371,196043,177636,212083,212086,200391,201270,129909,168622,175898,190361,190362,203718,189444,189445,189446,136626,189372,186463,187651,187652,187649,187650,177088,191756,191755,177089,210660,213832,716185,211108,203731,203732,155822,155823,155824,155825,155826,205725,167348,207195,212660,214295,214301,214302,201411,201413,201415,188544,201578,188543,173998,173999,213720,171653,185613,185614,199013,198857,199760,102345,99170,99182,99088,185457,538624,86407,86403,163590,207596,207597,199206,209576,209577,508133,204703,202116,197991,161641,214786,156586,208918,34046,198250,197647,214500,215412,171124,203380,43669,43671,170237,214384,214380,213807,146635,207975,186545,559934,559936,215345,214990,215252,214619,213114,213114,213115,213115)THEN b.invoice_id ELSE NULL END) as invoicec,
      sum (CASE WHEN b.art_no not in (167979,174407,214154,495638,203803,188061,138277,205809,150916,996346,61582,53447,995796,210187,210188,128538,199298,199299,208896,208898,208900,147656,549789,186665,204661,192544,192541,177291,199441,199439,59551,59552,192623,182502,139433,197314,197315,197321,197320,173805,18947,115184,182009,182012,215372,215371,196043,177636,212083,212086,200391,201270,129909,168622,175898,190361,190362,203718,189444,189445,189446,136626,189372,186463,187651,187652,187649,187650,177088,191756,191755,177089,210660,213832,716185,211108,203731,203732,155822,155823,155824,155825,155826,205725,167348,207195,212660,214295,214301,214302,201411,201413,201415,188544,201578,188543,173998,173999,213720,171653,185613,185614,199013,198857,199760,102345,99170,99182,99088,185457,538624,86407,86403,163590,207596,207597,199206,209576,209577,508133,204703,202116,197991,161641,214786,156586,208918,34046,198250,197647,214500,215412,171124,203380,43669,43671,170237,214384,214380,213807,146635,207975,186545,559934,559936,215345,214990,215252,214619,213114,213114,213115,213115)THEN (b.sell_val_nsp) ELSE NULL END) as salescnsp,
      count(distinct CASE WHEN not b.art_no in (167979,174407,214154,495638,203803,188061,138277,205809,150916,996346,61582,53447,995796,210187,210188,128538,199298,199299,208896,208898,208900,147656,549789,186665,204661,192544,192541,177291,199441,199439,59551,59552,192623,182502,139433,197314,197315,197321,197320,173805,18947,115184,182009,182012,215372,215371,196043,177636,212083,212086,200391,201270,129909,168622,175898,190361,190362,203718,189444,189445,189446,136626,189372,186463,187651,187652,187649,187650,177088,191756,191755,177089,210660,213832,716185,211108,203731,203732,155822,155823,155824,155825,155826,205725,167348,207195,212660,214295,214301,214302,201411,201413,201415,188544,201578,188543,173998,173999,213720,171653,185613,185614,199013,198857,199760,102345,99170,99182,99088,185457,538624,86407,86403,163590,207596,207597,199206,209576,209577,508133,204703,202116,197991,161641,214786,156586,208918,34046,198250,197647,214500,215412,171124,203380,43669,43671,170237,214384,214380,213807,146635,207975,186545,559934,559936,215345,214990,215252,214619,213114,213114,213115,213115)THEN c.home_store_id||c.cust_no||c.auth_person_id ELSE NULL END) as buyerc
      from (select distinct invoice_id from chnccp_msi_z.participating_namelist_group) a 
      join chnccp_fls.view_frank_auth_person_invoice_line_channel_adj b
      on a.invoice_id = b.invoice_id
      join (select sending, umc, home_store_id, cust_no, auth_person_id from chnccp_msi_z.participating_namelist_group group by sending, umc, home_store_id, cust_no, auth_person_id) c 
      on b.home_store_id = c.home_store_id and b.cust_no = c.cust_no and b.auth_person_id = c.auth_person_id
      and b.wel_ind = 'N' 
      and b.fsd_ind = 'N' 
      and b.deli_ind = 'N' 
      and b.bvs_ind = 'N' 
      and b.pcr_ind = 'N'
      group by c.umc, c.sending
      order by c.umc, c.sending;



