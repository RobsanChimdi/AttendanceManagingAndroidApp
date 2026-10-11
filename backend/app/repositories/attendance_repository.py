from typing import Optional, List
from sqlalchemy.orm import Session
from sqlalchemy import and_
from app.models.attendance import Attendance, AttendanceStatus
from app.repositories.base_repository import BaseRepository

class AttendanceRepository(BaseRepository[Attendance]):
    def __init__(self, db: Session):
        super().__init__(Attendance, db)

    def get_by_session(self, session_id: int, skip: int = 0, limit: int = 100) -> List[Attendance]:
        return self.db.query(Attendance).filter(
            Attendance.session_id == session_id
        ).offset(skip).limit(limit).all()

    def get_by_student(self, student_id: int, skip: int = 0, limit: int = 100) -> List[Attendance]:
        return self.db.query(Attendance).filter(
            Attendance.student_id == student_id
        ).offset(skip).limit(limit).all()

    def get_by_session_and_student(self, session_id: int, student_id: int) -> Optional[Attendance]:
        return self.db.query(Attendance).filter(
            Attendance.session_id == session_id,
            Attendance.student_id == student_id
        ).first()

    def get_present_count(self, session_id: int) -> int:
        return self.db.query(Attendance).filter(
            Attendance.session_id == session_id,
            Attendance.status == AttendanceStatus.PRESENT
        ).count()

    def get_absent_count(self, session_id: int) -> int:
        return self.db.query(Attendance).filter(
            Attendance.session_id == session_id,
            Attendance.status == AttendanceStatus.ABSENT
        ).count()
