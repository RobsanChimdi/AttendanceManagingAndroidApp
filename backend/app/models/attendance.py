from sqlalchemy import Column, Integer, String, ForeignKey, DateTime, Enum as SQLEnum, UniqueConstraint
from sqlalchemy.orm import relationship
import enum
from app.database import Base
from app.models.base import TimestampMixin

class AttendanceStatus(str, enum.Enum):
    PRESENT = "PRESENT"
    ABSENT = "ABSENT"

class AttendanceMethod(str, enum.Enum):
    FACE = "FACE"
    QR = "QR"
    MANUAL = "MANUAL"

class Attendance(Base, TimestampMixin):
    __tablename__ = "attendance"
    
    # Ensure no duplicate attendance for same session and student
    __table_args__ = (
        UniqueConstraint('session_id', 'student_id', name='unique_session_student_attendance'),
    )

    id = Column(Integer, primary_key=True, index=True)
    session_id = Column(Integer, ForeignKey("attendance_sessions.id"), nullable=False)
    student_id = Column(Integer, ForeignKey("students.id"), nullable=False)
    status = Column(SQLEnum(AttendanceStatus), nullable=False)
    method = Column(SQLEnum(AttendanceMethod), nullable=True)
    recognized_at = Column(DateTime, nullable=True)
    
    # Relationships
    session = relationship("AttendanceSession", back_populates="attendance_records")
    student = relationship("Student", back_populates="attendance_records")