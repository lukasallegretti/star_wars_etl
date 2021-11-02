""" This script will extract our necessary data"""
import requests
from typing import Dict, List
import logging
from json import loads

from etl.connection.pg_conn import DbConn


LOGGER = logging.getLogger('airflow.task')
DB_TABLES = [
    'people',
    'films',
    'vehicles',
    'species',
    'starships',
    'planets'
]
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

def extract_sw_data(url: str) -> Dict:
    """Made a request to Star Wars API
    Args:
        url (str): URL to be request

    Returns:
        Dict: The responde of Star Wars API
    """
    try:
        response = requests.get(url)
        LOGGER.info('Request completed. Status code: %s', response.status_code)

        return loads(response.text)

    except ConnectionError as e:
        LOGGER.error("It's not possible to make a request. Error: %s", e)


def extract_db_data(table: str) -> List[Dict]:
    """ Will extract data from database

    Args:
        table (str): table to be extracted

    Returns:
        List[Dict]: A list of values from table
    """
    conn = DbConn()
    all_data = conn.select(table)

    return all_data
