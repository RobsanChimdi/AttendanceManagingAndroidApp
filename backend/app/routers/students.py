from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from sqlalchemy.orm import Session
from app.database import get_db

router = APIRouter(prefix="/students", tags=["Students"])

@router.get("/")
def list_students(db: Session = Depends(get_db)):
    """
    List all registered students.
    """
    return []

@router.post("/")
def create_student(db: Session = Depends(get_db)):
    """
    Register a new student.
    """
    return {"message": "Student created successfully"}

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
