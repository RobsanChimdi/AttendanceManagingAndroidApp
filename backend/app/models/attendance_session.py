from sqlalchemy import Column, Integer, String, ForeignKey, Date, DateTime, Enum as SQLEnum
from sqlalchemy.orm import relationship
import enum
from app.database import Base
from app.models.base import TimestampMixin

class SessionStatus(str, enum.Enum):
    OPEN = "OPEN"
    CLOSED = "CLOSED"

class AttendanceSession(Base, TimestampMixin):
    __tablename__ = "attendance_sessions"

    id = Column(Integer, primary_key=True, index=True)
    class_id = Column(Integer, ForeignKey("classes.id"), nullable=False)
    teacher_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    date = Column(Date, nullable=False)
    status = Column(SQLEnum(SessionStatus), default=SessionStatus.OPEN)
    started_at = Column(DateTime, nullable=True)
    closed_at = Column(DateTime, nullable=True)
    
    # Relationships
    class_relationship = relationship("Class", back_populates="attendance_sessions")
    teacher = relationship("User", back_populates="attendance_sessions")
    attendance_records = relationship("Attendance", back_populates="session")