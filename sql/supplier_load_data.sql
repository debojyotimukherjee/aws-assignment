/*SQL Query to*/

truncate table schema_name.supplier_stage;

copy schema_name.supplier_stage
from 's3://environment-data-output/data_source_name/output/'
iam_role 'arn:aws:iam::aws_account_id:role/environment-redshift-s3-access-role'
delimiter '|' gzip;


insert into schema_name.supplier_data
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
      from schema_name.supplier_stage
);


