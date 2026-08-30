from typing import List
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from sqlalchemy.exc import IntegrityError
from app.repositories.attendance_repository import AttendanceRepository
from app.repositories.attendance_session_repository import AttendanceSessionRepository
from app.repositories.student_repository import StudentRepository
from app.schemas.attendance import AttendanceCreate, AttendanceUpdate
from app.models.attendance import Attendance, AttendanceStatus, AttendanceMethod

class AttendanceService:
    def __init__(self, db: Session):
        self.db = db
        self.attendance_repo = AttendanceRepository(db)
        self.session_repo = AttendanceSessionRepository(db)
        self.student_repo = StudentRepository(db)

    def get_attendance(self, attendance_id: int) -> Attendance:
        attendance = self.attendance_repo.get(attendance_id)
        if not attendance:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Attendance with id {attendance_id} not found"
            )
        return attendance

    def list_attendance(self, skip: int = 0, limit: int = 100) -> List[Attendance]:
        return self.attendance_repo.get_all(skip=skip, limit=limit)

    def create_attendance(self, attendance_in: AttendanceCreate) -> Attendance:
        # Validate session exists
        if not self.session_repo.exists(attendance_in.session_id):
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Attendance session with id {attendance_in.session_id} not found"
            )
        
        # Validate student exists
        if not self.student_repo.exists(attendance_in.student_id):
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Student with id {attendance_in.student_id} not found"
            )
        
        # Check for duplicate attendance
        existing = self.attendance_repo.get_by_session_and_student(
            attendance_in.session_id, 
            attendance_in.student_id
        )
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Attendance already recorded for student {attendance_in.student_id} in session {attendance_in.session_id}"
            )
        
        attendance_data = attendance_in.model_dump()
        
        try:
            return self.attendance_repo.create(attendance_data)
        except IntegrityError:
            self.db.rollback()
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Duplicate attendance record detected"
            )

    def update_attendance(self, attendance_id: int, attendance_in: AttendanceUpdate) -> Attendance:
        attendance = self.get_attendance(attendance_id)
        update_data = attendance_in.model_dump(exclude_unset=True)
        return self.attendance_repo.update(attendance, update_data)

    def delete_attendance(self, attendance_id: int) -> Attendance:
        attendance = self.get_attendance(attendance_id)
        return self.attendance_repo.delete(attendance_id)

    def get_attendance_by_session(self, session_id: int, skip: int = 0, limit: int = 100) -> List[Attendance]:
        if not self.session_repo.exists(session_id):
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Attendance session with id {session_id} not found"
            )
        return self.attendance_repo.get_by_session(session_id, skip=skip, limit=limit)

    def get_attendance_by_student(self, student_id: int, skip: int = 0, limit: int = 100) -> List[Attendance]:
        if not self.student_repo.exists(student_id):
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Student with id {student_id} not found"
            )
        return self.attendance_repo.get_by_student(student_id, skip=skip, limit=limit)

    def get_session_statistics(self, session_id: int) -> dict:
        if not self.session_repo.exists(session_id):
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Attendance session with id {session_id} not found"
            )
        
        present_count = self.attendance_repo.get_present_count(session_id)
        absent_count = self.attendance_repo.get_absent_count(session_id)
        
        return {
            "session_id": session_id,
            "present_count": present_count,
            "absent_count": absent_count,
            "total_count": present_count + absent_count
        }
