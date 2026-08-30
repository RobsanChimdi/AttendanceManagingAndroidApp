from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from sqlalchemy.orm import Session
from app.database import get_db
from app.repositories.attendance_session_repository import AttendanceSessionRepository
from app.repositories.face_embedding_repository import FaceEmbeddingRepository
from app.repositories.attendance_repository import AttendanceRepository
from app.repositories.student_repository import StudentRepository
from app.models.attendance_session import SessionStatus
from app.models.attendance import AttendanceStatus, AttendanceMethod
from app.config import settings
import pickle
import numpy as np
import logging

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/attendance", tags=["Attendance"])

@router.post("/sessions/{session_id}/recognize")
async def recognize_face(
    session_id: int,
    file: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    """
    Recognize a face from an uploaded image and match against enrolled students.
    Returns match status, student info, and confidence if matched.
    """
    try:
        from app.facial_recognition.service import face_recognition_service
        
        # Validate session exists and is OPEN
        session_repo = AttendanceSessionRepository(db)
        session = session_repo.get_by_id(session_id)
        
        if not session:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Attendance session not found"
            )
        
        if session.status != SessionStatus.OPEN:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Attendance session is {session.status.value}. Cannot recognize faces in closed sessions."
            )
        
        # Download models if needed
        face_recognition_service.download_models_if_missing()
        
        # Read image
        image_bytes = await file.read()
        
        # Detect face
        success, face_coords, num_faces = face_recognition_service.detect_face(image_bytes)
        
        if not success:
            return {
                "status": "UNKNOWN",
                "reason": "No face detected in the image"
            }
        
        if num_faces > 1:
            return {
                "status": "UNKNOWN",
                "reason": "Multiple faces detected. Please ensure only one person is visible."
            }
        
        # Validate face quality
        quality_check = face_recognition_service.validate_face_quality(image_bytes, face_coords)
        if not quality_check["valid"]:
            return {
                "status": "UNKNOWN",
                "reason": quality_check["message"]
            }
        
        # Extract embedding from detected face
        query_embedding = face_recognition_service.extract_embedding(image_bytes, face_coords)
        
        # Get all enrolled embeddings
        face_embedding_repo = FaceEmbeddingRepository(db)
        all_embeddings = face_embedding_repo.get_by_model("sface", "2021dec")
        
        if not all_embeddings:
            return {
                "status": "UNKNOWN",
                "reason": "No enrolled students found in the system"
            }
        
        # Compare query embedding with all enrolled embeddings
        best_match = None
        best_confidence = 0.0
        
        for face_embedding in all_embeddings:
            try:
                # Deserialize stored embedding
                stored_embedding = pickle.loads(face_embedding.embedding)
                
                # Compare embeddings using cosine similarity
                is_match, confidence = face_recognition_service.compare_embeddings(
                    query_embedding, 
                    stored_embedding
                )
                
                if confidence > best_confidence:
                    best_confidence = confidence
                    best_match = face_embedding
                    
            except Exception as e:
                logger.error(f"Error comparing with embedding {face_embedding.id}: {e}")
                continue
        
        # Check if best match exceeds threshold
        if best_match and best_confidence >= settings.FACE_RECOGNITION_THRESHOLD:
            # Get student details
            student_repo = StudentRepository(db)
            student = student_repo.get_by_id(best_match.student_id)
            
            if not student:
                return {
                    "status": "UNKNOWN",
                    "reason": "Matched student not found in database"
                }
            
            # Check if student has already been marked present for this session
            attendance_repo = AttendanceRepository(db)
            existing_attendance = attendance_repo.get_by_session_and_student(session_id, student.id)
            
            if existing_attendance and existing_attendance.status == AttendanceStatus.PRESENT:
                return {
                    "status": "MATCH",
                    "student_id": student.id,
                    "student_name": f"{student.firstName} {student.lastName}",
                    "student_id_str:": student.studentId,
                    "confidence": best_confidence,
                    "already_marked": True,
                    "message": "Student already marked as present"
                }
            
            # Mark attendance
            attendance_repo.create({
                "session_id": session_id,
                "student_id": student.id,
                "status": AttendanceStatus.PRESENT,
                "method": AttendanceMethod.FACE,
                "recognized_at": None  # Will be set by timestamp mixin
            })
            
            return {
                "status": "MATCH",
                "student_id": student.id,
                "student_name": f"{student.firstName} {student.lastName}",
                "student_id_str": student.studentId,
                "confidence": best_confidence,
                "already_marked": False,
                "message": "Student recognized and marked present"
            }
        else:
            # Low confidence or no match
            if best_match and best_confidence > 0.0:
                return {
                    "status": "LOW_CONFIDENCE",
                    "reason": f"Best match confidence ({best_confidence:.3f}) is below threshold ({settings.FACE_RECOGNITION_THRESHOLD})"
                }
            else:
                return {
                    "status": "UNKNOWN",
                    "reason": "No matching student found"
                }
            
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in face recognition: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Face recognition failed: {str(e)}"
        )
