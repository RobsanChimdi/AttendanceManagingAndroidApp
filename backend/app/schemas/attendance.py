from pydantic import BaseModel, Field, ConfigDict
from datetime import datetime
from enum import Enum
from typing import Optional

class AttendanceStatus(str, Enum):
    PRESENT = "PRESENT"
    ABSENT = "ABSENT"

class AttendanceMethod(str, Enum):
    FACE = "FACE"
    QR = "QR"
    MANUAL = "MANUAL"

class AttendanceBase(BaseModel):
    session_id: int = Field(..., gt=0)
    student_id: int = Field(..., gt=0)
    status: AttendanceStatus
    method: AttendanceMethod = None

class AttendanceCreate(AttendanceBase):
    pass

class AttendanceUpdate(BaseModel):
    status: AttendanceStatus = None
    method: AttendanceMethod = None
    recognized_at: datetime = None

class AttendanceResponse(BaseModel):
    id: int
    session_id: int
    student_id: int
    status: AttendanceStatus
    method: Optional[AttendanceMethod]
    recognized_at: Optional[datetime]
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)
