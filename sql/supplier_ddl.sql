/* Following is the DDL for Supplier Table */

create schema if not exists assignment;

create table if not exists assignment.supplier_stage(
        s_suppkey bigint encode MOSTLY32,
        s_name varchar(100) encode zstd,
        s_address varchar(100) encode zstd,
        s_nationkey integer encode az64,
        s_phone varchar(40) encode zstd,
        s_acctbal decimal(12,2) encode az64,
        s_comment varchar(max) encode zstd
     )
        distkey(s_suppkey);

create table if not exists assignment.supplier_data(
        s_suppkey bigint NOT NULL encode MOSTLY32,
        s_name varchar(100) encode zstd,
        s_address varchar(100) encode zstd,
        s_nationkey integer encode az64,
        s_phone varchar(40) encode zstd,
        s_acctbal decimal(12,2) encode az64,
        s_comment varchar(max) encode zstd,
        load_ts timestamp NOT NULL encode AZ64
     )
        distkey(s_suppkey) compound sortkey(load_ts) ;




