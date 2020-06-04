#!/bin/bash

########################## Generic Script for triggering the Redshift on EMR Cluster########################

if [ $# -ne 1 ]; then
	echo "usage: `basename $0` data_source_name" > /dev/stderr
	exit 1
fi

home_path=/home/hadoop/aws-assignment/emr_scripts

#Step - 1 - Trigger Spark Script to load the files to HDFS

spark-submit --master yarn --driver-memory 2g --num-executors 2 --executor-memory 1g --executor-cores 2 ${home_path}/spark/awsassignment_emr_spark_prepare_file.py -f ${home_path}/config/supplier.config -s ${home_path}/supplier -e aws-assignment


#Step - 2 Trigger PSQL Script

