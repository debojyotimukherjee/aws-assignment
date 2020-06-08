/* Following is the DDL for Supplier Table */

create schema if not exists assignment;

create table if not exists assignment.supplier_stage(
        s_suppkey bigint ,
        s_name varchar(100) ,
        s_address varchar(100) ,
        s_nationkey integer ,
        s_phone varchar(40) ,
        s_acctbal decimal(12,2) ,
        s_comment varchar(max)
     )
        distkey(s_suppkey) compound sortkey(s_suppkey) ;

create table if not exists assignment.supplier_dim(
        s_suppkey bigint NOT NULL ,
        s_name varchar(100) ,
        s_address varchar(100) ,
        s_nationkey integer,
        s_phone varchar(40) ,
        eff_start_date date,
        eff_end_date date,
        active_flag char(1)

     )
        distkey(s_suppkey) compound sortkey(active_flag) ;

create table if not exists assignment.supplier_fact(
        s_suppkey bigint ,
        s_acctbal decimal(12,2) ,
        s_comment varchar(max) ,
        load_ts
     )
        distkey(s_suppkey) compound sortkey(load_ts) ;




