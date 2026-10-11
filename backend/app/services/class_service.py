from typing import List
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.repositories.class_repository import ClassRepository
from app.schemas.class_model import ClassCreate, ClassUpdate
from app.models.class_model import Class

class ClassService:
    def __init__(self, db: Session):
        self.db = db
        self.class_repo = ClassRepository(db)

    def get_class(self, class_id: int) -> Class:
        class_obj = self.class_repo.get(class_id)
        if not class_obj:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Class with id {class_id} not found"
            )
        return class_obj

    def list_classes(self, skip: int = 0, limit: int = 100) -> List[Class]:
        return self.class_repo.get_all(skip=skip, limit=limit)

    def create_class(self, class_in: ClassCreate) -> Class:
        # Check if class with same grade and section already exists
        if class_in.grade and class_in.section:
            existing = self.class_repo.get_by_grade_section(class_in.grade, class_in.section)
            if existing:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Class with grade {class_in.grade} and section {class_in.section} already exists"
                )
        
        class_data = class_in.model_dump()
        return self.class_repo.create(class_data)

    def update_class(self, class_id: int, class_in: ClassUpdate) -> Class:
        class_obj = self.get_class(class_id)
        update_data = class_in.model_dump(exclude_unset=True)
        return self.class_repo.update(class_obj, update_data)

    def delete_class(self, class_id: int) -> Class:
        class_obj = self.get_class(class_id)
        return self.class_repo.delete(class_id)

    def get_classes_by_grade(self, grade: str, skip: int = 0, limit: int = 100) -> List[Class]:
        return self.class_repo.get_by_grade(grade, skip=skip, limit=limit)
