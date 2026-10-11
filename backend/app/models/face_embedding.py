from sqlalchemy import Column, Integer, String, ForeignKey, LargeBinary
from sqlalchemy.orm import relationship
from app.database import Base
from app.models.base import TimestampMixin

class FaceEmbedding(Base, TimestampMixin):
    __tablename__ = "face_embeddings"

    id = Column(Integer, primary_key=True, index=True)
    student_id = Column(Integer, ForeignKey("students.id"), nullable=False)
    embedding = Column(LargeBinary, nullable=False)  # Store as binary to prevent exposure
    model_name = Column(String, nullable=False)
    model_version = Column(String, nullable=True)
    
    # Relationships
    student = relationship("Student", back_populates="face_embeddings")