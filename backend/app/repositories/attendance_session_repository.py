from typing import Optional, List
from sqlalchemy.orm import Session
from sqlalchemy import and_
from datetime import date
from app.models.attendance_session import AttendanceSession, SessionStatus
from app.repositories.base_repository import BaseRepository

class AttendanceSessionRepository(BaseRepository[AttendanceSession]):
    def __init__(self, db: Session):
        super().__init__(AttendanceSession, db)

    def get_by_class_and_date(self, class_id: int, date) -> Optional[AttendanceSession]:
        return self.db.query(AttendanceSession).filter(
            AttendanceSession.class_id == class_id,
            AttendanceSession.date == date
        ).first()

    def get_open_sessions(self, skip: int = 0, limit: int = 100) -> List[AttendanceSession]:
        return self.db.query(AttendanceSession).filter(
            AttendanceSession.status == SessionStatus.OPEN
        ).offset(skip).limit(limit).all()

    def get_by_class(self, class_id: int, skip: int = 0, limit: int = 100) -> List[AttendanceSession]:
        return self.db.query(AttendanceSession).filter(
            AttendanceSession.class_id == class_id
        ).offset(skip).limit(limit).all()

    def get_by_teacher(self, teacher_id: int, skip: int = 0, limit: int = 100) -> List[AttendanceSession]:
        return self.db.query(AttendanceSession).filter(
            AttendanceSession.teacher_id == teacher_id
        ).offset(skip).limit(limit).all()

    def get_sessions_by_date(self, date: date) -> List[AttendanceSession]:
        return self.db.query(AttendanceSession).filter(
            AttendanceSession.date == date
        ).all()

    def get_closed_sessions(self, skip: int = 0, limit: int = 100) -> List[AttendanceSession]:
        return self.db.query(AttendanceSession).filter(
            AttendanceSession.status == SessionStatus.CLOSED
        ).offset(skip).limit(limit).all()
