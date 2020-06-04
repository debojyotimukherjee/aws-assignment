#!/bin/bash

########################## Generic Script for triggering the Redshift on EMR Cluster########################

if [ $# -ne 1 ]; then
	echo "usage: `basename $0` data_source_name" > /dev/stderr
	exit 1
fi

data_source_name=${1}

home_path=/home/hadoop/aws-assignment/emr_scripts
log_dir=/home/hadoop/logs
log_file_name="${data_source_name}_load_`date +"%Y%m%d%H%M%S"`.log"

#Step - 1 - Trigger Spark Script to load the files to HDFS
echo "Starting Spark Job to create the source files for Redshift Copy at - `date +"%Y%m%d%H%M%S"`" > ${log_dir}/"${log_file_name}"
spark-submit --master yarn --driver-memory 2g --num-executors 2 --executor-memory 1g --executor-cores 2 ${home_path}/spark/awsassignment_emr_spark_prepare_file.py -f ${home_path}/config/supplier.config -s "${data_source_name}" -e "aws-assignment" >> ${log_dir}/${log_file_name}
echo "Finished Spark Job to create the source files for Redshift Copy at - `date +"%Y%m%d%H%M%S"`" >> ${log_dir}/"${log_file_name}"
###########################################################

#Step - 2 Trigger PSQL Script
echo "Starting PSQL Script to load the data into Redshift at - `date +"%Y%m%d%H%M%S"`" >> ${log_dir}/"${log_file_name}"
