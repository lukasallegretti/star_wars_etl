""" receive data via api and insert it into the db and bucket """
from typing import Dict
import re
from tempfile import NamedTemporaryFile
import logging
import os

import pandas as pd
import boto3

from dao.connection.pg_conn import DbConn


# logger setup
LOGGER = logging.getLogger(__name__)

# necessary topics
VALIDATE_KEY = [
    'vehicles',
    'people',
    'species',
    'starships',
    'planets',
    'films',
    'residents',
    'homeworld',
    'characters'    
]

def load_data(data: Dict, table: str) -> None:
    """ Load data on database

    Args:
        data (Dict): Data to be insert
        table (str): Table name to insert data
    """
    db_conn = DbConn()

    if table == 'starships':
        data = {
            "mglt" if old == 'MGLT' else old:new for old,new in data.items()
            }
        LOGGER.info('Fix MGLT problem')

    data = transform_url(data)
    try:

        if table in ['species', 'people']:

            try:
                data['homeworld'] = int(
                    data['homeworld'][0] + data['homeworld'][1]
                )

            except IndexError:
                data['homeworld'] = int(
                    data['homeworld'][0]
                )

    except TypeError:
        pass

    columns = list(data.keys())
    values = list(data.values())

    LOGGER.info('Starting execute query')
    db_conn.execute_query(table, columns, values)


def transform_url(data: Dict) -> Dict:
    """ Take only the id number from url

    Args:
        data (Dict): Data to be modify

    Returns:
        Dict: Return data with modifications
    """
    for key in list(data.keys()):

        if key in VALIDATE_KEY:
            
            try:
                values = data.get(key)
                values = ",".join(values)
                ids = re.findall(r'\b\d+\b', values)
                new_values = {key: list(ids)}
                data.update(new_values)

            except TypeError:
                pass

    return data


def upload_s3_file(table: str):
    """ Upload parquet file on s3

    Args:
        table (str): table that will be uploaded
    """
    s3_client = boto3.client(
        's3',
        aws_access_key_id="",
	    aws_secret_access_key="+99n6iDXwCoaY"
    )
    pg_conn = DbConn()
    LOGGER.info('Geting data from database')
    data = pg_conn.select(table)
    
    data = pd.DataFrame(data)
    data.columns = data.columns.astype(str)
    with NamedTemporaryFile('w') as tmp:
        data.to_parquet(tmp.name)
        s3_client.upload_file(
            tmp.name,
            'star-wars-data',
            f'data/{table}.pq'
        )
