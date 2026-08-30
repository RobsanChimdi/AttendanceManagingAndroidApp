from typing import Optional, List
from sqlalchemy.orm import Session
from app.models.class_model import Class
from app.repositories.base_repository import BaseRepository

class ClassRepository(BaseRepository[Class]):
    def __init__(self, db: Session):
        super().__init__(Class, db)

    def get_by_grade_section(self, grade: str, section: str) -> Optional[Class]:
        return self.db.query(Class).filter(
            Class.grade == grade,
            Class.section == section
        ).first()

    def get_by_grade(self, grade: str, skip: int = 0, limit: int = 100) -> List[Class]:
        return self.db.query(Class).filter(Class.grade == grade).offset(skip).limit(limit).all()
