#
# Infrastructure setup test/development driver script
# Make sure there are no special chars (spaces, hyphens, etc..) in the environment name
#

if [ $# -ne 2 ]; then
	echo "usage: `basename $0` <environment> <redshift_root_password>" > /dev/stderr
	exit 1
fi

readonly ENVIRONMENT="${1}"
echo ENVIRONMENT = ${ENVIRONMENT}

readonly REDSHIFT_PASSWORD="${2}"
echo REDSHIFT_PASSWORD="${REDSHIFT_PASSWORD}"

readonly CF_FILENAME="cloudformation/aws_assignment_approach_1_create_stack.yaml"
readonly CF_TEMP_FILENAME="aws_assignment_approach_1_create_stack_temp.yaml"
readonly CF_OUT_FILENAME="aws_assignment_approach_1_create_stack_out.yaml"
readonly CF_STACK_NAME="${ENVIRONMENT}"
readonly FUNCTIONS_BUCKET_NAME="${ENVIRONMENT}-functions"

readonly TIMESTAMP=$(date +%Y%m%d%H%M%S)
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

aws s3 cp glue_etl/awsassignment_glue_etl_load.py s3://${FUNCTIONS_BUCKET_NAME}/glue_etl/

aws cloudformation package \
	--template-file ${CF_TEMP_FILENAME} \
	--output-template-file ${CF_OUT_FILENAME} \
	--s3-bucket ${FUNCTIONS_BUCKET_NAME}

aws cloudformation deploy \
	--template-file ${CF_OUT_FILENAME} \
	--stack-name ${CF_STACK_NAME} \
  --s3-bucket ${FUNCTIONS_BUCKET_NAME} \
  --parameter-overrides "environment=${ENVIRONMENT}" "s3FunctionsBucket=${FUNCTIONS_BUCKET_NAME}" "redshiftPassword=${REDSHIFT_PASSWORD}" \
  --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND

rm -f ${CF_TEMP_FILENAME}
rm -f ${CF_OUT_FILENAME}

exit 0
