#!/bin/bash

#
# Infrastructure setup test/development driver script
# Make sure there are no special chars (spaces, hyphens, etc..) in the environment name
#

if [ $# -ne 2 ]; then
	echo "usage: `basename $0` <environment> <skip_credentials(y/n)" > /dev/stderr
	exit 1
fi

if [ ${2} == 'n' ]
then
  echo "Enter the root User Id for Redshift: "
  read REDSHIFT_ROOT_USER

  echo "Enter the root User Id's password for Redshift: "
  read -s REDSHIFT_ROOT_PASSWORD

  echo "Enter the ETL User Id for Redshift: "
  read REDSHIFT_ETL_USER

  echo "Enter the ETL User Id's password for Redshift: "
  read -s REDSHIFT_ETL_PASSWORD
fi



ENVIRONMENT="${1}"
echo ENVIRONMENT = ${ENVIRONMENT}

CF_FILENAME="cloudformation/aws_assignment_create_stack.yaml"
CF_TEMP_FILENAME="aws_assignment_create_stack_temp.yaml"
CF_OUT_FILENAME="aws_assignment_create_stack_out.yaml"
CF_STACK_NAME="${ENVIRONMENT}"
FUNCTIONS_BUCKET_NAME="${ENVIRONMENT}-functions"

TIMESTAMP=$(date +%Y%m%d%H%M%S)
sed -e "s/DeploymentTimestamp/${TIMESTAMP}/g" ${CF_FILENAME} > ${CF_TEMP_FILENAME}

aws s3 mb s3://${FUNCTIONS_BUCKET_NAME}/

aws s3api put-bucket-encryption \
	--bucket ${FUNCTIONS_BUCKET_NAME} \
	--server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'

aws s3api put-public-access-block \
    --bucket ${FUNCTIONS_BUCKET_NAME} \
    --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

aws s3api put-bucket-tagging \
	--bucket ${FUNCTIONS_BUCKET_NAME} \
	--tagging "TagSet=[{Key=environment,Value=${ENVIRONMENT}}]"

aws s3 cp glue_etl/ s3://${FUNCTIONS_BUCKET_NAME}/glue_etl/ --recursive
aws s3 cp sql/ s3://${FUNCTIONS_BUCKET_NAME}/sql/ --recursive

aws cloudformation package \
	--template-file ${CF_TEMP_FILENAME} \
	--output-template-file ${CF_OUT_FILENAME} \
	--s3-bucket ${FUNCTIONS_BUCKET_NAME}

aws cloudformation deploy \
	--template-file ${CF_OUT_FILENAME} \
	--stack-name ${CF_STACK_NAME} \
  --s3-bucket ${FUNCTIONS_BUCKET_NAME} \
  --parameter-overrides "environment=${ENVIRONMENT}" "s3FunctionsBucket=${FUNCTIONS_BUCKET_NAME}" \
  "redshiftRootUser=${REDSHIFT_ROOT_USER}" "redshiftRootPassword=${REDSHIFT_ROOT_PASSWORD}" \
  "redshiftETLUser=${REDSHIFT_ETL_USER}" "redshiftETLPassword=${REDSHIFT_ETL_PASSWORD}" \
  --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND

rm -f ${CF_TEMP_FILENAME}
rm -f ${CF_OUT_FILENAME}

exit 0
