from sqlalchemy import Column, Integer, String, Enum as SQLEnum
from sqlalchemy.orm import relationship
import enum
from app.database import Base
from app.models.base import TimestampMixin

class UserRole(str, enum.Enum):
    ADMIN = "ADMIN"
    TEACHER = "TEACHER"

class User(Base, TimestampMixin):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=False)
    role = Column(SQLEnum(UserRole), nullable=False, default=UserRole.TEACHER)
    
    # Relationships
    attendance_sessions = relationship("AttendanceSession", back_populates="teacher")
    audit_logs = relationship("AuditLog", back_populates="user")
