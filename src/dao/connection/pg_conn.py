import logging
from typing import List, Dict

import psycopg2
from psycopg2.extras import DictCursor
from psycopg2 import sql


LOGGER = logging.getLogger(__name__)

class DbConn():
    """ Class to centralize postgres connection """

    def __init__(self):
        self._conn = psycopg2.connect(
            host='postgres',
            database='postgres',
            user='postgres',
            password='postgres'
        )


    def execute_query(self, table: str, columns: List, values: List):
        cursor = self._conn.cursor()
        query = sql.SQL("INSERT INTO {} ({}) VALUES ({})").format(
        sql.SQL(table),
        sql.SQL(', ').join(map(sql.Identifier, columns)),
        sql.SQL(', ').join(map(sql.Literal, values)),        
        ).as_string(cursor)

        cursor.execute(
            query
        )
        self._conn.commit()

    def select(self, table: str) -> List[Dict]:
        """ Select data from databse

        Args:
            table (str): The data will be from this table
        """
        cursor = self._conn.cursor(
            cursor_factory=DictCursor
        )
        query = sql.SQL("SELECT * FROM {}").format(
            sql.SQL(table)
        ).as_string(cursor)
        
        cursor.execute(query)

        return cursor.fetchall()