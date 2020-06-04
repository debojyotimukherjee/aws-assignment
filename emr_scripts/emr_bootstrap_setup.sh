#!/bin/bash

#######################################Script for bootstrapping the EMR Cluster###########################

if [ $# -ne 2 ]; then
	echo "usage: `basename $0` <environment>" > /dev/stderr
	exit 1
fi

environment=$1

#Copying Scripts from S3
aws s3 cp s3://${environment}-emr_scripts/shell_script aws_assignment/shell_script/ --recursive
aws s3 cp s3://${environment}-emr_scripts/spark_script aws_assignment/shell_script/ --recursive
aws s3 cp s3://${environment}-emr_scripts/sql_script aws_assignment/shell_script/ --recursive

#Install postgres client
sudo yum install -y postgresql

#Install git
sudo yum install -y git

#Download Code Repo
git clone https://github.com/debojyotimukherjee/aws-assignment.git