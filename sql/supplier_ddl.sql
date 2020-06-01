/* Following is the DDL for Supplier Table */

create schema if not exists assignment;

create table if not exists assignment.supplier_stage(
        s_suppkey bigint encode MOSTLY32,
        s_name varchar(100) encode LZO,
        s_address varchar(100) encode LZO,
        s_nationkey integer encode MOSTLY8,
        s_phone varchar(40) encode LZO,
        s_acctbal decimal(12,2) encode delta32k,
        s_comment varchar(max) encode LZO
     )
        distkey(s_suppkey) compound sortkey(s_suppkey) ;

create table if not exists assignment.supplier_dim(
        s_suppkey bigint encode MOSTLY32,
        s_name varchar(100) encode LZO,
        s_address varchar(100) encode LZO,
        s_nationkey integer encode MOSTLY8,
        s_phone varchar(40) encode LZO,
  		eff_start_date date,
  		eff_end_date date,
  		dw_active_flag char(1)
     )
        distkey(s_suppkey) compound sortkey(s_suppkey, dw_active_flag) ;




