BEGIN transaction;

truncate table :schema_name.supplier_stage;

--copy :schema_name.supplier_stage
--from 'emr://j-35YPEDUMMF9AO/output_store/supplier/20200608/'
--credentials iam_role 'arn:aws:iam::048532184061:role/aws-assignment-redshift-s3-access-role'
--delimiter '|' gzip;

--copy assignment.supplier_stage
--from 'emr://j-35YPEDUMMF9AO/output_store/supplier/20200608/*' credentials iam_role 'arn:aws:iam::048532184061:role/aws-assignment-redshift-s3-access-role' delimiter '|' gzip;

copy schema_name.supplier_stage
from 'emr://j-35YPEDUMMF9AO/output_store/supplier/20200608/*'
iam_role 'arn:aws:iam::aws_account_id:role/environment-redshift-s3-access-role'
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


