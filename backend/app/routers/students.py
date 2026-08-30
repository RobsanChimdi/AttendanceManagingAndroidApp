from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from app.database import get_db
from app.services.student_service import StudentService
from app.schemas.student import StudentCreate, StudentUpdate, StudentResponse, StudentStatus
from pydantic import BaseModel

router = APIRouter(prefix="/students", tags=["Students"])

class StudentFilterResponse(BaseModel):
    students: List[StudentResponse]
    total: int
    skip: int
    limit: int

@router.get("/", response_model=StudentFilterResponse)
def list_students(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=100),
    class_id: Optional[int] = Query(None),
    grade: Optional[str] = Query(None),
    section: Optional[str] = Query(None),
    status: Optional[StudentStatus] = Query(None),
    search: Optional[str] = Query(None),
    sort_by: Optional[str] = Query(None, description="Field to sort by: first_name, last_name, student_id, grade, section, status"),
    sort_order: Optional[str] = Query("asc", regex="^(asc|desc)$"),
    db: Session = Depends(get_db)
):
    """
    List all registered students with pagination, filtering, search, and sorting.
    """
    student_service = StudentService(db)
    result = student_service.filter_students(
        skip=skip,
        limit=limit,
        class_id=class_id,
        grade=grade,
        section=section,
        status=status,
        search=search,
        sort_by=sort_by,
        sort_order=sort_order
    )
    return result

@router.get("/student-id/{student_id}", response_model=StudentResponse)
def get_student_by_student_id(student_id: str, db: Session = Depends(get_db)):
    """
    Get a specific student by student_id.
    """
    student_service = StudentService(db)
    return student_service.get_student_by_student_id(student_id)

@router.get("/class/{class_id}", response_model=List[StudentResponse])
def get_students_by_class(
    class_id: int,
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=100),
    db: Session = Depends(get_db)
):
    """
    Get all students for a specific class.
    """
    student_service = StudentService(db)
    return student_service.get_students_by_class(class_id, skip=skip, limit=limit)

@router.get("/search/{name}", response_model=List[StudentResponse])
def search_students(
    name: str,
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=100),
    db: Session = Depends(get_db)
):
    """
    Search students by name.
    """
    student_service = StudentService(db)
    return student_service.search_students(name, skip=skip, limit=limit)

@router.get("/{student_id}", response_model=StudentResponse)
def get_student(student_id: int, db: Session = Depends(get_db)):
    """
    Get a specific student by ID.
    """
    student_service = StudentService(db)
    return student_service.get_student(student_id)

@router.post("/", response_model=StudentResponse, status_code=status.HTTP_201_CREATED)
def create_student(student_in: StudentCreate, db: Session = Depends(get_db)):
    """
    Register a new student.
    """
    student_service = StudentService(db)
    return student_service.create_student(student_in)

@router.put("/{student_id}", response_model=StudentResponse)
def update_student(student_id: int, student_in: StudentUpdate, db: Session = Depends(get_db)):
    """
    Update an existing student.
    """
    student_service = StudentService(db)
    return student_service.update_student(student_id, student_in)

@router.delete("/{student_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_student(student_id: int, db: Session = Depends(get_db)):
    """
    Delete a student.
    """
    student_service = StudentService(db)
    student_service.delete_student(student_id)
    return None

@router.patch("/{student_id}/deactivate", response_model=StudentResponse)
def deactivate_student(student_id: int, db: Session = Depends(get_db)):
    """
    Deactivate a student (soft delete).
    """
    student_service = StudentService(db)
    return student_service.deactivate_student(student_id)

@router.post("/{student_id}/enroll-face")
async def enroll_face(student_id: str, file: UploadFile = File(...), db: Session = Depends(get_db)):
    """
    Enroll a student's face by uploading a face photo.
    """
    try:
        from app.facial_recognition.service import face_recognition_service
        image_bytes = await file.read()
        
        # Detect face
        success, face_coords = face_recognition_service.detect_face(image_bytes)
        if not success:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="No face detected in the uploaded image. Please try again with a clear photo."
            )
            
        # Extract features
        embedding = face_recognition_service.extract_embedding(image_bytes, face_coords)
        
        # In a real app we'd save this embedding array to the student table.
        # For this foundation skeleton, we return success.
        return {
            "message": "Face enrolled successfully",
            "student_id": student_id,
            "embedding_length": len(embedding)
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Facial enrollment failed: {e}"
        )
