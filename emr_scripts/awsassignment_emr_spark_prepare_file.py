import sys
from pyspark.sql import SparkSession
from datetime import datetime


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

        spark_session = SparkSession.appName(f'{data_source_name}-prepare-file').getOrCreate()

        read_file_df = get_read_file_df(spark_session, source_path, source_file_type)

        # Write Dataframe to S3:
        write_file(target_path, read_file_df, output_file_partitions, output_file_delimiter)

    except Exception as e:
        print(f'Unhandled exception: {str(e)}')
        sys.exit()
