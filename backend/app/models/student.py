from sqlalchemy import Column, Integer, String, ForeignKey, Enum as SQLEnum, Date, Boolean
from sqlalchemy.orm import relationship
import enum
from app.database import Base
from app.models.base import TimestampMixin

class StudentStatus(str, enum.Enum):
    ACTIVE = "ACTIVE"
    INACTIVE = "INACTIVE"
    GRADUATED = "GRADUATED"

class Student(Base, TimestampMixin):
    __tablename__ = "students"

    id = Column(Integer, primary_key=True, index=True)
    student_id = Column(String, unique=True, index=True, nullable=False)
    first_name = Column(String, nullable=False)
    middle_name = Column(String, nullable=True)
    last_name = Column(String, nullable=False)
    gender = Column(String, nullable=True)
    date_of_birth = Column(Date, nullable=True)
    grade = Column(String, nullable=True)
    section = Column(String, nullable=True)
    class_id = Column(Integer, ForeignKey("classes.id"), nullable=True)
    guardian_name = Column(String, nullable=True)
    guardian_phone = Column(String, nullable=True)
    guardian_email = Column(String, nullable=True)
    qr_token = Column(String, unique=True, nullable=True)  # Secure token for二维码 attendance
    status = Column(SQLEnum(StudentStatus), default=StudentStatus.ACTIVE)
    critical_attendance = Column(String, nullable=True)  # Stores attendance percentage as string
    is_critical = Column(Boolean, default=False)  # Flag for critical attendance
    
    # Relationships
    class_relationship = relationship("Class", back_populates="students")
    face_embeddings = relationship("FaceEmbedding", back_populates="student")
    attendance_records = relationship("Attendance", back_populates="student")
    notifications = relationship("Notification", back_populates="student")
