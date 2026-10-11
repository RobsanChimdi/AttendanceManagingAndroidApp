from pydantic import BaseModel, Field, ConfigDict
from datetime import datetime
from enum import Enum
from typing import Optional

class NotificationStatus(str, Enum):
    PENDING = "PENDING"
    SENT = "SENT"
    FAILED = "FAILED"

class NotificationBase(BaseModel):
    student_id: int = Field(..., gt=0)
    guardian_name: str = Field(..., min_length=1, max_length=100)
    guardian_phone: str = Field(..., min_length=1, max_length=20)
    message: str = Field(..., min_length=1, max_length=500)
    status: NotificationStatus = NotificationStatus.PENDING

class NotificationCreate(NotificationBase):
    pass

class NotificationUpdate(BaseModel):
    status: NotificationStatus = None
    sent_at: datetime = None

class NotificationResponse(BaseModel):
    id: int
    student_id: int
    guardian_name: str
    guardian_phone: str
    message: str
    status: NotificationStatus
    sent_at: Optional[datetime]
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)
