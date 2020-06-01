import boto3
import sys
from awsglue.utils import getResolvedOptions
from pgdb import connect


def get_aws_account():
    return boto3.client('sts').get_caller_identity()['Account']


def get_sql_body(environment, data_source_name, rs_schema, aws_account_id):
    s3 = boto3.resource('s3')
    sql_file_obj = s3.Object(f'{environment}-functions', f'sql/{data_source_name}_load_data.sql')
    sql_body = sql_file_obj.get()['Body'].read()

    return sql_body.decode('utf-8').replace("schema_name", rs_schema).\
        replace("aws_account_id", aws_account_id).replace("environment", environment).\
        replace("data_source_name", data_source_name)


def execute_query(sql_query_body):
    con = connect(host=rs_host + ':' + rs_port, database=environment, user=rs_etl_user, password=rs_etl_password)
    cursor = con.cursor()
    cursor.execute(sql_query_body)
    con.commit()
    cursor.close()
    con.close()


if __name__ == '__main__':
    try:
        default_args = getResolvedOptions(sys.argv, ['AWS_REGION', 'ENVIRONMENT',
                                                     'DATA_SOURCE_NAME', 'RS_HOST',
                                                     'RS_PORT', 'RS_ETL_USER',
                                                     'RS_ETL_PASSWORD', 'RS_SCHEMA'])

        environment = default_args['ENVIRONMENT']
        data_source_name = default_args['DATA_SOURCE_NAME']
        rs_host = default_args['RS_HOST']
        rs_port = default_args['RS_PORT']
        rs_etl_user = default_args['RS_ETL_USER']
        rs_etl_password = default_args['RS_ETL_PASSWORD']
        rs_schema = default_args['RS_SCHEMA']

        aws_account_id = get_aws_account()

        sql_query_body = get_sql_body(environment, data_source_name, rs_schema, aws_account_id)

        execute_query(sql_query_body)

    except Exception as e:
        print(f'Unhandled exception: {str(e)}')
        sys.exit()
