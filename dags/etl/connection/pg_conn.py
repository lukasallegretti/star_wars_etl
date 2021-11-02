"""
Hold operations for connecting to database, centralized to be used
by all DAGs
"""
import logging
from typing import List, Dict

from airflow.providers.postgres.hooks.postgres import PostgresHook
from psycopg2.extras import DictCursor
from psycopg2 import sql


LOGGER = logging.getLogger('airflow.task')

class DbConn():
    """ Class to centralize postgres hook connection """

    def __init__(self):
        """ Initial db connection """
        self.hook = PostgresHook(postgres_conn_id='pg_default')
        self.conn = self.hook.get_conn()

    def select(self, table: str) -> List[Dict]:
        """ Select data from table in database

        Args:
            query (str): query to be executed
            params ([type], optional): dynamic params. Defaults to None.
        """
        cursor = self.conn.cursor(
            cursor_factory=DictCursor
        )

        query = sql.SQL("SELECT * FROM {}").format(
        sql.SQL(table)
        ).as_string(cursor)
        LOGGER.info('The query is: %s', query)
        cursor.execute(query)

        return cursor.fetchall()

    def insert(self, table: str, columns: List, values: List) -> None:
        """ Will insert data on database

        Args:
            table (str): Table to be inserted
            columns (List): Columns where will be inserted
            values (List): Values that will be inserted
        """
        cursor = self.conn.cursor()

        query = sql.SQL("INSERT INTO {} ({}) VALUES ({})").format(
        sql.SQL(table),
        sql.SQL(', ').join(map(sql.Identifier, columns)),
        sql.SQL(', ').join(map(sql.Literal, values)),        
        ).as_string(cursor)
        LOGGER.info('The query is: %s', query)

        cursor.execute(query)
        self.conn.commit()
