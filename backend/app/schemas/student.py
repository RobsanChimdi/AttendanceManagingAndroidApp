from pydantic import BaseModel, EmailStr, Field, ConfigDict
from datetime import datetime, date
from enum import Enum

class StudentStatus(str, Enum):
    ACTIVE = "ACTIVE"
    INACTIVE = "INACTIVE"
    GRADUATED = "GRADUATED"

class StudentBase(BaseModel):
    student_id: str = Field(..., min_length=1, max_length=50)
    first_name: str = Field(..., min_length=1, max_length=50)
    middle_name: str = Field(None, max_length=50)
    last_name: str = Field(..., min_length=1, max_length=50)
    gender: str = Field(None, max_length=10)
    date_of_birth: date = None
    grade: str = Field(None, max_length=10)
    section: str = Field(None, max_length=10)
    class_id: int = None
    guardian_name: str = Field(None, max_length=100)
    guardian_phone: str = Field(None, max_length=20)
    guardian_email: EmailStr = None
    status: StudentStatus = StudentStatus.ACTIVE

class StudentCreate(StudentBase):
    pass

class StudentUpdate(BaseModel):
    first_name: str = Field(None, min_length=1, max_length=50)
    middle_name: str = Field(None, max_length=50)
    last_name: str = Field(None, min_length=1, max_length=50)
    gender: str = Field(None, max_length=10)
    date_of_birth: date = None
    grade: str = Field(None, max_length=10)
    section: str = Field(None, max_length=10)
    class_id: int = None
    guardian_name: str = Field(None, max_length=100)
    guardian_phone: str = Field(None, max_length=20)
    guardian_email: EmailStr = None
    status: StudentStatus = None

class StudentResponse(BaseModel):
    id: int
    student_id: str
    first_name: str
    middle_name: str
    last_name: str
    gender: str
    date_of_birth: date
    grade: str
    section: str
    class_id: int
    guardian_name: str
    guardian_phone: str
    guardian_email: str
    status: StudentStatus
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)