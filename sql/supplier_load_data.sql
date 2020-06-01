truncate table schema_name.supplier_stage;

copy schema_name.supplier_stage
from 's3://environment-data-output/data_source_name/output/'
iam_role 'arn:aws:iam::aws_account_id:role/environment-redshift-s3-access-role'
delimiter '|' gzip;

delete from schema_name.supplier_dim
where s_suppkey in
(
   select
          src.s_suppkey
          from schema_name.supplier_stage src join schema_name.supplier_dim tgt
          on src.s_suppkey = tgt.s_suppkey and tgt.dw_active_flag = 'Y'
          where
          src.s_name <> tgt.s_name or
          src.s_address <> tgt.s_address or
          src.s_address <> tgt.s_address or
          src.s_phone <> tgt.s_phone
) and dw_active_flag = 'Y';

insert into schema_name.supplier_dim
(
 select
    src.s_suppkey,
    src.s_name,
    src.s_address,
    src.s_nationkey,
    src.s_phone,
    current_date eff_start_date,
    '9999-12-31' eff_end_date,
    case when
       tgt.s_suppkey is NULL or
       (
         src.s_name <> tgt.s_name or
         src.s_address <> tgt.s_address or
         src.s_address <> tgt.s_address or
         src.s_phone <> tgt.s_phone
       ) then 'Y' else 'N' end dw_active_flag
    from schema_name.supplier_stage src left join schema_name.supplier_dim tgt
    on src.s_suppkey = tgt.s_suppkey and tgt.dw_active_flag = 'Y'
);


