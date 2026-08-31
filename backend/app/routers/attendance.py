from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from sqlalchemy.orm import Session
from app.database import get_db
from app.repositories.attendance_session_repository import AttendanceSessionRepository
from app.repositories.face_embedding_repository import FaceEmbeddingRepository
from app.repositories.attendance_repository import AttendanceRepository
from app.repositories.student_repository import StudentRepository
from app.repositories.class_repository import ClassRepository
from app.models.attendance_session import SessionStatus
from app.models.attendance import AttendanceStatus, AttendanceMethod
from app.services.attendance_session_service import AttendanceSessionService
from app.schemas.attendance_session import AttendanceSessionCreate, AttendanceSessionResponse
from app.config import settings
from pydantic import BaseModel
import pickle
import numpy as np
import logging

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/attendance", tags=["Attendance"])

class QRAttendanceRequest(BaseModel):
    qr_token: str

# Session Management Endpoints

@router.post("/sessions", response_model=AttendanceSessionResponse, status_code=status.HTTP_201_CREATED)
def create_session(
    session_data: AttendanceSessionCreate,
    db: Session = Depends(get_db)
):
    """
    Create a new attendance session.
    """
    try:
        session_service = AttendanceSessionService(db)
        return session_service.create_session(session_data)
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error creating attendance session: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create attendance session: {str(e)}"
        )

@router.get("/sessions/{session_id}", response_model=AttendanceSessionResponse)
def get_session(
    session_id: int,
    db: Session = Depends(get_db)
):
    """
    Get attendance session by ID.
    """
    try:
        session_service = AttendanceSessionService(db)
        return session_service.get_session(session_id)
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting attendance session: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get attendance session: {str(e)}"
        )

@router.post("/sessions/{session_id}/start", response_model=AttendanceSessionResponse)
def start_session(
    session_id: int,
    db: Session = Depends(get_db)
):
    """
    Start an attendance session (change status to OPEN).
    """
    try:
        session_service = AttendanceSessionService(db)
        return session_service.start_session(session_id)
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error starting attendance session: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to start attendance session: {str(e)}"
        )

@router.post("/sessions/{session_id}/close")
def close_session(
    session_id: int,
    db: Session = Depends(get_db)
):
    """
    Close an attendance session and mark remaining students as absent.
    """
    try:
        session_service = AttendanceSessionService(db)
        result = session_service.close_session(session_id)
        return result
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error closing attendance session: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to close attendance session: {str(e)}"
        )

@router.get("/sessions/{session_id}/statistics")
def get_session_statistics(
    session_id: int,
    db: Session = Depends(get_db)
):
    """
    Get attendance statistics for a session.
    """
    try:
        session_service = AttendanceSessionService(db)
        return session_service.get_session_statistics(session_id)
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting session statistics: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get session statistics: {str(e)}"
        )

@router.get("/sessions/{session_id}/attendance")
def get_session_attendance(
    session_id: int,
    db: Session = Depends(get_db)
):
    """
    Get all attendance records for a session with student details.
    """
    try:
        session_service = AttendanceSessionService(db)
        return session_service.get_session_attendance(session_id)
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting session attendance: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get session attendance: {str(e)}"
        )

# Face Recognition Endpoint

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

# QR Attendance Endpoint

@router.post("/sessions/{session_id}/qr-attendance")
async def mark_qr_attendance(
    session_id: int,
    qr_request: QRAttendanceRequest,
    db: Session = Depends(get_db)
):
    """
    Mark attendance using QR code token.
    Validates the token, checks session status, prevents duplicates.
    """
    try:
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
                detail=f"Attendance session is {session.status.value}. Cannot mark attendance in closed sessions."
            )
        
        # Find student by QR token
        student_repo = StudentRepository(db)
        student = student_repo.get_by_qr_token(qr_request.qr_token)
        
        if not student:
            return {
                "status": "INVALID",
                "reason": "Invalid QR code"
            }
        
        # Check if student belongs to the session's class
        if student.class_id != session.class_id:
            return {
                "status": "INVALID",
                "reason": "Student does not belong to this class"
            }
        
        # Check for duplicate attendance
        attendance_repo = AttendanceRepository(db)
        existing_attendance = attendance_repo.get_by_session_and_student(session_id, student.id)
        
        if existing_attendance and existing_attendance.status == AttendanceStatus.PRESENT:
            return {
                "status": "ALREADY_PRESENT",
                "student_id": student.id,
                "student_name": f"{student.firstName} {student.lastName}",
                "student_id_str": student.studentId,
                "message": "Student already marked present"
            }
        
        # Mark attendance
        attendance_repo.create({
            "session_id": session_id,
            "student_id": student.id,
            "status": AttendanceStatus.PRESENT,
            "method": AttendanceMethod.QR,
            "recognized_at": None  # Will be set by timestamp mixin
        })
        
        return {
            "status": "MATCH",
            "student_id": student.id,
            "student_name": f"{student.firstName} {student.lastName}",
            "student_id_str": student.studentId,
            "message": "Attendance marked successfully"
        }
            
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in QR attendance: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"QR attendance failed: {str(e)}"
        )
