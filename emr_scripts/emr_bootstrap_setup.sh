#!/bin/bash

#######################################Script for bootstrapping the EMR Cluster###########################

if [ $# -ne 2 ]; then
	echo "usage: `basename $0` <environment>" > /dev/stderr
	exit 1
fi

environment=$1

#Creating directories in EMR in startup
mkdir -p aws_assignment/shell_script
mkdir -p aws_assignment/spark_script
mkdir -p aws_assignment/sql_script

#Copying Scripts from S3
aws s3 cp s3://${environment}-emr_scripts/shell_script aws_assignment/shell_script/ --recursive
aws s3 cp s3://${environment}-emr_scripts/spark_script aws_assignment/shell_script/ --recursive
aws s3 cp s3://${environment}-emr_scripts/sql_script aws_assignment/shell_script/ --recursive

#Install
sudo yum install -y postgresql
