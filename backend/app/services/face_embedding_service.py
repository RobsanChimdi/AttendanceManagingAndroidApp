from typing import List, Optional
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.repositories.face_embedding_repository import FaceEmbeddingRepository
from app.repositories.student_repository import StudentRepository
from app.schemas.face_embedding import FaceEmbeddingCreate
from app.models.face_embedding import FaceEmbedding

class FaceEmbeddingService:
    def __init__(self, db: Session):
        self.db = db
        self.face_embedding_repo = FaceEmbeddingRepository(db)
        self.student_repo = StudentRepository(db)

    def get_face_embedding(self, embedding_id: int) -> FaceEmbedding:
        embedding = self.face_embedding_repo.get(embedding_id)
        if not embedding:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Face embedding with id {embedding_id} not found"
            )
        return embedding

    def list_face_embeddings(self, skip: int = 0, limit: int = 100) -> List[FaceEmbedding]:
        return self.face_embedding_repo.get_all(skip=skip, limit=limit)

    def create_face_embedding(self, embedding_in: FaceEmbeddingCreate) -> FaceEmbedding:
        # Validate student exists
        if not self.student_repo.exists(embedding_in.student_id):
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Student with id {embedding_in.student_id} not found"
            )
        
        embedding_data = embedding_in.model_dump()
        return self.face_embedding_repo.create(embedding_data)

    def delete_face_embedding(self, embedding_id: int) -> FaceEmbedding:
        embedding = self.get_face_embedding(embedding_id)
        return self.face_embedding_repo.delete(embedding_id)

    def get_face_embeddings_by_student(self, student_id: int) -> List[FaceEmbedding]:
        if not self.student_repo.exists(student_id):
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Student with id {student_id} not found"
            )
        return self.face_embedding_repo.get_by_student(student_id)

    def get_latest_face_embedding(self, student_id: int) -> Optional[FaceEmbedding]:
        if not self.student_repo.exists(student_id):
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Student with id {student_id} not found"
            )
        return self.face_embedding_repo.get_latest_by_student(student_id)

    def get_face_embeddings_by_model(self, model_name: str, model_version: str = None, skip: int = 0, limit: int = 100) -> List[FaceEmbedding]:
        return self.face_embedding_repo.get_by_model(model_name, model_version, skip=skip, limit=limit)
