""" This script will load data on database and bucket """
import logging
import requests
from math import ceil
from typing import Dict, List, Tuple

from psycopg2.errors import ForeignKeyViolation

from etl.connection.pg_conn import DbConn
from etl.extract import extract_sw_data, extract_db_data


LOGGER = logging.getLogger('airflow.task')
PEOPLE_RELATION = [
    ('planets', 'homeworld'),
    ('films', 'films'),
    ('species', 'species'),
    ('vehicles', 'vehicles'),
    ('starships', 'starships')
]
FILMS_RELATION = [
    ('planets', 'planets'),
    ('species', 'species'),
    ('vehicles', 'vehicles'),
    ('starships', 'starships')
]


def send_data_to_api(url: str):
    """Send data to a local api

    Args:
        table (str): Table name to be insert on API
        url (str): URL to be request
    """
    api_info = extract_sw_data(url)
    table_names = list(api_info.keys())
    LOGGER.info('Tables to be extract are: %s', table_names)

    for table in table_names:
        number_of_pages = ceil(
            (extract_sw_data(url + table).get('count') / 10)
        )
        LOGGER.info(f'{number_of_pages} numbers of pages for table {table}')

        for page in range(1,number_of_pages + 1):
            data = extract_sw_data(url + f'{table}/?page={page}')
            r = requests.post(
                f"http://lukas_api-star-wars_1:5000/star-wars/{table}",
                json=data
            )
            LOGGER.info('%s OK. Request was successfully', r.status_code)


def run():
    """ Send data to database """
    send_data_to_db('people')
    send_data_to_db('films')


def send_data_to_db(table: str):
    """ Make the logical to insert data on db

    Args:
        table (str): Table will be inserted
        relation (List[Tuple]): Relation between table and attribute
    """
    LOGGER.info('Extracting data')
    data = extract_db_data(table)

    for result in data:
        if table == 'people':
            relation = PEOPLE_RELATION
        else:
            relation = FILMS_RELATION
            
        for tuple_item in relation:
            sec_table, relation = tuple_item
            LOGGER.info('Loading data on relation tables')
            load_relation_data(table, sec_table, relation, dict(result))


def load_relation_data(main_table: str, aux_table: str, relation: str, data: Dict):
    """ Insert data on db

    Args:
        main_table (str): A main table
        aux_table (str): Table that relates to the main
        relation (str): Related attribute
        data (List[Dict]): Data with the relationship
    """
    values = data.get(relation)
    relation_table = f"{main_table}_{aux_table}"
    LOGGER.info(f'The values {values} will be insert on table {relation_table}')
    if type(values) == int:
        values = [values]

    for item in values:
        conn = DbConn()
        LOGGER.info('Starting insert data')
        try:
            conn.insert(
                relation_table,
                [f'id_{main_table}', f'id_{aux_table}'],
                [data['id'], int(item)]
            )
        except ForeignKeyViolation:
            LOGGER.error('Violates foreign key constraint')

