from typing import Optional, List
from sqlalchemy.orm import Session
from app.models.face_embedding import FaceEmbedding
from app.repositories.base_repository import BaseRepository

class FaceEmbeddingRepository(BaseRepository[FaceEmbedding]):
    def __init__(self, db: Session):
        super().__init__(FaceEmbedding, db)

    def get_by_student(self, student_id: int) -> List[FaceEmbedding]:
        return self.db.query(FaceEmbedding).filter(
            FaceEmbedding.student_id == student_id
        ).all()

    def get_latest_by_student(self, student_id: int) -> Optional[FaceEmbedding]:
        return self.db.query(FaceEmbedding).filter(
            FaceEmbedding.student_id == student_id
        ).order_by(FaceEmbedding.created_at.desc()).first()

    def get_by_model(self, model_name: str, model_version: str = None, skip: int = 0, limit: int = 100) -> List[FaceEmbedding]:
        if model_version:
            return self.db.query(FaceEmbedding).filter(
                FaceEmbedding.model_name == model_name,
                FaceEmbedding.model_version == model_version
            ).offset(skip).limit(limit).all()
        return self.db.query(FaceEmbedding).filter(
            FaceEmbedding.model_name == model_name
        ).offset(skip).limit(limit).all()

    def delete_by_student_id(self, student_id: int) -> int:
        """Delete all embeddings for a specific student (for re-enrollment)."""
        count = self.db.query(FaceEmbedding).filter(
            FaceEmbedding.student_id == student_id
        ).count()
        self.db.query(FaceEmbedding).filter(
            FaceEmbedding.student_id == student_id
        ).delete()
        self.db.commit()
        return count
