BEGIN transaction;

truncate table :schema_name.supplier_stage;

select * from :schema_name.supplier_data limit 10;

copy :schema_name.supplier_stage
from :emr_file_path credentials
iam_role :iam_role
delimiter '|' gzip;


insert into :schema_name.supplier_data
(
 select
     s_suppkey ,
        s_name ,
        s_address ,
        s_nationkey ,
        s_phone ,
        s_acctbal ,
        s_comment,
        current_timestamp as load_ts
      from :schema_name.supplier_stage
);

END transaction;


