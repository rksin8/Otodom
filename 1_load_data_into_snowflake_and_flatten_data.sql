-- Check data in the stage
select * from @otodom_stage limit 5;

-- Total number of records 62816
select count(*) from @otodom_stage;

-- Create a new table to load data from the stage
create table otodom_data_dump
(
 json_data variant
);

-- blank table
select * from otodom_data_dump;

-- Load data from stage to table
copy into otodom_data_dump
from @otodom_stage on_error = 'skip_file';

-- Check table format
select * from otodom_data_dump limit 5;

-- Verify the number of records
select count(*) from otodom_data_dump;

-- Extract the price column 
select json_data:price from otodom_data_dump limit 5;

-- Strip "" from the price
select replace(json_data:price,'"')from otodom_data_dump limit 5;


-- Currently, the table has only one column; Create a new table and flatten the data into it.


CREATE OR REPLACE table otodom_data_flatten
as
select row_number() over(order by title) as rn  -- add new index column as row_number
, x.*
from (
select replace(json_data:advertiser_type,'"')::string as advertiser_type
, replace(json_data:balcony_garden_terrace,'"')::string as balcony_garden_terrace
, regexp_replace(replace(json_data:description,'"'), '<[^>]+>')::string as description
, replace(json_data:heating,'"')::string as heating
, replace(json_data:is_for_sale,'"')::string as is_for_sale
, replace(json_data:lighting,'"')::string as lighting
, replace(json_data:location,'"')::string as location
, replace(json_data:price,'"')::string as price
, replace(json_data:remote_support,'"')::string as remote_support
, replace(json_data:rent_sale,'"')::string as rent_sale
, replace(json_data:surface,'"')::string as surface
, replace(json_data:timestamp,'"')::date as timestamp
, replace(json_data:title,'"')::string as title
, replace(json_data:url,'"')::string as url
, replace(json_data:form_of_property,'"')::string as form_of_property
, replace(json_data:no_of_rooms,'"')::string as no_of_rooms
, replace(json_data:parking_space,'"')::string as parking_space
from otodom_data_dump) x;


-- Check flattened data format
select * from otodom_data_flatten limit 10;

-- The table looks good, but the ad title and description are in Polish. In the next step, we will convert it into English.
-- Also, we need the city name from the location. This we will also do in the next step
