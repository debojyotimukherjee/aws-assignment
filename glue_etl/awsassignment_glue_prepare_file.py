import sys
from awsglue.context import GlueContext
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from datetime import datetime


def get_secret():

    secret_name = "aws-assignment-rs-etl-password"
    region_name = "us-east-1"

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    # In this sample we only handle the specific exceptions for the 'GetSecretValue' API.
    # See https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
    # We rethrow the exception by default.

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        if e.response['Error']['Code'] == 'DecryptionFailureException':
            # Secrets Manager can't decrypt the protected secret text using the provided KMS key.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response['Error']['Code'] == 'InternalServiceErrorException':
            # An error occurred on the server side.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response['Error']['Code'] == 'InvalidParameterException':
            # You provided an invalid value for a parameter.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response['Error']['Code'] == 'InvalidRequestException':
            # You provided a parameter value that is not valid for the current state of the resource.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response['Error']['Code'] == 'ResourceNotFoundException':
            # We can't find the resource that you asked for.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
    else:
        # Decrypts secret using the associated KMS CMK.
        # Depending on whether the secret is a string or binary, one of these fields will be populated.
        if 'SecretString' in get_secret_value_response:
            secret = get_secret_value_response['SecretString']
        else:
            decoded_binary_secret = base64.b64decode(get_secret_value_response['SecretBinary'])

def get_read_file_df(spark, file_path, file_type, file_header="true", file_delimiter=None, null_value=''):
    try:
        if file_type == "delimited":
            if file_delimiter:
                return spark.read.option("nullValue", null_value).load(file_path + "/*", format="csv",
                                                                       sep=file_delimiter, inferSchema="true",
                                                                       header=file_header)
            else:
                sys.exit("Missing delimiter for delimited file : ")

        elif file_type == "parquet":
            return spark.read.parquet(file_path + "/*")

        elif file_type == "orc":
            return spark.read.orc(file_path + "/*")

        else:
            sys.exit("Incorrect file type defined")

    except Exception as e:
        print(f'Unhandled exception: {str(e)}')
        sys.exit()


def write_file(file_path, read_file_df, output_file_partitions, output_file_delimiter):
    try:
        read_file_df.repartition(output_file_partitions).write. \
            mode('overwrite').csv(file_path, sep=output_file_delimiter,
                                  header="false", compression="gzip")
    except Exception as e:
        print(f'Unhandled exception: {str(e)}')
        sys.exit()


if __name__ == '__main__':
    try:
        default_args = getResolvedOptions(sys.argv, ['AWS_REGION', 'DATA_SOURCE_BUCKET_NAME',
                                                     'DATA_OUTPUT_BUCKET_NAME', 'ENVIRONMENT',
                                                     'DATA_SOURCE_NAME', 'SOURCE_FILE_TYPE',
                                                     'FILE_HEADER', 'FILE_DELIMITER',
                                                     'FILE_NULL_VALUE', 'OUTPUT_FILE_PARTITIONS',
                                                     'OUTPUT_FILE_DELIMITER'])

        aws_region = default_args['AWS_REGION']
        environment = default_args['ENVIRONMENT']
        target_bucket = f'{environment}-data-output'
        source_bucket = f'{environment}-data-source'
        data_source_name = default_args['DATA_SOURCE_NAME']
        source_file_type = default_args['SOURCE_FILE_TYPE']
        file_header = default_args['FILE_HEADER']
        file_delimiter = default_args['FILE_DELIMITER']
        null_value = default_args['FILE_NULL_VALUE']
        output_file_partitions = int(default_args['OUTPUT_FILE_PARTITIONS'])
        output_file_delimiter = default_args['OUTPUT_FILE_DELIMITER']

        source_folder_date = datetime.now().strftime("%Y%m%d")

        source_path = f's3://{source_bucket}/{data_source_name}/{source_folder_date}'
        target_path = f's3://{target_bucket}/{data_source_name}/output'

        glue_context = GlueContext(SparkContext.getOrCreate())
        spark_session = glue_context.spark_session

        read_file_df = get_read_file_df(spark_session, source_path, source_file_type)

        # Write Dataframe to S3:
        write_file(target_path, read_file_df, output_file_partitions, output_file_delimiter)

    except Exception as e:
        print(f'Unhandled exception: {str(e)}')
        sys.exit()
