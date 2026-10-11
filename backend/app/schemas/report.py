from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import date, datetime
from enum import Enum

class ReportFilter(BaseModel):
    date: Optional[date] = None
    date_from: Optional[date] = None
    date_to: Optional[date] = None
    grade: Optional[str] = None
    class_id: Optional[int] = None
    section: Optional[str] = None
    student_id: Optional[int] = None
    status: Optional[str] = None
    method: Optional[str] = None
    skip: int = Field(default=0, ge=0)
    limit: int = Field(default=100, ge=1, le=1000)

class AttendanceReportRecord(BaseModel):
    id: int
    date: date
    student_id: int
    student_name: str
    student_id_str: str
    grade: Optional[str] = None
    section: Optional[str] = None
    class_name: Optional[str] = None
    status: str
    method: Optional[str] = None
    recognized_at: Optional[datetime] = None

class AttendanceReportResponse(BaseModel):
    records: List[AttendanceReportRecord]
    total: int
    skip: int
    limit: int
    filters: ReportFilter

class ReportSummary(BaseModel):
    total_records: int
    present_count: int
    absent_count: int
    present_percentage: float
    absent_percentage: float
    face_count: int
    qr_count: int
    manual_count: int
