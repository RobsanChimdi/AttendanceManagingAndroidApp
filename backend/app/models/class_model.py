from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship
from app.database import Base
from app.models.base import TimestampMixin

class Class(Base, TimestampMixin):
    __tablename__ = "classes"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    grade = Column(String, nullable=True)
    section = Column(String, nullable=True)
    
    # Relationships
    students = relationship("Student", back_populates="class_relationship")
    attendance_sessions = relationship("AttendanceSession", back_populates="class_relationship")