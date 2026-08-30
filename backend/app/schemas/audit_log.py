from pydantic import BaseModel, Field, ConfigDict
from datetime import datetime
from typing import Optional, Dict, Any

class AuditLogBase(BaseModel):
    user_id: int = Field(..., gt=0)
    action: str = Field(..., min_length=1, max_length=100)
    entity_type: str = Field(..., min_length=1, max_length=50)
    entity_id: Optional[int] = None
    audit_metadata: Optional[Dict[str, Any]] = None

class AuditLogCreate(AuditLogBase):
    pass

class AuditLogResponse(BaseModel):
    id: int
    user_id: int
    action: str
    entity_type: str
    entity_id: Optional[int]
    audit_metadata: Optional[Dict[str, Any]]
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)
