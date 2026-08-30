from typing import Optional, List
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_
from app.models.student import Student, StudentStatus
from app.repositories.base_repository import BaseRepository

class StudentRepository(BaseRepository[Student]):
    def __init__(self, db: Session):
        super().__init__(Student, db)

    def get_by_student_id(self, student_id: str) -> Optional[Student]:
        return self.db.query(Student).filter(Student.student_id == student_id).first()

    def get_by_class(self, class_id: int, skip: int = 0, limit: int = 100) -> List[Student]:
        return self.db.query(Student).filter(Student.class_id == class_id).offset(skip).limit(limit).all()

    def get_active_students(self, skip: int = 0, limit: int = 100) -> List[Student]:
        return self.db.query(Student).filter(Student.status == StudentStatus.ACTIVE).offset(skip).limit(limit).all()

    def search_by_name(self, name: str, skip: int = 0, limit: int = 100) -> List[Student]:
        return self.db.query(Student).filter(
            Student.first_name.ilike(f"%{name}%") | 
            Student.last_name.ilike(f"%{name}%")
        ).offset(skip).limit(limit).all()

    def filter_students(
        self,
        skip: int = 0,
        limit: int = 100,
        class_id: Optional[int] = None,
        grade: Optional[str] = None,
        section: Optional[str] = None,
        status: Optional[StudentStatus] = None,
        search: Optional[str] = None,
        sort_by: Optional[str] = None,
        sort_order: Optional[str] = None
    ) -> List[Student]:
        query = self.db.query(Student)
        
        # Apply filters
        if class_id is not None:
            query = query.filter(Student.class_id == class_id)
        
        if grade is not None:
            query = query.filter(Student.grade == grade)
        
        if section is not None:
            query = query.filter(Student.section == section)
        
        if status is not None:
            query = query.filter(Student.status == status)
        
        if search is not None:
            query = query.filter(
                or_(
                    Student.first_name.ilike(f"%{search}%"),
                    Student.last_name.ilike(f"%{search}%"),
                    Student.student_id.ilike(f"%{search}%")
                )
            )
        
        # Apply sorting
        if sort_by is not None:
            sort_column = getattr(Student, sort_by, None)
            if sort_column is not None:
                if sort_order == "desc":
                    query = query.order_by(sort_column.desc())
                else:
                    query = query.order_by(sort_column.asc())
        
        return query.offset(skip).limit(limit).all()

    def count_students(
        self,
        class_id: Optional[int] = None,
        grade: Optional[str] = None,
        section: Optional[str] = None,
        status: Optional[StudentStatus] = None,
        search: Optional[str] = None
    ) -> int:
        query = self.db.query(Student)
        
        # Apply filters
        if class_id is not None:
            query = query.filter(Student.class_id == class_id)
        
        if grade is not None:
            query = query.filter(Student.grade == grade)
        
        if section is not None:
            query = query.filter(Student.section == section)
        
        if status is not None:
            query = query.filter(Student.status == status)
        
        if search is not None:
            query = query.filter(
                or_(
                    Student.first_name.ilike(f"%{search}%"),
                    Student.last_name.ilike(f"%{search}%"),
                    Student.student_id.ilike(f"%{search}%")
                )
            )
        
        return query.count()
