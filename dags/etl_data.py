""" Extract data from star wars API e send to my local API"""
from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.python_operator import PythonOperator

from etl.load import send_data_to_api, run


DEFAULT_ARGS = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2021, 10, 25, 0, 0, 0),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 3,
    'retry_delay': timedelta(seconds=30),
}


dag = DAG(
    'Star-Wars-API',
    default_args=DEFAULT_ARGS,
    schedule_interval=None,
    catchup=False,
    description='Get Star Wars data and send to a local API'
)

send_data = PythonOperator(
    task_id='send_data_star_wars',
    python_callable=send_data_to_api,
    op_kwargs={
        "url": "https://swapi.dev/api/"
    },
    dag=dag
)

relation = PythonOperator(
    task_id='construct_relation_tables',
    python_callable=run,
    dag=dag
)

send_data >> relation
