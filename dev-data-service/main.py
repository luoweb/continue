"""
Cowork Dev Data Service
A backend service for collecting and managing development data from Cowork
"""
from fastapi import FastAPI, HTTPException, Depends, Header, Query, Path, Security
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import datetime, timedelta
from dotenv import load_dotenv
import os
import json
import hashlib
import secrets
import uvicorn

import database

load_dotenv()

app = FastAPI(
    title="Cowork Dev Data Service",
    description="Backend service for collecting and managing Cowork development data",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

REQUIRE_AUTH = os.getenv("REQUIRE_AUTH", "false").lower() == "true"

# Token storage (in production, use a database)
_tokens_db: Dict[str, Dict[str, Any]] = {}


class TokenManager:
    """Token management system"""

    @staticmethod
    def generate_token(
        name: str,
        expires_days: int = 30,
        max_requests: Optional[int] = None
    ) -> Dict[str, Any]:
        """Generate a new API token"""
        token = secrets.token_urlsafe(32)
        token_hash = hashlib.sha256(token.encode()).hexdigest()

        token_data = {
            "name": name,
            "token_hash": token_hash,
            "created_at": datetime.utcnow().isoformat(),
            "expires_at": (datetime.utcnow() + timedelta(days=expires_days)).isoformat(),
            "max_requests": max_requests,
            "request_count": 0,
            "is_active": True
        }

        _tokens_db[token_hash] = token_data

        return {
            "token": token,
            "name": name,
            "expires_at": token_data["expires_at"],
            "max_requests": max_requests,
            "message": "Save this token securely. It will not be shown again."
        }

    @staticmethod
    def verify_token(token: str) -> Dict[str, Any]:
        """Verify token and return token info"""
        token_hash = hashlib.sha256(token.encode()).hexdigest()

        if token_hash not in _tokens_db:
            raise HTTPException(
                status_code=401,
                detail="Invalid token"
            )

        token_data = _tokens_db[token_hash]

        if not token_data["is_active"]:
            raise HTTPException(
                status_code=401,
                detail="Token has been revoked"
            )

        expires_at = datetime.fromisoformat(token_data["expires_at"])
        if datetime.utcnow() > expires_at:
            raise HTTPException(
                status_code=401,
                detail="Token has expired"
            )

        if token_data["max_requests"]:
            if token_data["request_count"] >= token_data["max_requests"]:
                raise HTTPException(
                    status_code=401,
                    detail="Token request limit exceeded"
                )

        token_data["request_count"] += 1

        return token_data

    @staticmethod
    def revoke_token(token: str) -> bool:
        """Revoke a token"""
        token_hash = hashlib.sha256(token.encode()).hexdigest()

        if token_hash not in _tokens_db:
            raise HTTPException(
                status_code=404,
                detail="Token not found"
            )

        _tokens_db[token_hash]["is_active"] = False
        return True

    @staticmethod
    def list_tokens() -> List[Dict[str, Any]]:
        """List all tokens (without exposing the actual tokens)"""
        return [
            {
                "name": data["name"],
                "created_at": data["created_at"],
                "expires_at": data["expires_at"],
                "max_requests": data["max_requests"],
                "request_count": data["request_count"],
                "is_active": data["is_active"]
            }
            for data in _tokens_db.values()
        ]

    @staticmethod
    def delete_expired_tokens():
        """Delete expired tokens"""
        now = datetime.utcnow()
        expired_hashes = []

        for token_hash, data in _tokens_db.items():
            expires_at = datetime.fromisoformat(data["expires_at"])
            if now > expires_at:
                expired_hashes.append(token_hash)

        for token_hash in expired_hashes:
            del _tokens_db[token_hash]

        return len(expired_hashes)


token_manager = TokenManager()


async def verify_api_key(authorization: Optional[str] = Header(None)):
    """Verify API key if authentication is required"""
    if not REQUIRE_AUTH:
        return True

    if not authorization:
        raise HTTPException(
            status_code=401,
            detail="Authorization header is required"
        )

    if not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=401,
            detail="Invalid authorization header format. Use: Bearer <token>"
        )

    token = authorization[7:]

    try:
        token_data = token_manager.verify_token(token)
        return token_data
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=401,
            detail=f"Token verification failed: {str(e)}"
        )


class DevDataRequest(BaseModel):
    """Request model for submitting dev data"""
    name: str = Field(..., description="Event name")
    data: Dict[str, Any] = Field(..., description="Event data payload")
    schema_version: str = Field(..., alias="schema", description="Schema version")
    level: Optional[str] = Field(default="all", alias="level", description="Data level (all/noCode)")
    profile_id: Optional[str] = Field(default=None, alias="profileId", description="Profile ID")

    class Config:
        populate_by_name = True


class DevDataResponse(BaseModel):
    """Response model for dev data submission"""
    success: bool
    id: Optional[int] = None
    message: str


class StatsResponse(BaseModel):
    """Response model for statistics"""
    total_records: int
    by_event: Dict[str, int]
    last_7_days: Dict[str, int]


class DevDataRecord(BaseModel):
    """Model for a single dev data record"""
    id: int
    event_name: str
    schema_version: str
    data_level: str
    user_id: Optional[str]
    profile_id: Optional[str]
    event_data: str
    created_at: str


class QueryResponse(BaseModel):
    """Response model for query results"""
    records: List[DevDataRecord]
    total: int


class TokenCreateRequest(BaseModel):
    """Request model for creating a new token"""
    name: str = Field(..., description="Token name (e.g., 'production', 'development')")
    expires_days: int = Field(default=30, ge=1, le=365, description="Token expiration in days")
    max_requests: Optional[int] = Field(default=None, ge=1, description="Maximum number of requests (unlimited if None)")


class TokenResponse(BaseModel):
    """Response model for token creation"""
    token: str
    name: str
    expires_at: str
    max_requests: Optional[int]
    message: str


@app.on_event("startup")
async def startup_event():
    """Initialize database on startup"""
    database.init_db()
    deleted_count = token_manager.delete_expired_tokens()
    print(f"Dev Data Service started successfully. Cleaned up {deleted_count} expired tokens.")


@app.get("/health")
async def health():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "Cowork Dev Data Service",
        "timestamp": datetime.utcnow().isoformat(),
        "auth_enabled": REQUIRE_AUTH
    }


@app.post("/api/v1/tokens", response_model=TokenResponse)
async def create_token(request: TokenCreateRequest):
    """
    Create a new API token

    Save the returned token securely. It will not be shown again.
    """
    if not REQUIRE_AUTH:
        raise HTTPException(
            status_code=403,
            detail="Authentication is disabled. Set REQUIRE_AUTH=true to enable token management."
        )

    token_info = token_manager.generate_token(
        name=request.name,
        expires_days=request.expires_days,
        max_requests=request.max_requests
    )

    return TokenResponse(**token_info)


@app.get("/api/v1/tokens")
async def list_tokens(_: Dict[str, Any] = Depends(verify_api_key)):
    """
    List all API tokens

    Returns token metadata without exposing actual tokens.
    """
    if not REQUIRE_AUTH:
        raise HTTPException(
            status_code=403,
            detail="Authentication is disabled"
        )

    return {
        "tokens": token_manager.list_tokens(),
        "total": len(_tokens_db)
    }


@app.delete("/api/v1/tokens/{token_name}")
async def revoke_token(
    token_name: str,
    authorization: str = Header(..., description="Current API token")
):
    """
    Revoke a token by name

    Requires a valid active token to perform this action.
    """
    if not REQUIRE_AUTH:
        raise HTTPException(
            status_code=403,
            detail="Authentication is disabled"
        )

    token_manager.verify_token(authorization[7:])

    for token_hash, data in _tokens_db.items():
        if data["name"] == token_name:
            token_manager.revoke_token(
                list(_tokens_db.keys())[list(_tokens_db.keys()).index(token_hash)]
            )
            return {
                "success": True,
                "message": f"Token '{token_name}' has been revoked"
            }

    raise HTTPException(
        status_code=404,
        detail=f"Token '{token_name}' not found"
    )


@app.post("/api/v1/data", response_model=DevDataResponse)
async def submit_dev_data(
    request: DevDataRequest,
    _: Dict[str, Any] = Depends(verify_api_key)
):
    """
    Submit development data

    This endpoint accepts dev data events from Cowork clients and stores them.
    """
    try:
        event_data_str = json.dumps(request.data)

        record_id = database.insert_dev_data(
            event_name=request.name,
            schema_version=request.schema_version,
            data_level=request.level,
            event_data=event_data_str,
            user_id=None,
            profile_id=request.profile_id
        )

        return DevDataResponse(
            success=True,
            id=record_id,
            message="Data stored successfully"
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to store data: {str(e)}")


@app.get("/api/v1/data", response_model=QueryResponse)
async def query_dev_data(
    event_name: Optional[str] = Query(None, description="Filter by event name"),
    user_id: Optional[str] = Query(None, description="Filter by user ID"),
    start_date: Optional[datetime] = Query(None, description="Filter by start date"),
    end_date: Optional[datetime] = Query(None, description="Filter by end date"),
    limit: int = Query(100, ge=1, le=1000, description="Number of records to return"),
    offset: int = Query(0, ge=0, description="Offset for pagination"),
    _: Dict[str, Any] = Depends(verify_api_key)
):
    """
    Query development data with filters

    Supports filtering by event name, user ID, and date ranges.
    """
    try:
        records = database.get_dev_data(
            event_name=event_name,
            user_id=user_id,
            start_date=start_date,
            end_date=end_date,
            limit=limit,
            offset=offset
        )

        record_models = [
            DevDataRecord(
                id=r["id"],
                event_name=r["event_name"],
                schema_version=r["schema_version"],
                data_level=r["data_level"],
                user_id=r["user_id"],
                profile_id=r["profile_id"],
                event_data=r["event_data"],
                created_at=r["created_at"]
            )
            for r in records
        ]

        return QueryResponse(
            records=record_models,
            total=len(record_models)
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to query data: {str(e)}")


@app.get("/api/v1/stats", response_model=StatsResponse)
async def get_statistics(
    _: Dict[str, Any] = Depends(verify_api_key)
):
    """
    Get statistics about collected dev data

    Returns total records, breakdown by event type, and last 7 days activity.
    """
    try:
        stats = database.get_stats()
        return StatsResponse(**stats)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get statistics: {str(e)}")


@app.delete("/api/v1/data/old/{days}")
async def delete_old_data(
    days: int = Path(..., ge=1, description="Delete records older than this many days"),
    _: Dict[str, Any] = Depends(verify_api_key)
):
    """
    Delete old development data

    Use this to clean up old records and manage database size.
    """
    try:
        deleted_count = database.delete_old_records(days=days)
        return {
            "success": True,
            "deleted_count": deleted_count,
            "message": f"Deleted {deleted_count} records older than {days} days"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to delete old data: {str(e)}")


@app.get("/api/v1/events")
async def get_event_types(
    _: Dict[str, Any] = Depends(verify_api_key)
):
    """
    Get list of supported event types

    Based on Cowork's dev data schema.
    """
    event_types = [
        "tokensGenerated",
        "chatInteraction",
        "editInteraction",
        "editOutcome",
        "nextEditOutcome",
        "nextEditWithHistory",
        "toolUsage",
        "autocomplete",
        "chatFeedback",
        "quickEdit"
    ]

    return {
        "event_types": event_types,
        "schema_versions": ["0.1.0", "0.2.0"]
    }


if __name__ == "__main__":
    host = os.getenv("HOST", "0.0.0.0")
    port = int(os.getenv("PORT", "8001"))
    uvicorn.run(app, host=host, port=port)
