from sqlalchemy import Column, Integer, String, ForeignKey, DateTime, Enum as SQLEnum
from sqlalchemy.orm import relationship
import enum
from app.database import Base
from app.models.base import TimestampMixin

class NotificationStatus(str, enum.Enum):
    PENDING = "PENDING"
    SENT = "SENT"
    FAILED = "FAILED"

class Notification(Base, TimestampMixin):
    __tablename__ = "notifications"

    id = Column(Integer, primary_key=True, index=True)
    student_id = Column(Integer, ForeignKey("students.id"), nullable=False)
    guardian_name = Column(String, nullable=False)
    guardian_phone = Column(String, nullable=False)
    message = Column(String, nullable=False)
    status = Column(SQLEnum(NotificationStatus), default=NotificationStatus.PENDING)
    sent_at = Column(DateTime, nullable=True)
    
    # Relationships
    student = relationship("Student", back_populates="notifications")