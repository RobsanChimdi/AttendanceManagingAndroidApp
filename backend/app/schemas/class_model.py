from pydantic import BaseModel, Field, ConfigDict
from datetime import datetime
from typing import Optional

class ClassBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    grade: str = Field(None, max_length=10)
    section: str = Field(None, max_length=10)

class ClassCreate(ClassBase):
    pass

class ClassUpdate(BaseModel):
    name: str = Field(None, min_length=1, max_length=100)
    grade: str = Field(None, max_length=10)
    section: str = Field(None, max_length=10)

class ClassResponse(BaseModel):
    id: int
    name: str
    grade: Optional[str]
    section: Optional[str]
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)
