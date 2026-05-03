import os
import sqlite3
from datetime import datetime, timedelta
from typing import Optional, Tuple

DATABASE_PATH = os.getenv("DATABASE_PATH", "auth.db")

def init_db():
    conn = sqlite3.connect(DATABASE_PATH)
    cursor = conn.cursor()
    
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS users (
            id TEXT PRIMARY KEY,
            email TEXT UNIQUE NOT NULL,
            hashed_password TEXT NOT NULL,
            first_name TEXT,
            last_name TEXT,
            organization_id TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS refresh_tokens (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            token TEXT UNIQUE NOT NULL,
            expires_at TIMESTAMP NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id)
        )
    ''')
    
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS device_codes (
            id TEXT PRIMARY KEY,
            user_code TEXT UNIQUE NOT NULL,
            device_code TEXT UNIQUE NOT NULL,
            user_id TEXT,
            client_id TEXT NOT NULL,
            expires_at TIMESTAMP NOT NULL,
            interval INTEGER NOT NULL DEFAULT 5,
            status TEXT NOT NULL DEFAULT 'pending',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id)
        )
    ''')
    
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS authorization_codes (
            id TEXT PRIMARY KEY,
            code TEXT UNIQUE NOT NULL,
            user_id TEXT NOT NULL,
            client_id TEXT NOT NULL,
            redirect_uri TEXT NOT NULL,
            state TEXT,
            expires_at TIMESTAMP NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id)
        )
    ''')
    
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS organizations (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            slug TEXT UNIQUE NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS user_organizations (
            user_id TEXT NOT NULL,
            organization_id TEXT NOT NULL,
            role TEXT NOT NULL DEFAULT 'member',
            joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (user_id, organization_id),
            FOREIGN KEY (user_id) REFERENCES users(id),
            FOREIGN KEY (organization_id) REFERENCES organizations(id)
        )
    ''')
    
    conn.commit()
    conn.close()

def get_db_connection():
    return sqlite3.connect(DATABASE_PATH)

def create_user(user_id: str, email: str, hashed_password: str, first_name: str = "", last_name: str = ""):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute('''
            INSERT INTO users (id, email, hashed_password, first_name, last_name)
            VALUES (?, ?, ?, ?, ?)
        ''', (user_id, email, hashed_password, first_name, last_name))
        conn.commit()
        return True
    except sqlite3.IntegrityError:
        return False
    finally:
        conn.close()

def get_user_by_email(email: str) -> Optional[dict]:
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM users WHERE email = ?', (email,))
    row = cursor.fetchone()
    conn.close()
    if row:
        return {
            "id": row[0],
            "email": row[1],
            "hashed_password": row[2],
            "first_name": row[3],
            "last_name": row[4],
            "organization_id": row[5],
            "created_at": row[6],
            "updated_at": row[7]
        }
    return None

def get_user_by_id(user_id: str) -> Optional[dict]:
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM users WHERE id = ?', (user_id,))
    row = cursor.fetchone()
    conn.close()
    if row:
        return {
            "id": row[0],
            "email": row[1],
            "hashed_password": row[2],
            "first_name": row[3],
            "last_name": row[4],
            "organization_id": row[5],
            "created_at": row[6],
            "updated_at": row[7]
        }
    return None

def create_refresh_token(token_id: str, user_id: str, token: str, expires_at: datetime):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('''
        INSERT INTO refresh_tokens (id, user_id, token, expires_at)
        VALUES (?, ?, ?, ?)
    ''', (token_id, user_id, token, expires_at.isoformat()))
    conn.commit()
    conn.close()

def get_refresh_token(token: str) -> Optional[dict]:
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM refresh_tokens WHERE token = ?', (token,))
    row = cursor.fetchone()
    conn.close()
    if row:
        return {
            "id": row[0],
            "user_id": row[1],
            "token": row[2],
            "expires_at": row[3],
            "created_at": row[4]
        }
    return None

def delete_refresh_token(token: str):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('DELETE FROM refresh_tokens WHERE token = ?', (token,))
    conn.commit()
    conn.close()

def create_device_code(device_code_id: str, user_code: str, device_code: str, client_id: str, expires_at: datetime, interval: int = 5):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('''
        INSERT INTO device_codes (id, user_code, device_code, client_id, expires_at, interval)
        VALUES (?, ?, ?, ?, ?, ?)
    ''', (device_code_id, user_code, device_code, client_id, expires_at.isoformat(), interval))
    conn.commit()
    conn.close()

def get_device_code(device_code: str) -> Optional[dict]:
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM device_codes WHERE device_code = ?', (device_code,))
    row = cursor.fetchone()
    conn.close()
    if row:
        return {
            "id": row[0],
            "user_code": row[1],
            "device_code": row[2],
            "user_id": row[3],
            "client_id": row[4],
            "expires_at": row[5],
            "interval": row[6],
            "status": row[7],
            "created_at": row[8]
        }
    return None

def get_device_code_by_user_code(user_code: str) -> Optional[dict]:
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM device_codes WHERE user_code = ?', (user_code,))
    row = cursor.fetchone()
    conn.close()
    if row:
        return {
            "id": row[0],
            "user_code": row[1],
            "device_code": row[2],
            "user_id": row[3],
            "client_id": row[4],
            "expires_at": row[5],
            "interval": row[6],
            "status": row[7],
            "created_at": row[8]
        }
    return None

def update_device_code_status(device_code: str, user_id: str = None, status: str = "authorized"):
    conn = get_db_connection()
    cursor = conn.cursor()
    if user_id:
        cursor.execute('''
            UPDATE device_codes SET user_id = ?, status = ? WHERE device_code = ?
        ''', (user_id, status, device_code))
    else:
        cursor.execute('''
            UPDATE device_codes SET status = ? WHERE device_code = ?
        ''', (status, device_code))
    conn.commit()
    conn.close()

def create_authorization_code(code_id: str, code: str, user_id: str, client_id: str, redirect_uri: str, state: str, expires_at: datetime):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('''
        INSERT INTO authorization_codes (id, code, user_id, client_id, redirect_uri, state, expires_at)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    ''', (code_id, code, user_id, client_id, redirect_uri, state, expires_at.isoformat()))
    conn.commit()
    conn.close()

def get_authorization_code(code: str) -> Optional[dict]:
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM authorization_codes WHERE code = ?', (code,))
    row = cursor.fetchone()
    conn.close()
    if row:
        return {
            "id": row[0],
            "code": row[1],
            "user_id": row[2],
            "client_id": row[3],
            "redirect_uri": row[4],
            "state": row[5],
            "expires_at": row[6],
            "created_at": row[7]
        }
    return None

def delete_authorization_code(code: str):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('DELETE FROM authorization_codes WHERE code = ?', (code,))
    conn.commit()
    conn.close()

def create_organization(org_id: str, name: str, slug: str):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute('''
            INSERT INTO organizations (id, name, slug)
            VALUES (?, ?, ?)
        ''', (org_id, name, slug))
        conn.commit()
        return True
    except sqlite3.IntegrityError:
        return False
    finally:
        conn.close()

def add_user_to_organization(user_id: str, organization_id: str, role: str = "member"):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute('''
            INSERT INTO user_organizations (user_id, organization_id, role)
            VALUES (?, ?, ?)
        ''', (user_id, organization_id, role))
        conn.commit()
        return True
    except sqlite3.IntegrityError:
        return False
    finally:
        conn.close()

def get_user_organizations(user_id: str) -> list:
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('''
        SELECT o.id, o.name, o.slug, uo.role, uo.joined_at
        FROM user_organizations uo
        JOIN organizations o ON uo.organization_id = o.id
        WHERE uo.user_id = ?
    ''', (user_id,))
    rows = cursor.fetchall()
    conn.close()
    return [{
        "id": row[0],
        "name": row[1],
        "slug": row[2],
        "role": row[3],
        "joined_at": row[4]
    } for row in rows]

def cleanup_expired_tokens():
    conn = get_db_connection()
    cursor = conn.cursor()
    now = datetime.now().isoformat()
    cursor.execute('DELETE FROM refresh_tokens WHERE expires_at < ?', (now,))
    cursor.execute('DELETE FROM device_codes WHERE expires_at < ?', (now,))
    cursor.execute('DELETE FROM authorization_codes WHERE expires_at < ?', (now,))
    conn.commit()
    conn.close()

init_db()