import sys
from pyspark.sql import SparkSession
from datetime import datetime
import configparser
import getopt


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
        # default_args = getResolvedOptions(sys.argv, ['AWS_REGION', 'DATA_SOURCE_BUCKET_NAME',
        #                                              'DATA_OUTPUT_BUCKET_NAME', 'ENVIRONMENT',
        #                                              'DATA_SOURCE_NAME', 'SOURCE_FILE_TYPE',
        #                                              'FILE_HEADER', 'FILE_DELIMITER',
        #                                              'FILE_NULL_VALUE', 'OUTPUT_FILE_PARTITIONS',
        #                                              'OUTPUT_FILE_DELIMITER'])
        #
        # environment = default_args['ENVIRONMENT']
        # target_bucket = f'{environment}-data-output'
        # source_bucket = f'{environment}-data-source'
        # data_source_name = default_args['DATA_SOURCE_NAME']
        # source_file_type = default_args['SOURCE_FILE_TYPE']
        # file_header = default_args['FILE_HEADER']
        # file_delimiter = default_args['FILE_DELIMITER']
        # null_value = default_args['FILE_NULL_VALUE']
        # output_file_partitions = int(default_args['OUTPUT_FILE_PARTITIONS'])
        # output_file_delimiter = default_args['OUTPUT_FILE_DELIMITER']

        config_file = None
        data_source_name = None

        try:
            opts, args = getopt.getopt(sys.argv[1:], "f:s:e:")
        except Exception as e:
            print("Invalid Arguments - {e}".format(e=e))
            sys.exit()

        for opt, arg in opts:
            if opt == "-f":
                config_file = arg
            elif opt == "-s":
                data_source_name = arg
            elif opt == "-e":
                environment = arg

        if config_file is None or config_file == '':
            print("Config File not provided with argument -f")
            sys.exit()
        elif data_source_name is None or data_source_name == '':
            print("Data Source name not provided with argument -s")
            sys.exit()
        elif environment is None or environment == '':
            print("Environment name not provided with argument -e")
            sys.exit()

        target_bucket = f'{environment}-data-output'
        source_bucket = f'{environment}-data-source'

        config = configparser.ConfigParser()
        config.read(config_file)

        source_file_type = config[f'{data_source_name}_config']['source_file_type']
        file_header = config[f'{data_source_name}_config']['file_header']
        file_delimiter = config[f'{data_source_name}_config']['file_delimiter']
        null_value = config[f'{data_source_name}_config']['null_value']
        output_file_partitions = int(config[f'{data_source_name}_config']['output_file_partitions'])
        output_file_delimiter = config[f'{data_source_name}_config']['output_file_delimiter']

        source_folder_date = datetime.now().strftime("%Y%m%d")

        source_path = f's3://{source_bucket}/{data_source_name}/{source_folder_date}'
        target_path = f'hdfs:///output_store/{data_source_name}/{source_folder_date}'

        spark_session = SparkSession.builder.appName(f'{data_source_name}-prepare-file').getOrCreate()

        read_file_df = get_read_file_df(spark_session, source_path, source_file_type)

        # Write Dataframe to S3:
        write_file(target_path, read_file_df, output_file_partitions, output_file_delimiter)

    except Exception as e:
        print(f'Unhandled exception: {str(e)}')
        sys.exit()
