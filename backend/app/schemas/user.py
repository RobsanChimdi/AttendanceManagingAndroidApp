from pydantic import BaseModel, EmailStr, Field, ConfigDict
from datetime import datetime
from enum import Enum

class UserRole(str, Enum):
    ADMIN = "ADMIN"
    TEACHER = "TEACHER"

class UserBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    email: EmailStr
    role: UserRole = UserRole.TEACHER

class UserCreate(UserBase):
    password: str = Field(..., min_length=8)

class UserResponse(BaseModel):
    id: int
    name: str
    email: str
    role: UserRole
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)

class UserLogin(BaseModel):
    email: EmailStr
    password: str