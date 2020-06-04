#!/bin/bash

#######################################Script for bootstrapping the EMR Cluster###########################

if [ $# -ne 1 ]; then
	echo "usage: `basename $0` <environment>" > /dev/stderr
	exit 1
fi

environment=$1

#Install postgres client
sudo yum install -y postgresql

#Install git
sudo yum install -y git

#Download Code Repo
git clone https://github.com/debojyotimukherjee/aws-assignment.git