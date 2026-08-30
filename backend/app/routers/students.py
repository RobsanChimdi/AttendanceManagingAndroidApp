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

@router.post("/{student_id}/face/enroll")
async def enroll_face(
    student_id: int,
    files: List[UploadFile] = File(...),
    db: Session = Depends(get_db)
):
    """
    Enroll a student's face by uploading multiple face samples (5 recommended).
    Each sample should be a clear photo of the student's face from different angles.
    """
    try:
        from app.facial_recognition.service import face_recognition_service
        from app.repositories.face_embedding_repository import FaceEmbeddingRepository
        import pickle
        import numpy as np
        
        # Verify student exists
        student_service = StudentService(db)
        student = student_service.get_student(student_id)
        
        # Validate number of samples
        if len(files) < 3:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"At least 3 face samples required. {len(files)} provided."
            )
        
        if len(files) > 10:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Too many samples. Maximum 10 allowed. {len(files)} provided."
            )
        
        # Download models if needed
        face_recognition_service.download_models_if_missing()
        
        embeddings = []
        valid_samples = 0
        failed_samples = []
        
        for i, file in enumerate(files):
            try:
                image_bytes = await file.read()
                
                # Detect face
                success, face_coords, num_faces = face_recognition_service.detect_face(image_bytes)
                
                if not success:
                    failed_samples.append({
                        "sample": i + 1,
                        "reason": "No face detected"
                    })
                    continue
                
                if num_faces > 1:
                    failed_samples.append({
                        "sample": i + 1,
                        "reason": "Multiple faces detected"
                    })
                    continue
                
                # Validate face quality
                quality_check = face_recognition_service.validate_face_quality(image_bytes, face_coords)
                if not quality_check["valid"]:
                    failed_samples.append({
                        "sample": i + 1,
                        "reason": quality_check["message"]
                    })
                    continue
                
                # Extract embedding
                embedding = face_recognition_service.extract_embedding(image_bytes, face_coords)
                embeddings.append(embedding)
                valid_samples += 1
                
            except Exception as e:
                failed_samples.append({
                    "sample": i + 1,
                    "reason": f"Processing error: {str(e)}"
                })
                continue
        
        if valid_samples < 3:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Insufficient valid samples. Need at least 3, got {valid_samples}. Failed: {failed_samples}"
            )
        
        # Average the embeddings to create a single representative embedding
        embeddings_array = np.array(embeddings)
        averaged_embedding = np.mean(embeddings_array, axis=0)
        
        # Store embedding
        face_embedding_repo = FaceEmbeddingRepository(db)
        
        # Delete existing embeddings for this student (re-enrollment)
        face_embedding_repo.delete_by_student_id(student_id)
        
        # Store new embedding
        embedding_bytes = pickle.dumps(averaged_embedding)
        face_embedding_repo.create({
            "student_id": student_id,
            "embedding": embedding_bytes,
            "model_name": "sface",
            "model_version": "2021dec"
        })
        
        return {
            "message": "Face enrolled successfully",
            "student_id": student_id,
            "student_name": f"{student.firstName} {student.lastName}",
            "valid_samples": valid_samples,
            "total_samples": len(files),
            "failed_samples": failed_samples,
            "embedding_length": len(averaged_embedding)
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Facial enrollment failed: {e}"
        )

@router.get("/{student_id}/face/status")
async def get_face_enrollment_status(student_id: int, db: Session = Depends(get_db)):
    """
    Check if a student has face enrollment.
    """
    try:
        from app.repositories.face_embedding_repository import FaceEmbeddingRepository
        from app.services.student_service import StudentService
        
        # Verify student exists
        student_service = StudentService(db)
        student = student_service.get_student(student_id)
        
        # Check for existing embeddings
        face_embedding_repo = FaceEmbeddingRepository(db)
        embeddings = face_embedding_repo.get_by_student(student_id)
        
        if embeddings:
            latest = face_embedding_repo.get_latest_by_student(student_id)
            return {
                "enrolled": True,
                "student_id": student_id,
                "student_name": f"{student.firstName} {student.lastName}",
                "enrollment_date": latest.created_at.isoformat() if latest else None,
                "model_name": latest.model_name if latest else None,
                "model_version": latest.model_version if latest else None,
                "samples_count": len(embeddings)
            }
        else:
            return {
                "enrolled": False,
                "student_id": student_id,
                "student_name": f"{student.firstName} {student.lastName}"
            }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to check enrollment status: {e}"
        )
