#!/bin/bash

########################## Generic Script for triggering the Redshift on EMR Cluster########################

if [ $# -ne 1 ]; then
	echo "usage: `basename $0` data_source_name" > /dev/stderr
	exit 1
fi

data_source_name=${1}
rs_hostname="aws-assignment-awsassignmentredshiftcluster-d8z2i899ckcw.cnowfxl3k0d2.us-east-1.redshift.amazonaws.com"
rs_user="etl_user"
rs_schema_name="assignment"
rs_database_name="aws-assignment"
secret_id_string="aws-assignment-rs-etl-password"
rs_password=`aws secretsmanager get-secret-value --secret-id ${secret_id_string} | jq '.SecretString' | sed 's|\\"||g
' | awk -F":" '{print $2}' | sed 's|}"||g' | sed 's/^ *//g'`

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

PGPASSWORD=${rs_password} psql -h ${rs_hostname} -d ${rs_database_name} -U ${rs_user} -p 5439 -v schema_name=${rs_schema_name} -f ${home_path}/sql/supplier_load_data.sql