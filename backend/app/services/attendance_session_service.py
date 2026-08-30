from typing import List
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from datetime import datetime
from app.repositories.attendance_session_repository import AttendanceSessionRepository
from app.repositories.class_repository import ClassRepository
from app.repositories.user_repository import UserRepository
from app.schemas.attendance_session import AttendanceSessionCreate, AttendanceSessionUpdate
from app.models.attendance_session import AttendanceSession, SessionStatus

class AttendanceSessionService:
    def __init__(self, db: Session):
        self.db = db
        self.session_repo = AttendanceSessionRepository(db)
        self.class_repo = ClassRepository(db)
        self.user_repo = UserRepository(db)

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
