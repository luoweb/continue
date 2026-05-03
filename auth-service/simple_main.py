from fastapi import FastAPI, HTTPException, Form
from fastapi.responses import HTMLResponse
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime, timedelta
import uuid
import os
import hashlib
import base64

app = FastAPI(title="Continue Auth Service", version="2.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

SECRET_KEY = os.getenv("SECRET_KEY", "your-secret-key-here-must-be-at-least-32-chars")
ACCESS_TOKEN_EXPIRE_MINUTES = 60
REFRESH_TOKEN_EXPIRE_DAYS = 7

API_BASE = os.getenv("API_BASE", "http://localhost:8000")
CLIENT_ID = os.getenv("CLIENT_ID", "continue-cli")

users = {}
refresh_tokens = {}
device_codes = {}
authorization_codes = {}

def hash_password(password):
    return hashlib.sha256((password + SECRET_KEY).encode()).hexdigest()

def verify_password(plain_password, hashed_password):
    return hash_password(plain_password) == hashed_password

def create_access_token(user_id, email):
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    token_data = f"{user_id}:{email}:{expire.timestamp()}"
    token = base64.b64encode(token_data.encode()).decode()
    return token, int(expire.timestamp())

def decode_access_token(token):
    try:
        decoded = base64.b64decode(token).decode()
        parts = decoded.split(":")
        if len(parts) >= 3:
            user_id, email, expires_at = parts[0], parts[1], float(parts[2])
            if datetime.utcnow().timestamp() < expires_at:
                return {"sub": user_id, "email": email}
        return None
    except:
        return None

def generate_refresh_token():
    return str(uuid.uuid4())

def generate_user_code():
    return '-'.join([str(uuid.uuid4()).replace('-', '')[:4].upper() for _ in range(3)])

@app.post("/auth/register")
async def register(email: str, password: str, first_name: str = "", last_name: str = ""):
    if email in users:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    user_id = str(uuid.uuid4())
    hashed_password = hash_password(password)
    
    users[email] = {
        "id": user_id,
        "email": email,
        "hashed_password": hashed_password,
        "first_name": first_name,
        "last_name": last_name,
        "organization_id": None
    }
    
    access_token, expires_at = create_access_token(user_id, email)
    refresh_token = generate_refresh_token()
    refresh_tokens[refresh_token] = {
        "user_id": user_id,
        "expires_at": datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
    }
    
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "expires_at": expires_at,
        "user_id": user_id,
        "user_email": email
    }

@app.post("/auth/login")
async def login(email: str, password: str):
    if email not in users or not verify_password(password, users[email]["hashed_password"]):
        raise HTTPException(status_code=401, detail="Invalid email or password")
    
    user = users[email]
    access_token, expires_at = create_access_token(user["id"], user["email"])
    refresh_token = generate_refresh_token()
    refresh_tokens[refresh_token] = {
        "user_id": user["id"],
        "expires_at": datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
    }
    
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "expires_at": expires_at,
        "user_id": user["id"],
        "user_email": user["email"]
    }

@app.get("/auth/authorize")
async def authorize(client_id: str, redirect_uri: str = None, state: str = None):
    if client_id != CLIENT_ID:
        raise HTTPException(status_code=400, detail="Invalid client_id")
    
    redirect = redirect_uri or "http://localhost:8000/auth/callback"
    
    login_page = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <title>Continue Login</title>
        <style>
            body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 400px; margin: 0 auto; padding: 20px; }}
            .form-group {{ margin-bottom: 15px; }}
            label {{ display: block; margin-bottom: 5px; }}
            input {{ width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; }}
            button {{ width: 100%; padding: 12px; background: #6366f1; color: white; border: none; border-radius: 4px; cursor: pointer; }}
            button:hover {{ background: #4f46e5; }}
            .error {{ color: red; margin-top: 10px; }}
        </style>
    </head>
    <body>
        <h1>Continue Login</h1>
        <form id="loginForm">
            <div class="form-group">
                <label for="email">Email</label>
                <input type="email" id="email" required>
            </div>
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" required>
            </div>
            <button type="submit">Login</button>
        </form>
        <div class="error" id="error"></div>
        <script>
            document.getElementById('loginForm').addEventListener('submit', async (e) => {{
                e.preventDefault();
                const email = document.getElementById('email').value;
                const password = document.getElementById('password').value;
                const errorDiv = document.getElementById('error');
                
                try {{
                    const response = await fetch('{API_BASE}/auth/token', {{
                        method: 'POST',
                        headers: {{ 'Content-Type': 'application/json' }},
                        body: JSON.stringify({{ email, password, grant_type: 'password', client_id: '{client_id}' }})
                    }});
                    
                    if (!response.ok) {{
                        const data = await response.json();
                        errorDiv.textContent = data.detail || 'Login failed';
                        return;
                    }}
                    
                    const data = await response.json();
                    const redirectUrl = new URL('{redirect}');
                    redirectUrl.searchParams.set('code', data.authorization_code);
                    if ('{state}') redirectUrl.searchParams.set('state', '{state}');
                    window.location.href = redirectUrl.toString();
                }} catch (err) {{
                    errorDiv.textContent = 'An error occurred';
                }}
            }});
        </script>
    </body>
    </html>
    """
    return HTMLResponse(content=login_page)

@app.post("/auth/token")
async def token_endpoint(grant_type: str, email: str = None, password: str = None, 
                        code: str = None, refresh_token: str = None, device_code: str = None,
                        client_id: str = None):
    if client_id != CLIENT_ID:
        raise HTTPException(status_code=400, detail="Invalid client_id")
    
    if grant_type == "password":
        if not email or not password:
            raise HTTPException(status_code=400, detail="email and password are required")
        
        if email not in users or not verify_password(password, users[email]["hashed_password"]):
            raise HTTPException(status_code=401, detail="Invalid email or password")
        
        auth_code = str(uuid.uuid4())
        authorization_codes[auth_code] = {
            "user_id": users[email]["id"],
            "expires_at": datetime.utcnow() + timedelta(minutes=5)
        }
        
        return {"authorization_code": auth_code}
    
    elif grant_type == "authorization_code":
        if not code or code not in authorization_codes:
            raise HTTPException(status_code=400, detail="Invalid authorization code")
        
        auth_code_data = authorization_codes[code]
        if datetime.utcnow() > auth_code_data["expires_at"]:
            del authorization_codes[code]
            raise HTTPException(status_code=400, detail="Authorization code expired")
        
        user_id = auth_code_data["user_id"]
        user = next((u for u in users.values() if u["id"] == user_id), None)
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
        del authorization_codes[code]
        
        access_token, expires_at = create_access_token(user["id"], user["email"])
        refresh_token_val = generate_refresh_token()
        refresh_tokens[refresh_token_val] = {
            "user_id": user["id"],
            "expires_at": datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
        }
        
        return {
            "access_token": access_token,
            "refresh_token": refresh_token_val,
            "user": {"id": user["id"], "email": user["email"]},
            "expires_in": ACCESS_TOKEN_EXPIRE_MINUTES * 60,
            "issued_at": int(datetime.utcnow().timestamp())
        }
    
    elif grant_type == "refresh_token":
        if not refresh_token or refresh_token not in refresh_tokens:
            raise HTTPException(status_code=401, detail="Invalid refresh token")
        
        token_data = refresh_tokens[refresh_token]
        if datetime.utcnow() > token_data["expires_at"]:
            del refresh_tokens[refresh_token]
            raise HTTPException(status_code=401, detail="Refresh token expired")
        
        user = next((u for u in users.values() if u["id"] == token_data["user_id"]), None)
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
        del refresh_tokens[refresh_token]
        
        access_token, expires_at = create_access_token(user["id"], user["email"])
        new_refresh_token = generate_refresh_token()
        refresh_tokens[new_refresh_token] = {
            "user_id": user["id"],
            "expires_at": datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
        }
        
        return {
            "access_token": access_token,
            "refresh_token": new_refresh_token,
            "user": {"id": user["id"], "email": user["email"]},
            "expires_in": ACCESS_TOKEN_EXPIRE_MINUTES * 60,
            "issued_at": int(datetime.utcnow().timestamp())
        }
    
    elif grant_type == "urn:ietf:params:oauth:grant-type:device_code":
        if not device_code or device_code not in device_codes:
            raise HTTPException(status_code=400, detail="Invalid device code")
        
        device_code_data = device_codes[device_code]
        if datetime.utcnow() > device_code_data["expires_at"]:
            del device_codes[device_code]
            raise HTTPException(status_code=400, detail="Device code expired")
        
        if device_code_data["status"] == "pending":
            raise HTTPException(status_code=400, detail="Authorization pending")
        
        if device_code_data["status"] == "denied":
            raise HTTPException(status_code=400, detail="Access denied")
        
        user_id = device_code_data["user_id"]
        user = next((u for u in users.values() if u["id"] == user_id), None)
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
        access_token, expires_at = create_access_token(user["id"], user["email"])
        refresh_token_val = generate_refresh_token()
        refresh_tokens[refresh_token_val] = {
            "user_id": user["id"],
            "expires_at": datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
        }
        
        return {
            "access_token": access_token,
            "refresh_token": refresh_token_val,
            "user": {"id": user["id"], "email": user["email"]},
            "expires_in": ACCESS_TOKEN_EXPIRE_MINUTES * 60,
            "issued_at": int(datetime.utcnow().timestamp())
        }
    
    else:
        raise HTTPException(status_code=400, detail=f"Unsupported grant_type: {grant_type}")

@app.post("/auth/refresh")
async def refresh_token(refreshToken: str):
    if refreshToken not in refresh_tokens:
        raise HTTPException(status_code=401, detail="Invalid refresh token")
    
    token_data = refresh_tokens[refreshToken]
    if datetime.utcnow() > token_data["expires_at"]:
        del refresh_tokens[refreshToken]
        raise HTTPException(status_code=401, detail="Refresh token expired")
    
    user = next((u for u in users.values() if u["id"] == token_data["user_id"]), None)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    del refresh_tokens[refreshToken]
    
    access_token, expires_at = create_access_token(user["id"], user["email"])
    new_refresh_token = generate_refresh_token()
    refresh_tokens[new_refresh_token] = {
        "user_id": user["id"],
        "expires_at": datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
    }
    
    return {
        "access_token": access_token,
        "refresh_token": new_refresh_token,
        "expires_at": expires_at,
        "user_id": user["id"],
        "user_email": user["email"]
    }

@app.post("/user_management/authorize/device")
async def device_authorization(client_id: str = Form(None)):
    if not client_id or client_id != CLIENT_ID:
        raise HTTPException(status_code=400, detail="Invalid client_id")
    
    device_code = str(uuid.uuid4())
    user_code = generate_user_code()
    
    device_codes[device_code] = {
        "user_code": user_code,
        "client_id": client_id,
        "user_id": None,
        "status": "pending",
        "expires_at": datetime.utcnow() + timedelta(minutes=10),
        "interval": 5
    }
    
    verification_uri = f"{API_BASE}/auth/device"
    verification_uri_complete = f"{verification_uri}?user_code={user_code}"
    
    return {
        "device_code": device_code,
        "user_code": user_code,
        "verification_uri": verification_uri,
        "verification_uri_complete": verification_uri_complete,
        "expires_in": 600,
        "interval": 5
    }

@app.get("/auth/device")
async def device_login_page(user_code: str = None):
    if not user_code:
        return HTMLResponse(content="<html><body><h1>Device Authorization</h1><p>Please provide a user code</p></body></html>")
    
    device_code_data = next((d for d in device_codes.values() if d["user_code"] == user_code), None)
    if not device_code_data:
        return HTMLResponse(content="<html><body><h1>Device Authorization</h1><p>Invalid user code</p></body></html>")
    
    login_page = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <title>Device Authorization - Continue</title>
        <style>
            body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 400px; margin: 0 auto; padding: 20px; }}
            .code {{ font-family: monospace; font-size: 24px; letter-spacing: 4px; margin-bottom: 20px; }}
            .form-group {{ margin-bottom: 15px; }}
            label {{ display: block; margin-bottom: 5px; }}
            input {{ width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; }}
            button {{ width: 100%; padding: 12px; background: #6366f1; color: white; border: none; border-radius: 4px; cursor: pointer; }}
            button:hover {{ background: #4f46e5; }}
            .error {{ color: red; margin-top: 10px; }}
            .success {{ color: green; margin-top: 10px; }}
        </style>
    </head>
    <body>
        <h1>Continue Device Login</h1>
        <p>Enter the code displayed on your device:</p>
        <div class="code">{user_code}</div>
        <form id="loginForm">
            <div class="form-group">
                <label for="email">Email</label>
                <input type="email" id="email" required>
            </div>
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" required>
            </div>
            <button type="submit">Authorize Device</button>
        </form>
        <div class="error" id="error"></div>
        <div class="success" id="success"></div>
        <script>
            document.getElementById('loginForm').addEventListener('submit', async (e) => {{
                e.preventDefault();
                const email = document.getElementById('email').value;
                const password = document.getElementById('password').value;
                const errorDiv = document.getElementById('error');
                const successDiv = document.getElementById('success');
                
                errorDiv.textContent = '';
                successDiv.textContent = '';
                
                try {{
                    const response = await fetch('{API_BASE}/auth/device/authorize', {{
                        method: 'POST',
                        headers: {{ 'Content-Type': 'application/json' }},
                        body: JSON.stringify({{ user_code: '{user_code}', email, password }})
                    }});
                    
                    if (!response.ok) {{
                        const data = await response.json();
                        errorDiv.textContent = data.detail || 'Authorization failed';
                        return;
                    }}
                    
                    successDiv.textContent = 'Device authorized successfully! You can close this page.';
                    document.getElementById('loginForm').style.display = 'none';
                }} catch (err) {{
                    errorDiv.textContent = 'An error occurred';
                }}
            }});
        </script>
    </body>
    </html>
    """
    return HTMLResponse(content=login_page)

@app.post("/auth/device/authorize")
async def authorize_device(user_code: str, email: str, password: str):
    device_code_data = next((d for d in device_codes.values() if d["user_code"] == user_code), None)
    if not device_code_data:
        raise HTTPException(status_code=400, detail="Invalid user code")
    
    if datetime.utcnow() > device_code_data["expires_at"]:
        raise HTTPException(status_code=400, detail="User code expired")
    
    if email not in users or not verify_password(password, users[email]["hashed_password"]):
        raise HTTPException(status_code=401, detail="Invalid email or password")
    
    device_code = next((k for k, v in device_codes.items() if v["user_code"] == user_code), None)
    if device_code:
        device_codes[device_code]["user_id"] = users[email]["id"]
        device_codes[device_code]["status"] = "authorized"
    
    return {"message": "Device authorized successfully"}

@app.post("/user_management/authenticate")
async def authenticate(grant_type: str = Form(None), device_code: str = Form(None), client_id: str = Form(None),
                      refresh_token: str = Form(None), code: str = Form(None), redirect_uri: str = Form(None)):
    return await token_endpoint(grant_type=grant_type, device_code=device_code, 
                               client_id=client_id, refresh_token=refresh_token, code=code)

@app.get("/auth/userinfo")
async def userinfo(access_token: str):
    payload = decode_access_token(access_token)
    if not payload:
        raise HTTPException(status_code=401, detail="Invalid access token")
    
    user = next((u for u in users.values() if u["id"] == payload["sub"]), None)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    return {
        "id": user["id"],
        "email": user["email"],
        "first_name": user["first_name"],
        "last_name": user["last_name"],
        "organization_id": user["organization_id"]
    }

@app.get("/user_management/users/me")
async def user_me(access_token: str = None, authorization: str = None):
    token = access_token
    if authorization and authorization.startswith("Bearer "):
        token = authorization[7:]
    
    if not token:
        raise HTTPException(status_code=400, detail="access_token is required")
    
    payload = decode_access_token(token)
    if not payload:
        raise HTTPException(status_code=401, detail="Invalid access token")
    
    user = next((u for u in users.values() if u["id"] == payload["sub"]), None)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    return {
        "id": user["id"],
        "email": user["email"],
        "first_name": user["first_name"],
        "last_name": user["last_name"],
        "organization_id": user["organization_id"]
    }

@app.get("/auth/scope")
async def auth_scope(authorization: str = None):
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=400, detail="Authorization header required")
    
    access_token = authorization[7:]
    payload = decode_access_token(access_token)
    if not payload:
        raise HTTPException(status_code=401, detail="Invalid access token")
    
    user = next((u for u in users.values() if u["id"] == payload["sub"]), None)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    return {"organizationId": user["organization_id"]}

@app.get("/auth/callback")
async def callback(code: str):
    if code not in authorization_codes:
        raise HTTPException(status_code=400, detail="Invalid authorization code")
    
    auth_code_data = authorization_codes[code]
    user = next((u for u in users.values() if u["id"] == auth_code_data["user_id"]), None)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    access_token, expires_at = create_access_token(user["id"], user["email"])
    refresh_token_val = generate_refresh_token()
    refresh_tokens[refresh_token_val] = {
        "user_id": user["id"],
        "expires_at": datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
    }
    
    del authorization_codes[code]
    
    return {
        "access_token": access_token,
        "refresh_token": refresh_token_val,
        "expires_at": expires_at,
        "user_id": user["id"],
        "user_email": user["email"]
    }

@app.get("/health")
async def health():
    return {"status": "healthy", "service": "Continue Auth Service"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)