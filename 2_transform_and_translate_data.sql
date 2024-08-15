
truncate table otodom_data_flatten_address;


select * from otodom_data_flatten_address limit 5;

select count(*) from otodom_data_flatten_address;


create table otodom_data_flatten_address_full
(
rn int,
location text,
address text
)

-- create stage <- file format 
-- 1. create file format, then stage
create or replace file format csv_format
type = csv
field_delimiter=','
field_optionally_enclosed_by='"';

-- 2. create stage now
create or replace stage my_csv_stage 
file_format = csv_format;


-- 3. Move data from local computer to stage -- do graphically or use put command from snowsql
-- done through GUI
-- Check data in the CSV stage
select * from @my_csv_stage limit 5;


-- Copy address data from CSV stage to the table
copy into otodom_data_flatten_address_full
from @my_csv_stage;

-- verify data
select * from otodom_data_flatten_address_full limit 5;


-- Translate Polish to English

-- Connect Google sheet to Python
create or replace stage my_csv_stage2 
file_format = csv_format;




-- Create a table for address data
create table otodom_data_flatten_translate
(
rn int,
title text,
title_eng text
)

-- Copy address data from CSV stage to the table
copy into otodom_data_flatten_translate
from @my_csv_stage2;

-- verify
select * from otodom_data_flatten_translate limit 10;


