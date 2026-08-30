from typing import List, Dict, Any
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from datetime import datetime
from app.repositories.attendance_session_repository import AttendanceSessionRepository
from app.repositories.class_repository import ClassRepository
from app.repositories.user_repository import UserRepository
from app.repositories.student_repository import StudentRepository
from app.repositories.attendance_repository import AttendanceRepository
from app.schemas.attendance_session import AttendanceSessionCreate, AttendanceSessionUpdate
from app.models.attendance_session import AttendanceSession, SessionStatus
from app.models.attendance import AttendanceStatus, AttendanceMethod

class AttendanceSessionService:
    def __init__(self, db: Session):
        self.db = db
        self.session_repo = AttendanceSessionRepository(db)
        self.class_repo = ClassRepository(db)
        self.user_repo = UserRepository(db)
        self.student_repo = StudentRepository(db)
        self.attendance_repo = AttendanceRepository(db)

    def get_session(self, session_id: int) -> AttendanceSession:
        session = self.session_repo.get(session_id)
        if not session:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Attendance session with id {session_id} not found"
            )
        return session

    def list_sessions(self, skip: int = 0, limit: int = 100) -> List[AttendanceSession]:
        return self.session_repo.get_all(skip=skip, limit=limit)

    def create_session(self, session_in: AttendanceSessionCreate) -> AttendanceSession:
        # Validate class exists
        if not self.class_repo.exists(session_in.class_id):
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Class with id {session_in.class_id} not found"
            )
        
        # Validate teacher exists
        if not self.user_repo.exists(session_in.teacher_id):
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"User with id {session_in.teacher_id} not found"
            )
        
        # Check if session already exists for this class and date
        existing = self.session_repo.get_by_class_and_date(session_in.class_id, session_in.date)
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Attendance session already exists for class {session_in.class_id} on {session_in.date}"
            )
        
        session_data = session_in.model_dump()
        session_data["started_at"] = datetime.utcnow()
        
        return self.session_repo.create(session_data)

    def update_session(self, session_id: int, session_in: AttendanceSessionUpdate) -> AttendanceSession:
        session = self.get_session(session_id)
        update_data = session_in.model_dump(exclude_unset=True)
        
        # Handle status changes
        if session_in.status == SessionStatus.CLOSED and session.status != SessionStatus.CLOSED:
            update_data["closed_at"] = datetime.utcnow()
        
        return self.session_repo.update(session, update_data)

    def delete_session(self, session_id: int) -> AttendanceSession:
        session = self.get_session(session_id)
        return self.session_repo.delete(session_id)

    def get_sessions_by_class(self, class_id: int, skip: int = 0, limit: int = 100) -> List[AttendanceSession]:
        if not self.class_repo.exists(class_id):
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Class with id {class_id} not found"
            )
        return self.session_repo.get_by_class(class_id, skip=skip, limit=limit)

    def get_sessions_by_teacher(self, teacher_id: int, skip: int = 0, limit: int = 100) -> List[AttendanceSession]:
        if not self.user_repo.exists(teacher_id):
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"User with id {teacher_id} not found"
            )
        return self.session_repo.get_by_teacher(teacher_id, skip=skip, limit=limit)

    def get_open_sessions(self, skip: int = 0, limit: int = 100) -> List[AttendanceSession]:
        return self.session_repo.get_open_sessions(skip=skip, limit=limit)

    def start_session(self, session_id: int) -> AttendanceSession:
        """Start an attendance session and mark all students as expected."""
        session = self.get_session(session_id)
        
        if session.status == SessionStatus.OPEN:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Session is already open"
            )
        
        if session.status == SessionStatus.CLOSED:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Cannot restart a closed session"
            )
        
        # Update session status to OPEN
        update_data = {
            "status": SessionStatus.OPEN,
            "started_at": datetime.utcnow()
        }
        session = self.session_repo.update(session, update_data)
        
        return session

    def close_session(self, session_id: int) -> Dict[str, Any]:
        """Close an attendance session and mark remaining students as absent."""
        session = self.get_session(session_id)
        
        if session.status != SessionStatus.OPEN:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Cannot close session with status {session.status.value}"
            )
        
        # Use transaction to ensure atomicity
        try:
            # Get all students in the class
            students = self.student_repo.get_by_class(session.class_id)
            student_ids = [s.id for s in students]
            
            # Get all attendance records for this session
            attendance_records = self.attendance_repo.get_by_session(session_id)
            present_student_ids = {r.student_id for r in attendance_records if r.status == AttendanceStatus.PRESENT}
            
            # Mark remaining students as absent
            absent_count = 0
            for student_id in student_ids:
                if student_id not in present_student_ids:
                    self.attendance_repo.create({
                        "session_id": session_id,
                        "student_id": student_id,
                        "status": AttendanceStatus.ABSENT,
                        "method": AttendanceMethod.MANUAL,  # Auto-marked as manual
                        "recognized_at": datetime.utcnow()
                    })
                    absent_count += 1
            
            # Close the session
            update_data = {
                "status": SessionStatus.CLOSED,
                "closed_at": datetime.utcnow()
            }
            session = self.session_repo.update(session, update_data)
            
            # Get final statistics
            final_attendance = self.attendance_repo.get_by_session(session_id)
            present_count = self.attendance_repo.get_present_count(session_id)
            absent_count = self.attendance_repo.get_absent_count(session_id)
            total_count = len(students)
            attendance_percentage = (present_count / total_count * 100) if total_count > 0 else 0
            
            return {
                "session": session,
                "total_students": total_count,
                "present_count": present_count,
                "absent_count": absent_count,
                "attendance_percentage": round(attendance_percentage, 2),
                "auto_marked_absent": absent_count
            }
            
        except Exception as e:
            self.db.rollback()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to close session: {str(e)}"
            )

    def get_session_statistics(self, session_id: int) -> Dict[str, Any]:
        """Get attendance statistics for a session."""
        session = self.get_session(session_id)
        
        # Get all students in the class
        students = self.student_repo.get_by_class(session.class_id)
        total_count = len(students)
        
        # Get attendance records
        present_count = self.attendance_repo.get_present_count(session_id)
        absent_count = self.attendance_repo.get_absent_count(session_id)
        attendance_percentage = (present_count / total_count * 100) if total_count > 0 else 0
        remaining_count = total_count - present_count - absent_count
        
        return {
            "session_id": session_id,
            "status": session.status.value,
            "total_students": total_count,
            "present_count": present_count,
            "absent_count": absent_count,
            "remaining_count": remaining_count,
            "attendance_percentage": round(attendance_percentage, 2),
            "started_at": session.started_at.isoformat() if session.started_at else None,
            "closed_at": session.closed_at.isoformat() if session.closed_at else None
        }

    def get_session_attendance(self, session_id: int) -> List[Dict[str, Any]]:
        """Get all attendance records for a session with student details."""
        session = self.get_session(session_id)
        
        attendance_records = self.attendance_repo.get_by_session(session_id)
        result = []
        
        for record in attendance_records:
            student = self.student_repo.get_by_id(record.student_id)
            if student:
                result.append({
                    "attendance_id": record.id,
                    "student_id": student.id,
                    "student_name": f"{student.firstName} {student.lastName}",
                    "student_id_str": student.studentId,
                    "status": record.status.value,
                    "method": record.method.value if record.method else None,
                    "recognized_at": record.recognized_at.isoformat() if record.recognized_at else None
                })
        
        return result
