"""
Database helper – thin wrapper around mysql.connector with connection pooling.
Every function returns plain Python dicts so templates can use row['column'].
Includes proper error handling so connection/query failures produce
user-friendly flash messages instead of raw Flask tracebacks.
"""

import mysql.connector
from mysql.connector import pooling, Error as MySQLError
import config

_pool = None


def _get_pool():
    """Lazy-initialise and return the connection pool."""
    global _pool
    if _pool is None:
        try:
            _pool = pooling.MySQLConnectionPool(
                pool_name="elite_pool",
                pool_size=5,
                host=config.MYSQL_HOST,
                port=config.MYSQL_PORT,
                user=config.MYSQL_USER,
                password=config.MYSQL_PASSWORD,
                database=config.MYSQL_DATABASE,
            )
        except MySQLError as e:
            raise ConnectionError(
                f"Cannot connect to MySQL database '{config.MYSQL_DATABASE}' "
                f"at {config.MYSQL_HOST}:{config.MYSQL_PORT} as '{config.MYSQL_USER}'. "
                f"MySQL error: {e}"
            )
    return _pool


def get_connection():
    """Get a connection from the pool."""
    try:
        return _get_pool().get_connection()
    except (MySQLError, ConnectionError) as e:
        raise ConnectionError(f"Database connection failed: {e}")


def execute_query(sql, params=None, fetchone=False):
    """
    Run a SELECT and return a list of dicts (or a single dict if fetchone=True).
    """
    conn = get_connection()
    try:
        cur = conn.cursor(dictionary=True)
        cur.execute(sql, params or ())
        rows = cur.fetchone() if fetchone else cur.fetchall()
        cur.close()
        return rows
    except MySQLError as e:
        raise RuntimeError(f"Query failed: {e}")
    finally:
        conn.close()


def execute_update(sql, params=None):
    """Run an INSERT / UPDATE / DELETE and commit."""
    conn = get_connection()
    try:
        cur = conn.cursor()
        cur.execute(sql, params or ())
        conn.commit()
        affected = cur.rowcount
        cur.close()
        return affected
    except MySQLError as e:
        conn.rollback()
        raise RuntimeError(f"Update failed: {e}")
    finally:
        conn.close()


def call_proc(proc_name, args=()):
    """
    Call a stored procedure and return the first result-set row (dict).
    Most of the club's procedures SELECT a 'Message' column.
    """
    conn = get_connection()
    try:
        cur = conn.cursor(dictionary=True)
        cur.callproc(proc_name, args)
        # stored procedures may produce multiple result sets
        for result in cur.stored_results():
            row = result.fetchone()
            if row:
                return row
        conn.commit()
        return {"Message": "Procedure executed successfully."}
    except MySQLError as e:
        conn.rollback()
        raise RuntimeError(f"Procedure '{proc_name}' failed: {e}")
    finally:
        conn.close()


def execute_query_raw(sql, params=None):
    """Run arbitrary SQL that may contain multiple statements (for views etc.)."""
    conn = get_connection()
    try:
        cur = conn.cursor(dictionary=True)
        cur.execute(sql, params or ())
        try:
            rows = cur.fetchall()
        except Exception:
            rows = []
        conn.commit()
        cur.close()
        return rows
    except MySQLError as e:
        raise RuntimeError(f"Raw query failed: {e}")
    finally:
        conn.close()
