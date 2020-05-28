import boto3
import sys
from awsglue.context import GlueContext
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext






default_args = getResolvedOptions(sys.argv, ['AWS_REGION', 'DATA_SOURCE_BUCKET_NAME',
                                             'DATA_OUTPUT_BUCKET_NAME', 'ENVIRONMENT'])
environment = default_args['ENVIRONMENT']

new_bucket_name = f'{environment}-data-output'
bucket_to_copy = f'{environment}-data-source'
