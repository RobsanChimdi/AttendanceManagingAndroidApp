from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.services.class_service import ClassService
from app.schemas.class_model import ClassCreate, ClassUpdate, ClassResponse

router = APIRouter(prefix="/classes", tags=["Classes"])

@router.get("/", response_model=List[ClassResponse])
def list_classes(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=100),
    db: Session = Depends(get_db)
):
    """
    List all classes with pagination.
    """
    class_service = ClassService(db)
    return class_service.list_classes(skip=skip, limit=limit)

@router.get("/{class_id}", response_model=ClassResponse)
def get_class(class_id: int, db: Session = Depends(get_db)):
    """
    Get a specific class by ID.
    """
    class_service = ClassService(db)
    return class_service.get_class(class_id)

@router.post("/", response_model=ClassResponse, status_code=status.HTTP_201_CREATED)
def create_class(class_in: ClassCreate, db: Session = Depends(get_db)):
    """
    Create a new class.
    """
    class_service = ClassService(db)
    return class_service.create_class(class_in)

@router.put("/{class_id}", response_model=ClassResponse)
def update_class(class_id: int, class_in: ClassUpdate, db: Session = Depends(get_db)):
    """
    Update an existing class.
    """
    class_service = ClassService(db)
    return class_service.update_class(class_id, class_in)

@router.delete("/{class_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_class(class_id: int, db: Session = Depends(get_db)):
    """
    Delete a class.
    """
    class_service = ClassService(db)
    class_service.delete_class(class_id)
    return None

@router.get("/grade/{grade}", response_model=List[ClassResponse])
def get_classes_by_grade(
    grade: str,
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=100),
    db: Session = Depends(get_db)
):
    """
    Get all classes for a specific grade.
    """
    class_service = ClassService(db)
    return class_service.get_classes_by_grade(grade, skip=skip, limit=limit)
