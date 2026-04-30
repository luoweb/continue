from fastapi import FastAPI, HTTPException
from fastapi.responses import RedirectResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import requests
import os
from dotenv import load_dotenv
import time

load_dotenv()

app = FastAPI(title="Continue Auth Service", version="1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

WORKOS_API_KEY = os.getenv("WORKOS_API_KEY")
WORKOS_CLIENT_ID = os.getenv("WORKOS_CLIENT_ID")
WORKOS_REDIRECT_URI = os.getenv("WORKOS_REDIRECT_URI", "http://localhost:8000/auth/callback")
WORKOS_API_URL = os.getenv("WORKOS_API_URL", "https://api.workos.com")
API_BASE = os.getenv("API_BASE", "http://localhost:8000")

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

@app.get("/auth/authorize")
async def authorize(redirect_uri: str = None):
    """重定向到 WorkOS 授权页面 (Authorization Code Flow)"""
    if not WORKOS_CLIENT_ID:
        raise HTTPException(status_code=500, detail="WORKOS_CLIENT_ID not configured")
    
    redirect = redirect_uri or WORKOS_REDIRECT_URI
    
    auth_url = f"{WORKOS_API_URL}/user_management/authorize"
    params = {
        "response_type": "code",
        "client_id": WORKOS_CLIENT_ID,
        "redirect_uri": redirect,
        "scope": "openid email profile",
        "provider": "authkit",
    }
    
    url = requests.Request("GET", auth_url, params=params).prepare().url
    return RedirectResponse(url=str(url))

@app.get("/auth/callback")
async def callback(code: str, redirect_uri: str = None):
    """处理 WorkOS 回调，交换授权码获取令牌"""
    if not WORKOS_API_KEY or not WORKOS_CLIENT_ID:
        raise HTTPException(status_code=500, detail="WorkOS credentials not configured")
    
    redirect = redirect_uri or WORKOS_REDIRECT_URI
    
    token_url = f"{WORKOS_API_URL}/user_management/authenticate"
    headers = {
        "Authorization": f"Bearer {WORKOS_API_KEY}",
        "Content-Type": "application/x-www-form-urlencoded",
    }
    data = {
        "grant_type": "authorization_code",
        "client_id": WORKOS_CLIENT_ID,
        "redirect_uri": redirect,
        "code": code,
    }
    
    try:
        response = requests.post(token_url, headers=headers, data=data)
        response.raise_for_status()
        token_data = response.json()
        
        user_info = await get_user_info(token_data["access_token"])
        
        return TokenResponse(
            access_token=token_data["access_token"],
            refresh_token=token_data.get("refresh_token", ""),
            expires_at=token_data.get("expires_in", 3600) + int(time.time()),
            user_id=user_info.id,
            user_email=user_info.email,
        )
    except requests.exceptions.RequestException as e:
        raise HTTPException(status_code=400, detail=f"Failed to exchange token: {str(e)}")

@app.post("/auth/refresh", response_model=TokenResponse)
async def refresh_token(request: TokenRefreshRequest):
    """使用刷新令牌获取新的访问令牌"""
    if not WORKOS_API_KEY or not WORKOS_CLIENT_ID:
        raise HTTPException(status_code=500, detail="WorkOS credentials not configured")
    
    token_url = f"{WORKOS_API_URL}/user_management/authenticate"
    headers = {
        "Authorization": f"Bearer {WORKOS_API_KEY}",
        "Content-Type": "application/x-www-form-urlencoded",
    }
    data = {
        "grant_type": "refresh_token",
        "client_id": WORKOS_CLIENT_ID,
        "refresh_token": request.refreshToken,
    }
    
    try:
        response = requests.post(token_url, headers=headers, data=data)
        response.raise_for_status()
        token_data = response.json()
        
        user_info = await get_user_info(token_data["access_token"])
        
        return TokenResponse(
            access_token=token_data["access_token"],
            refresh_token=token_data.get("refresh_token", request.refreshToken),
            expires_at=token_data.get("expires_in", 3600) + int(time.time()),
            user_id=user_info.id,
            user_email=user_info.email,
        )
    except requests.exceptions.RequestException as e:
        raise HTTPException(status_code=400, detail=f"Failed to refresh token: {str(e)}")

@app.post("/user_management/authorize/device", response_model=DeviceAuthorizationResponse)
async def device_authorization():
    """请求设备授权 (Device Authorization Flow)"""
    if not WORKOS_API_KEY or not WORKOS_CLIENT_ID:
        raise HTTPException(status_code=500, detail="WorkOS credentials not configured")
    
    device_auth_url = f"{WORKOS_API_URL}/user_management/authorize/device"
    headers = {
        "Authorization": f"Bearer {WORKOS_API_KEY}",
        "Content-Type": "application/x-www-form-urlencoded",
    }
    data = {
        "client_id": WORKOS_CLIENT_ID,
        "screen_hint": "sign-up",
    }
    
    try:
        response = requests.post(device_auth_url, headers=headers, data=data)
        response.raise_for_status()
        device_data = response.json()
        
        return DeviceAuthorizationResponse(
            device_code=device_data["device_code"],
            user_code=device_data["user_code"],
            verification_uri=device_data["verification_uri"],
            verification_uri_complete=device_data["verification_uri_complete"],
            expires_in=device_data["expires_in"],
            interval=device_data["interval"],
        )
    except requests.exceptions.RequestException as e:
        raise HTTPException(status_code=400, detail=f"Device authorization error: {str(e)}")

@app.post("/user_management/authenticate")
async def authenticate(grant_type: str, device_code: str = None, client_id: str = None, 
                      refresh_token: str = None, code: str = None, redirect_uri: str = None):
    """认证端点，支持多种 grant_type"""
    if not WORKOS_API_KEY:
        raise HTTPException(status_code=500, detail="WorkOS API key not configured")
    
    token_url = f"{WORKOS_API_URL}/user_management/authenticate"
    headers = {
        "Authorization": f"Bearer {WORKOS_API_KEY}",
        "Content-Type": "application/x-www-form-urlencoded",
    }
    
    data = {"grant_type": grant_type}
    
    if grant_type == "urn:ietf:params:oauth:grant-type:device_code":
        if not device_code or not client_id:
            raise HTTPException(status_code=400, detail="device_code and client_id are required")
        data["device_code"] = device_code
        data["client_id"] = client_id
    elif grant_type == "refresh_token":
        if not refresh_token or not client_id:
            raise HTTPException(status_code=400, detail="refresh_token and client_id are required")
        data["refresh_token"] = refresh_token
        data["client_id"] = client_id
    elif grant_type == "authorization_code":
        if not code or not client_id or not redirect_uri:
            raise HTTPException(status_code=400, detail="code, client_id and redirect_uri are required")
        data["code"] = code
        data["client_id"] = client_id
        data["redirect_uri"] = redirect_uri
    else:
        raise HTTPException(status_code=400, detail=f"Unsupported grant_type: {grant_type}")
    
    try:
        response = requests.post(token_url, headers=headers, data=data)
        
        if not response.ok:
            error_data = response.json() if response.content else {}
            return {"error": error_data.get("error", "unknown_error"), "error_description": error_data.get("error_description", "")}
        
        token_data = response.json()
        user_info = await get_user_info(token_data["access_token"])
        
        return {
            "access_token": token_data["access_token"],
            "refresh_token": token_data.get("refresh_token", ""),
            "user": {
                "id": user_info.id,
                "email": user_info.email,
            },
            "expires_in": token_data.get("expires_in", 3600),
            "issued_at": int(time.time()),
        }
    except requests.exceptions.RequestException as e:
        raise HTTPException(status_code=400, detail=f"Authentication error: {str(e)}")

@app.get("/auth/userinfo", response_model=UserInfo)
async def userinfo(access_token: str):
    """获取用户信息"""
    return await get_user_info(access_token)

@app.get("/user_management/users/me", response_model=UserInfo)
async def user_me(access_token: str = None, authorization: str = None):
    """获取当前用户信息 (WorkOS 兼容接口)"""
    token = access_token
    if authorization and authorization.startswith("Bearer "):
        token = authorization[7:]
    
    if not token:
        raise HTTPException(status_code=400, detail="access_token is required")
    
    return await get_user_info(token)

async def get_user_info(access_token: str) -> UserInfo:
    """从 WorkOS 获取用户信息"""
    user_url = f"{WORKOS_API_URL}/user_management/users/me"
    headers = {"Authorization": f"Bearer {access_token}"}
    
    try:
        response = requests.get(user_url, headers=headers)
        response.raise_for_status()
        user_data = response.json()
        
        return UserInfo(
            id=user_data["id"],
            email=user_data["email"],
            first_name=user_data.get("first_name", ""),
            last_name=user_data.get("last_name", ""),
            organization_id=user_data.get("organization_id"),
        )
    except requests.exceptions.RequestException as e:
        raise HTTPException(status_code=400, detail=f"Failed to get user info: {str(e)}")

@app.get("/auth/scope")
async def auth_scope(authorization: str = None):
    """获取认证范围信息"""
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=400, detail="Authorization header required")
    
    access_token = authorization[7:]
    
    try:
        user_info = await get_user_info(access_token)
        return {"organizationId": user_info.organization_id}
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Failed to get scope: {str(e)}")

@app.get("/health")
async def health():
    """健康检查"""
    return {"status": "healthy", "service": "Continue Auth Service"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)