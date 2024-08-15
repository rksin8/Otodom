select * from otodom_data_flatten limit 5;
select * from otodom_data_flatten_address_full limit 5;
select * from otodom_data_flatten_translate limit 5;


-- Extract useful columns from 1st table
select case when price like 'PLN%' then try_to_number(replace(price,'PLN ',''),'999,999,999.99')
           when price like '€%' then try_to_number(replace(price,'€',''),'999,999,999.99') * 4.43
      end as price_new
      , try_to_double(replace(replace(replace(replace(surface,'m²',''),'м²',''),' ',''),',','.'),'9999.99') as surface_new
from otodom_data_flatten;


-- Extract useful column from 2nd table
select 
replace(parse_json(addr.address):suburb,'"', '') as suburb 
 , replace(parse_json(addr.address):city,'"', '') as city
, replace(parse_json(addr.address):country,'"', '') as country

from otodom_data_flatten_address_full addr;

-- Extract useful column from 3rd table
select trans.title_eng as title_eng 
from otodom_data_flatten_translate trans;


-- Now join these extracted tables 
CREATE OR REPLACE TABLE OTODOM_DATA_TRANSFORMED
as
with cte as 
    (select ot.*
    , case when price like 'PLN%' then try_to_number(replace(price,'PLN ',''),'999,999,999.99')
           when price like '€%' then try_to_number(replace(price,'€',''),'999,999,999.99') * 4.43
      end as price_new
    , try_to_double(replace(replace(replace(replace(surface,'m²',''),'м²',''),' ',''),',','.'),'9999.99') as surface_new
    , replace(parse_json(addr.address):suburb,'"', '') as suburb
    , replace(parse_json(addr.address):city,'"', '') as city
    , replace(parse_json(addr.address):country,'"', '') as country
    , trans.title_eng as title_eng
    from otodom_data_flatten ot 
    left join otodom_data_flatten_address_full addr on ot.rn=addr.rn 
    left join otodom_data_flatten_translate trans on ot.rn=trans.rn)
select *
, case when lower(title_eng) like '%commercial%' or lower(title_eng) like '%office%' or lower(title_eng) like '%shop%' then 'non apartment'
       when is_for_sale = 'false' and surface_new <=330 and price_new <=55000 then 'apartment'
       when is_for_sale = 'false' then 'non apartment'
       when is_for_sale = 'true'  and surface_new <=600 and price_new <=20000000 then 'apartment'
       when is_for_sale = 'true'  then 'non apartment'
  end as apartment_flag
from cte;

-- Verify output table
select * from OTODOM_DATA_TRANSFORMED limit 5;