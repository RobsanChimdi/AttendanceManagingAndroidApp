from typing import List, Optional
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.repositories.student_repository import StudentRepository
from app.repositories.class_repository import ClassRepository
from app.schemas.student import StudentCreate, StudentUpdate
from app.models.student import Student

class StudentService:
    def __init__(self, db: Session):
        self.db = db
        self.student_repo = StudentRepository(db)
        self.class_repo = ClassRepository(db)

    def get_student(self, student_id: int) -> Student:
        student = self.student_repo.get(student_id)
        if not student:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Student with id {student_id} not found"
            )
        return student

    def get_student_by_student_id(self, student_id: str) -> Student:
        student = self.student_repo.get_by_student_id(student_id)
        if not student:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Student with student_id {student_id} not found"
            )
        return student

    def list_students(self, skip: int = 0, limit: int = 100) -> List[Student]:
        return self.student_repo.get_all(skip=skip, limit=limit)

    def create_student(self, student_in: StudentCreate) -> Student:
        # Check if student_id already exists
        existing = self.student_repo.get_by_student_id(student_in.student_id)
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Student with student_id {student_in.student_id} already exists"
            )
        
        # Validate class_id if provided
        if student_in.class_id:
            if not self.class_repo.exists(student_in.class_id):
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Class with id {student_in.class_id} not found"
                )
        
        student_data = student_in.model_dump()
        return self.student_repo.create(student_data)

    def update_student(self, student_id: int, student_in: StudentUpdate) -> Student:
        student = self.get_student(student_id)
        
        # Validate class_id if provided
        if student_in.class_id and student_in.class_id != student.class_id:
            if not self.class_repo.exists(student_in.class_id):
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Class with id {student_in.class_id} not found"
                )
        
        update_data = student_in.model_dump(exclude_unset=True)
        return self.student_repo.update(student, update_data)

    def delete_student(self, student_id: int) -> Student:
        student = self.get_student(student_id)
        return self.student_repo.delete(student_id)

    def get_students_by_class(self, class_id: int, skip: int = 0, limit: int = 100) -> List[Student]:
        if not self.class_repo.exists(class_id):
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Class with id {class_id} not found"
            )
        return self.student_repo.get_by_class(class_id, skip=skip, limit=limit)

    def search_students(self, name: str, skip: int = 0, limit: int = 100) -> List[Student]:
        return self.student_repo.search_by_name(name, skip=skip, limit=limit)
