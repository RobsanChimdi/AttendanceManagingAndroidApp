from pydantic import BaseModel, Field, ConfigDict
from datetime import datetime, date
from enum import Enum
from typing import Optional

class SessionStatus(str, Enum):
    OPEN = "OPEN"
    CLOSED = "CLOSED"

class AttendanceSessionBase(BaseModel):
    class_id: int = Field(..., gt=0)
    teacher_id: int = Field(..., gt=0)
    date: date
    status: SessionStatus = SessionStatus.OPEN

class AttendanceSessionCreate(AttendanceSessionBase):
    pass

class AttendanceSessionUpdate(BaseModel):
    status: SessionStatus = None
    started_at: datetime = None
    closed_at: datetime = None

class AttendanceSessionResponse(BaseModel):
    id: int
    class_id: int
    teacher_id: int
    date: date
    status: SessionStatus
    started_at: Optional[datetime]
    closed_at: Optional[datetime]
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)
