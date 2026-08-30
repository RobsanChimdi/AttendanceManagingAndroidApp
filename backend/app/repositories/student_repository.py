from typing import Optional, List
from sqlalchemy.orm import Session
from sqlalchemy import and_
from app.models.student import Student
from app.repositories.base_repository import BaseRepository

class StudentRepository(BaseRepository[Student]):
    def __init__(self, db: Session):
        super().__init__(Student, db)

    def get_by_student_id(self, student_id: str) -> Optional[Student]:
        return self.db.query(Student).filter(Student.student_id == student_id).first()

    def get_by_class(self, class_id: int, skip: int = 0, limit: int = 100) -> List[Student]:
        return self.db.query(Student).filter(Student.class_id == class_id).offset(skip).limit(limit).all()

    def get_active_students(self, skip: int = 0, limit: int = 100) -> List[Student]:
        from app.models.student import StudentStatus
        return self.db.query(Student).filter(Student.status == StudentStatus.ACTIVE).offset(skip).limit(limit).all()

    def search_by_name(self, name: str, skip: int = 0, limit: int = 100) -> List[Student]:
        return self.db.query(Student).filter(
            Student.first_name.ilike(f"%{name}%") | 
            Student.last_name.ilike(f"%{name}%")
        ).offset(skip).limit(limit).all()
