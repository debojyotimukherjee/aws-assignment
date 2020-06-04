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

create table if not exists assignment.supplier_data(
        s_suppkey bigint NOT NULL encode MOSTLY32,
        s_name varchar(100) encode LZO,
        s_address varchar(100) encode LZO,
        s_nationkey integer encode MOSTLY8,
        s_phone varchar(40) encode LZO,
        s_acctbal decimal(12,2) encode delta32k,
        s_comment varchar(max) encode LZO,
        load_ts timestamp NOT NULL
     )
        distkey(s_suppkey) compound sortkey(load_ts) ;




