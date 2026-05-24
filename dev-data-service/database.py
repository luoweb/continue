"""
Database module for Dev Data Service
Supports multiple databases: SQLite, MySQL
"""
import os
from datetime import datetime
from abc import ABC, abstractmethod
from typing import Optional, Dict, Any, List

# Database configuration
DB_TYPE = os.getenv("DB_TYPE", "sqlite").lower()


class DatabaseAdapter(ABC):
    """Abstract base class for database adapters"""

    @abstractmethod
    def get_connection(self):
        """Get a database connection"""
        pass

    @abstractmethod
    def init_db(self):
        """Initialize database tables"""
        pass

    @abstractmethod
    def insert_dev_data(self, event_name: str, schema_version: str,
                       data_level: str, event_data: str,
                       user_id: Optional[str] = None,
                       profile_id: Optional[str] = None) -> int:
        """Insert a new dev data record"""
        pass

    @abstractmethod
    def get_dev_data(self, event_name: Optional[str] = None,
                    user_id: Optional[str] = None,
                    start_date: Optional[datetime] = None,
                    end_date: Optional[datetime] = None,
                    limit: int = 100,
                    offset: int = 0) -> List[Dict[str, Any]]:
        """Query dev data with filters"""
        pass

    @abstractmethod
    def get_stats(self) -> Dict[str, Any]:
        """Get basic statistics about the dev data"""
        pass

    @abstractmethod
    def delete_old_records(self, days: int = 90) -> int:
        """Delete records older than specified days"""
        pass


class SQLiteAdapter(DatabaseAdapter):
    """SQLite database adapter"""

    def __init__(self):
        self.database_path = os.getenv("DATABASE_PATH", "./dev_data.db")

    def get_connection(self):
        import sqlite3
        conn = sqlite3.connect(self.database_path)
        conn.row_factory = sqlite3.Row
        return conn

    def init_db(self):
        conn = self.get_connection()
        cursor = conn.cursor()

        cursor.execute('''
            CREATE TABLE IF NOT EXISTS dev_data (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                event_name TEXT NOT NULL,
                schema_version TEXT NOT NULL,
                data_level TEXT NOT NULL,
                user_id TEXT,
                profile_id TEXT,
                event_data TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')

        cursor.execute('''
            CREATE INDEX IF NOT EXISTS idx_dev_data_event_name
            ON dev_data(event_name)
        ''')
        cursor.execute('''
            CREATE INDEX IF NOT EXISTS idx_dev_data_user_id
            ON dev_data(user_id)
        ''')
        cursor.execute('''
            CREATE INDEX IF NOT EXISTS idx_dev_data_created_at
            ON dev_data(created_at)
        ''')

        conn.commit()
        conn.close()

    def insert_dev_data(self, event_name: str, schema_version: str,
                     data_level: str, event_data: str,
                     user_id: Optional[str] = None,
                     profile_id: Optional[str] = None) -> int:
        conn = self.get_connection()
        cursor = conn.cursor()

        cursor.execute('''
            INSERT INTO dev_data (
                event_name, schema_version, data_level,
                user_id, profile_id, event_data
            )
            VALUES (?, ?, ?, ?, ?, ?)
        ''', (event_name, schema_version, data_level, user_id, profile_id, event_data))

        conn.commit()
        record_id = cursor.lastrowid
        conn.close()

        return record_id

    def get_dev_data(self, event_name: Optional[str] = None,
                    user_id: Optional[str] = None,
                    start_date: Optional[datetime] = None,
                    end_date: Optional[datetime] = None,
                    limit: int = 100,
                    offset: int = 0) -> List[Dict[str, Any]]:
        conn = self.get_connection()
        cursor = conn.cursor()

        query = "SELECT * FROM dev_data WHERE 1=1"
        params = []

        if event_name:
            query += " AND event_name = ?"
            params.append(event_name)

        if user_id:
            query += " AND user_id = ?"
            params.append(user_id)

        if start_date:
            query += " AND created_at >= ?"
            params.append(start_date.isoformat())

        if end_date:
            query += " AND created_at <= ?"
            params.append(end_date.isoformat())

        query += " ORDER BY created_at DESC LIMIT ? OFFSET ?"
        params.extend([limit, offset])

        cursor.execute(query, params)
        records = cursor.fetchall()
        conn.close()

        return [dict(record) for record in records]

    def get_stats(self) -> Dict[str, Any]:
        conn = self.get_connection()
        cursor = conn.cursor()

        stats = {}

        cursor.execute("SELECT COUNT(*) as total FROM dev_data")
        stats["total_records"] = cursor.fetchone()["total"]

        cursor.execute('''
            SELECT event_name, COUNT(*) as count
            FROM dev_data
            GROUP BY event_name
        ''')
        stats["by_event"] = {row["event_name"]: row["count"] for row in cursor.fetchall()}

        cursor.execute('''
            SELECT DATE(created_at) as date, COUNT(*) as count
            FROM dev_data
            WHERE created_at >= DATE('now', '-7 days')
            GROUP BY DATE(created_at)
            ORDER BY date
        ''')
        stats["last_7_days"] = {str(row["date"]): row["count"] for row in cursor.fetchall()}

        conn.close()
        return stats

    def delete_old_records(self, days: int = 90) -> int:
        conn = self.get_connection()
        cursor = conn.cursor()

        cursor.execute('''
            DELETE FROM dev_data
            WHERE created_at < DATE('now', ?)
        ''', (f'-{days} days',))

        deleted_count = cursor.rowcount
        conn.commit()
        conn.close()

        return deleted_count


class MySQLAdapter(DatabaseAdapter):
    """MySQL database adapter"""

    def __init__(self):
        self.host = os.getenv("DB_HOST", "localhost")
        self.port = int(os.getenv("DB_PORT", "3306"))
        self.user = os.getenv("DB_USER", "root")
        self.password = os.getenv("DB_PASSWORD", "")
        self.database = os.getenv("DB_NAME", "cowork_dev_data")
        self.charset = os.getenv("DB_CHARSET", "utf8mb4")

    def get_connection(self):
        try:
            import pymysql
            conn = pymysql.connect(
                host=self.host,
                port=self.port,
                user=self.user,
                password=self.password,
                database=self.database,
                charset=self.charset,
                cursorclass=pymysql.cursors.DictCursor
            )
            return conn
        except ImportError:
            raise ImportError("pymysql is required for MySQL. Install with: pip install pymysql")

    def init_db(self):
        conn = self.get_connection()
        cursor = conn.cursor()

        cursor.execute('''
            CREATE TABLE IF NOT EXISTS dev_data (
                id INT AUTO_INCREMENT PRIMARY KEY,
                event_name VARCHAR(255) NOT NULL,
                schema_version VARCHAR(50) NOT NULL,
                data_level VARCHAR(50) NOT NULL,
                user_id VARCHAR(255),
                profile_id VARCHAR(255),
                event_data TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_event_name (event_name),
                INDEX idx_user_id (user_id),
                INDEX idx_created_at (created_at)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        ''')

        conn.commit()
        conn.close()

    def insert_dev_data(self, event_name: str, schema_version: str,
                     data_level: str, event_data: str,
                     user_id: Optional[str] = None,
                     profile_id: Optional[str] = None) -> int:
        conn = self.get_connection()
        cursor = conn.cursor()

        cursor.execute('''
            INSERT INTO dev_data (
                event_name, schema_version, data_level,
                user_id, profile_id, event_data
            )
            VALUES (%s, %s, %s, %s, %s, %s)
        ''', (event_name, schema_version, data_level, user_id, profile_id, event_data))

        conn.commit()
        record_id = cursor.lastrowid
        conn.close()

        return record_id

    def get_dev_data(self, event_name: Optional[str] = None,
                    user_id: Optional[str] = None,
                    start_date: Optional[datetime] = None,
                    end_date: Optional[datetime] = None,
                    limit: int = 100,
                    offset: int = 0) -> List[Dict[str, Any]]:
        conn = self.get_connection()
        cursor = conn.cursor()

        query = "SELECT * FROM dev_data WHERE 1=1"
        params = []

        if event_name:
            query += " AND event_name = %s"
            params.append(event_name)

        if user_id:
            query += " AND user_id = %s"
            params.append(user_id)

        if start_date:
            query += " AND created_at >= %s"
            params.append(start_date.isoformat())

        if end_date:
            query += " AND created_at <= %s"
            params.append(end_date.isoformat())

        query += " ORDER BY created_at DESC LIMIT %s OFFSET %s"
        params.extend([limit, offset])

        cursor.execute(query, params)
        records = cursor.fetchall()
        conn.close()

        # Convert datetime objects to strings for MySQL
        for record in records:
            if 'created_at' in record and hasattr(record['created_at'], 'isoformat'):
                record['created_at'] = record['created_at'].isoformat()

        return records

    def get_stats(self) -> Dict[str, Any]:
        conn = self.get_connection()
        cursor = conn.cursor()

        stats = {}

        cursor.execute("SELECT COUNT(*) as total FROM dev_data")
        stats["total_records"] = cursor.fetchone()["total"]

        cursor.execute('''
            SELECT event_name, COUNT(*) as count
            FROM dev_data
            GROUP BY event_name
        ''')
        stats["by_event"] = {row["event_name"]: row["count"] for row in cursor.fetchall()}

        cursor.execute('''
            SELECT DATE(created_at) as date, COUNT(*) as count
            FROM dev_data
            WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
            GROUP BY DATE(created_at)
            ORDER BY date
        ''')
        stats["last_7_days"] = {str(row["date"]): row["count"] for row in cursor.fetchall()}

        conn.close()
        return stats

    def delete_old_records(self, days: int = 90) -> int:
        conn = self.get_connection()
        cursor = conn.cursor()

        cursor.execute('''
            DELETE FROM dev_data
            WHERE created_at < DATE_SUB(CURDATE(), INTERVAL %s DAY)
        ''', (days,))

        deleted_count = cursor.rowcount
        conn.commit()
        conn.close()

        return deleted_count


def get_database_adapter() -> DatabaseAdapter:
    """Factory function to get the appropriate database adapter"""
    if DB_TYPE == "mysql":
        return MySQLAdapter()
    elif DB_TYPE == "sqlite":
        return SQLiteAdapter()
    else:
        raise ValueError(f"Unsupported database type: {DB_TYPE}. Supported types: sqlite, mysql")


# Global adapter instance
_adapter: Optional[DatabaseAdapter] = None


def get_db_connection():
    """Get a database connection (legacy function for backward compatibility"""
    return get_adapter().get_connection()


def get_adapter() -> DatabaseAdapter:
    """Get the current database adapter"""
    global _adapter
    if _adapter is None:
        _adapter = get_database_adapter()
    return _adapter


def init_db():
    """Initialize the database tables"""
    get_adapter().init_db()


def insert_dev_data(
    event_name: str,
    schema_version: str,
    data_level: str,
    event_data: str,
    user_id: Optional[str] = None,
    profile_id: Optional[str] = None
) -> int:
    """Insert a new dev data record"""
    return get_adapter().insert_dev_data(
        event_name, schema_version, data_level, event_data, user_id, profile_id
    )


def get_dev_data(
    event_name: Optional[str] = None,
    user_id: Optional[str] = None,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    limit: int = 100,
    offset: int = 0
) -> List[Dict[str, Any]]:
    """Query dev data with filters"""
    return get_adapter().get_dev_data(
        event_name, user_id, start_date, end_date, limit, offset
    )


def get_stats() -> Dict[str, Any]:
    """Get basic statistics about the dev data"""
    return get_adapter().get_stats()


def delete_old_records(days: int = 90) -> int:
    """Delete records older than specified days"""
    return get_adapter().delete_old_records(days)
