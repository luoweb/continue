from fastapi import FastAPI, HTTPException, Depends
from fastapi.responses import RedirectResponse, HTMLResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr
from datetime import datetime, timedelta
from jose import JWTError, jwt
from passlib.context import CryptContext
import uuid
import os
from dotenv import load_dotenv

import database

load_dotenv()

app = FastAPI(title="Continue Auth Service", version="2.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

SECRET_KEY = os.getenv("SECRET_KEY", "your-secret-key-here-must-be-at-least-32-chars")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60
REFRESH_TOKEN_EXPIRE_DAYS = 7

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

API_BASE = os.getenv("API_BASE", "http://localhost:8000")
CLIENT_ID = os.getenv("CLIENT_ID", "continue-cli")
CLIENT_SECRET = os.getenv("CLIENT_SECRET", "")
REDIRECT_URI = os.getenv("REDIRECT_URI", "http://localhost:8000/auth/callback")

class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    expires_at: int
    user_id: str
    user_email: str

class DeviceAuthorizationResponse(BaseModel):
    device_code: str
    user_code: str
    verification_uri: str
    verification_uri_complete: str
    expires_in: int
    interval: int

class UserInfo(BaseModel):
    id: str
    email: str
    first_name: str
    last_name: str
    organization_id: str | None = None

class TokenRefreshRequest(BaseModel):
    refreshToken: str

class RegisterRequest(BaseModel):
    email: EmailStr
    password: str
    first_name: str = ""
    last_name: str = ""

class LoginRequest(BaseModel):
    email: EmailStr
    password: str

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password):
    return pwd_context.hash(password)

def create_access_token(data: dict, expires_delta: timedelta | None = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt, int(expire.timestamp())

def decode_access_token(token: str):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except JWTError:
        return None

def generate_refresh_token():
    return str(uuid.uuid4())

def generate_user_code():
    return ''.join([str(uuid.uuid4()).replace('-', '')[:4].upper() for _ in range(3)]).join('-')

@app.post("/auth/register", response_model=TokenResponse)
async def register(request: RegisterRequest):
    user = database.get_user_by_email(request.email)
    if user:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    hashed_password = get_password_hash(request.password)
    user_id = str(uuid.uuid4())
    
    success = database.create_user(
        user_id=user_id,
        email=request.email,
        hashed_password=hashed_password,
        first_name=request.first_name,
        last_name=request.last_name
    )
    
    if not success:
        raise HTTPException(status_code=500, detail="Failed to create user")
    
    access_token, expires_at = create_access_token(
        data={"sub": user_id, "email": request.email},
        expires_delta=timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    )
    
    refresh_token = generate_refresh_token()
    database.create_refresh_token(
        token_id=str(uuid.uuid4()),
        user_id=user_id,
        token=refresh_token,
        expires_at=datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
    )
    
    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        expires_at=expires_at,
        user_id=user_id,
        user_email=request.email
    )

@app.post("/auth/login", response_model=TokenResponse)
async def login(request: LoginRequest):
    user = database.get_user_by_email(request.email)
    if not user or not verify_password(request.password, user["hashed_password"]):
        raise HTTPException(status_code=401, detail="Invalid email or password")
    
    access_token, expires_at = create_access_token(
        data={"sub": user["id"], "email": user["email"]},
        expires_delta=timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    )
    
    refresh_token = generate_refresh_token()
    database.create_refresh_token(
        token_id=str(uuid.uuid4()),
        user_id=user["id"],
        token=refresh_token,
        expires_at=datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
    )
    
    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        expires_at=expires_at,
        user_id=user["id"],
        user_email=user["email"]
    )

@app.get("/auth/authorize")
async def authorize(client_id: str, redirect_uri: str = None, state: str = None):
    if client_id != CLIENT_ID:
        raise HTTPException(status_code=400, detail="Invalid client_id")
    
    redirect = redirect_uri or REDIRECT_URI
    
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
async def token_endpoint(
    grant_type: str,
    email: str = None,
    password: str = None,
    code: str = None,
    redirect_uri: str = None,
    refresh_token: str = None,
    device_code: str = None,
    client_id: str = None
):
    if client_id != CLIENT_ID:
        raise HTTPException(status_code=400, detail="Invalid client_id")
    
    if grant_type == "password":
        if not email or not password:
            raise HTTPException(status_code=400, detail="email and password are required")
        
        user = database.get_user_by_email(email)
        if not user or not verify_password(password, user["hashed_password"]):
            raise HTTPException(status_code=401, detail="Invalid email or password")
        
        auth_code = str(uuid.uuid4())
        database.create_authorization_code(
            code_id=str(uuid.uuid4()),
            code=auth_code,
            user_id=user["id"],
            client_id=client_id,
            redirect_uri=redirect_uri or REDIRECT_URI,
            state=None,
            expires_at=datetime.utcnow() + timedelta(minutes=5)
        )
        
        return {"authorization_code": auth_code}
    
    elif grant_type == "authorization_code":
        if not code:
            raise HTTPException(status_code=400, detail="code is required")
        
        auth_code_data = database.get_authorization_code(code)
        if not auth_code_data:
            raise HTTPException(status_code=400, detail="Invalid authorization code")
        
        if datetime.fromisoformat(auth_code_data["expires_at"]) < datetime.utcnow():
            raise HTTPException(status_code=400, detail="Authorization code expired")
        
        user = database.get_user_by_id(auth_code_data["user_id"])
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
        database.delete_authorization_code(code)
        
        access_token, expires_at = create_access_token(
            data={"sub": user["id"], "email": user["email"]},
            expires_delta=timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
        )
        
        refresh_token_val = generate_refresh_token()
        database.create_refresh_token(
            token_id=str(uuid.uuid4()),
            user_id=user["id"],
            token=refresh_token_val,
            expires_at=datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
        )
        
        return {
            "access_token": access_token,
            "refresh_token": refresh_token_val,
            "user": {"id": user["id"], "email": user["email"]},
            "expires_in": ACCESS_TOKEN_EXPIRE_MINUTES * 60,
            "issued_at": int(datetime.utcnow().timestamp())
        }
    
    elif grant_type == "refresh_token":
        if not refresh_token:
            raise HTTPException(status_code=400, detail="refresh_token is required")
        
        token_data = database.get_refresh_token(refresh_token)
        if not token_data:
            raise HTTPException(status_code=401, detail="Invalid refresh token")
        
        if datetime.fromisoformat(token_data["expires_at"]) < datetime.utcnow():
            database.delete_refresh_token(refresh_token)
            raise HTTPException(status_code=401, detail="Refresh token expired")
        
        user = database.get_user_by_id(token_data["user_id"])
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
        database.delete_refresh_token(refresh_token)
        
        access_token, expires_at = create_access_token(
            data={"sub": user["id"], "email": user["email"]},
            expires_delta=timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
        )
        
        new_refresh_token = generate_refresh_token()
        database.create_refresh_token(
            token_id=str(uuid.uuid4()),
            user_id=user["id"],
            token=new_refresh_token,
            expires_at=datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
        )
        
        return {
            "access_token": access_token,
            "refresh_token": new_refresh_token,
            "user": {"id": user["id"], "email": user["email"]},
            "expires_in": ACCESS_TOKEN_EXPIRE_MINUTES * 60,
            "issued_at": int(datetime.utcnow().timestamp())
        }
    
    elif grant_type == "urn:ietf:params:oauth:grant-type:device_code":
        if not device_code:
            raise HTTPException(status_code=400, detail="device_code is required")
        
        device_code_data = database.get_device_code(device_code)
        if not device_code_data:
            raise HTTPException(status_code=400, detail="Invalid device code")
        
        if datetime.fromisoformat(device_code_data["expires_at"]) < datetime.utcnow():
            raise HTTPException(status_code=400, detail="Device code expired", headers={"error": "expired_token"})
        
        if device_code_data["status"] == "pending":
            raise HTTPException(status_code=400, detail="Authorization pending", headers={"error": "authorization_pending"})
        
        if device_code_data["status"] == "denied":
            raise HTTPException(status_code=400, detail="Access denied", headers={"error": "access_denied"})
        
        if not device_code_data["user_id"]:
            raise HTTPException(status_code=400, detail="User not assigned")
        
        user = database.get_user_by_id(device_code_data["user_id"])
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
        access_token, expires_at = create_access_token(
            data={"sub": user["id"], "email": user["email"]},
            expires_delta=timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
        )
        
        refresh_token_val = generate_refresh_token()
        database.create_refresh_token(
            token_id=str(uuid.uuid4()),
            user_id=user["id"],
            token=refresh_token_val,
            expires_at=datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
        )
        
        return {
            "access_token": access_token,
            "refresh_token": refresh_token_val,
            "user": {"id": user["id"], "email": user["email"]},
            "expires_in": ACCESS_TOKEN_EXPIRE_MINUTES * 60,
            "issued_at": int(datetime.utcnow().timestamp())
        }
    
    else:
        raise HTTPException(status_code=400, detail=f"Unsupported grant_type: {grant_type}")

@app.post("/auth/refresh", response_model=TokenResponse)
async def refresh_token(request: TokenRefreshRequest):
    token_data = database.get_refresh_token(request.refreshToken)
    if not token_data:
        raise HTTPException(status_code=401, detail="Invalid refresh token")
    
    if datetime.fromisoformat(token_data["expires_at"]) < datetime.utcnow():
        database.delete_refresh_token(request.refreshToken)
        raise HTTPException(status_code=401, detail="Refresh token expired")
    
    user = database.get_user_by_id(token_data["user_id"])
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    database.delete_refresh_token(request.refreshToken)
    
    access_token, expires_at = create_access_token(
        data={"sub": user["id"], "email": user["email"]},
        expires_delta=timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    )
    
    new_refresh_token = generate_refresh_token()
    database.create_refresh_token(
        token_id=str(uuid.uuid4()),
        user_id=user["id"],
        token=new_refresh_token,
        expires_at=datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
    )
    
    return TokenResponse(
        access_token=access_token,
        refresh_token=new_refresh_token,
        expires_at=expires_at,
        user_id=user["id"],
        user_email=user["email"]
    )

@app.post("/user_management/authorize/device", response_model=DeviceAuthorizationResponse)
async def device_authorization(client_id: str = None):
    if not client_id or client_id != CLIENT_ID:
        raise HTTPException(status_code=400, detail="Invalid client_id")
    
    device_code = str(uuid.uuid4())
    user_code = generate_user_code()
    expires_at = datetime.utcnow() + timedelta(minutes=10)
    
    database.create_device_code(
        device_code_id=str(uuid.uuid4()),
        user_code=user_code,
        device_code=device_code,
        client_id=client_id,
        expires_at=expires_at,
        interval=5
    )
    
    verification_uri = f"{API_BASE}/auth/device"
    verification_uri_complete = f"{verification_uri}?user_code={user_code}"
    
    return DeviceAuthorizationResponse(
        device_code=device_code,
        user_code=user_code,
        verification_uri=verification_uri,
        verification_uri_complete=verification_uri_complete,
        expires_in=600,
        interval=5
    )

@app.get("/auth/device")
async def device_login_page(user_code: str = None):
    if not user_code:
        return HTMLResponse(content="""
        <!DOCTYPE html>
        <html>
        <head>
            <title>Device Authorization</title>
        </head>
        <body>
            <h1>Device Authorization</h1>
            <p>Please provide a user code</p>
        </body>
        </html>
        """)
    
    device_code_data = database.get_device_code_by_user_code(user_code)
    if not device_code_data:
        return HTMLResponse(content="""
        <!DOCTYPE html>
        <html>
        <head>
            <title>Device Authorization</title>
            <style>
                body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 400px; margin: 0 auto; padding: 20px; }
                .form-group { margin-bottom: 15px; }
                label { display: block; margin-bottom: 5px; }
                input { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; }
                button { width: 100%; padding: 12px; background: #6366f1; color: white; border: none; border-radius: 4px; cursor: pointer; }
                button:hover { background: #4f46e5; }
                .error { color: red; margin-top: 10px; }
            </style>
        </head>
        <body>
            <h1>Device Authorization</h1>
            <p>Invalid user code</p>
        </body>
        </html>
        """)
    
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

class DeviceAuthorizeRequest(BaseModel):
    user_code: str
    email: EmailStr
    password: str

@app.post("/auth/device/authorize")
async def authorize_device(request: DeviceAuthorizeRequest):
    device_code_data = database.get_device_code_by_user_code(request.user_code)
    if not device_code_data:
        raise HTTPException(status_code=400, detail="Invalid user code")
    
    if datetime.fromisoformat(device_code_data["expires_at"]) < datetime.utcnow():
        raise HTTPException(status_code=400, detail="User code expired")
    
    user = database.get_user_by_email(request.email)
    if not user or not verify_password(request.password, user["hashed_password"]):
        raise HTTPException(status_code=401, detail="Invalid email or password")
    
    database.update_device_code_status(
        device_code=device_code_data["device_code"],
        user_id=user["id"],
        status="authorized"
    )
    
    return {"message": "Device authorized successfully"}

@app.post("/user_management/authenticate")
async def authenticate(
    grant_type: str,
    device_code: str = None,
    client_id: str = None,
    refresh_token: str = None,
    code: str = None,
    redirect_uri: str = None
):
    return await token_endpoint(
        grant_type=grant_type,
        device_code=device_code,
        client_id=client_id,
        refresh_token=refresh_token,
        code=code,
        redirect_uri=redirect_uri
    )

@app.get("/auth/userinfo", response_model=UserInfo)
async def userinfo(access_token: str):
    payload = decode_access_token(access_token)
    if not payload:
        raise HTTPException(status_code=401, detail="Invalid access token")
    
    user = database.get_user_by_id(payload["sub"])
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    return UserInfo(
        id=user["id"],
        email=user["email"],
        first_name=user["first_name"] or "",
        last_name=user["last_name"] or "",
        organization_id=user["organization_id"]
    )

@app.get("/user_management/users/me", response_model=UserInfo)
async def user_me(access_token: str = None, authorization: str = None):
    token = access_token
    if authorization and authorization.startswith("Bearer "):
        token = authorization[7:]
    
    if not token:
        raise HTTPException(status_code=400, detail="access_token is required")
    
    payload = decode_access_token(token)
    if not payload:
        raise HTTPException(status_code=401, detail="Invalid access token")
    
    user = database.get_user_by_id(payload["sub"])
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    return UserInfo(
        id=user["id"],
        email=user["email"],
        first_name=user["first_name"] or "",
        last_name=user["last_name"] or "",
        organization_id=user["organization_id"]
    )

@app.get("/auth/scope")
async def auth_scope(authorization: str = None):
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=400, detail="Authorization header required")
    
    access_token = authorization[7:]
    payload = decode_access_token(access_token)
    if not payload:
        raise HTTPException(status_code=401, detail="Invalid access token")
    
    user = database.get_user_by_id(payload["sub"])
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    return {"organizationId": user["organization_id"]}

@app.get("/auth/callback")
async def callback(code: str, redirect_uri: str = None, state: str = None):
    auth_code_data = database.get_authorization_code(code)
    if not auth_code_data:
        raise HTTPException(status_code=400, detail="Invalid authorization code")
    
    user = database.get_user_by_id(auth_code_data["user_id"])
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    access_token, expires_at = create_access_token(
        data={"sub": user["id"], "email": user["email"]},
        expires_delta=timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    )
    
    refresh_token_val = generate_refresh_token()
    database.create_refresh_token(
        token_id=str(uuid.uuid4()),
        user_id=user["id"],
        token=refresh_token_val,
        expires_at=datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
    )
    
    database.delete_authorization_code(code)
    
    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token_val,
        expires_at=expires_at,
        user_id=user["id"],
        user_email=user["email"]
    )

@app.get("/health")
async def health():
    return {"status": "healthy", "service": "Continue Auth Service"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)