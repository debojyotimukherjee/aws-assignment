import boto3
import sys
from awsglue.utils import getResolvedOptions

print("Helloe World")

# default_args = getResolvedOptions(sys.argv, ['AWS_REGION', 'DATA_SOURCE_BUCKET_NAME',
#                                              'DATA_OUTPUT_BUCKET_NAME', 'ENVIRONMENT'])
# environment = default_args['ENVIRONMENT']
#
# new_bucket_name = f'{environment}-data-output'
# bucket_to_copy = f'{environment}-data-source'
#
# print(new_bucket_name)
# print(bucket_to_copy)


# s3_resource = boto3.resource('s3')
#
# for key in s3_resource.list_objects(Bucket=bucket_to_copy)['Contents']:
#     files = key['Key']
#     copy_source = {'Bucket': "bucket_to_copy", 'Key': files}
#     s3_resource.meta.client.copy(copy_source, new_bucket_name, files)
#     print(files)
