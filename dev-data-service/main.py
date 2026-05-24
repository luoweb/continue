"""
Continue Dev Data Service
A backend service for collecting and managing development data from Continue
"""
from fastapi import FastAPI, HTTPException, Depends, Header, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import datetime
from dotenv import load_dotenv
import os
import json
import uvicorn

import database

load_dotenv()

app = FastAPI(
    title="Continue Dev Data Service",
    description="Backend service for collecting and managing Continue development data",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

API_KEY = os.getenv("API_KEY", "")
REQUIRE_AUTH = os.getenv("REQUIRE_AUTH", "false").lower() == "true"


async def verify_api_key(authorization: Optional[str] = Header(None)):
    """Verify API key if authentication is required"""
    if not REQUIRE_AUTH:
        return True
    
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing or invalid authorization header")
    
    token = authorization[7:]
    if token != API_KEY:
        raise HTTPException(status_code=401, detail="Invalid API key")
    
    return True


class DevDataRequest(BaseModel):
    """Request model for submitting dev data"""
    name: str = Field(..., description="Event name")
    data: Dict[str, Any] = Field(..., description="Event data payload")
    schema: str = Field(..., description="Schema version")
    level: Optional[str] = Field(default="all", description="Data level (all/noCode)")
    profileId: Optional[str] = Field(default=None, description="Profile ID")


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


@app.on_event("startup")
async def startup_event():
    """Initialize database on startup"""
    database.init_db()
    print("Dev Data Service started successfully")


@app.get("/health")
async def health():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "Continue Dev Data Service",
        "timestamp": datetime.utcnow().isoformat()
    }


@app.post("/api/v1/data", response_model=DevDataResponse)
async def submit_dev_data(
    request: DevDataRequest,
    _: bool = Depends(verify_api_key)
):
    """
    Submit development data
    
    This endpoint accepts dev data events from Continue clients and stores them
    """
    try:
        event_data_str = json.dumps(request.data)
        
        record_id = database.insert_dev_data(
            event_name=request.name,
            schema_version=request.schema,
            data_level=request.level,
            event_data=event_data_str,
            user_id=None,
            profile_id=request.profileId
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
    _: bool = Depends(verify_api_key)
):
    """
    Query development data with filters
    
    Supports filtering by event name, user ID, and date ranges
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
    _: bool = Depends(verify_api_key)
):
    """
    Get statistics about collected dev data
    
    Returns total records, breakdown by event type, and last 7 days activity
    """
    try:
        stats = database.get_stats()
        return StatsResponse(**stats)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get statistics: {str(e)}")


@app.delete("/api/v1/data/old/{days}")
async def delete_old_data(
    days: int = Query(90, ge=1, description="Delete records older than this many days"),
    _: bool = Depends(verify_api_key)
):
    """
    Delete old development data
    
    Use this to clean up old records and manage database size
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
    _: bool = Depends(verify_api_key)
):
    """
    Get list of supported event types
    
    Based on Continue's dev data schema
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
