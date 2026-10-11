from typing import Optional, List
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, func
from app.models.student import Student, StudentStatus
from app.models.attendance import Attendance, AttendanceStatus
from app.models.attendance_session import SessionStatus
from app.repositories.base_repository import BaseRepository

class StudentRepository(BaseRepository[Student]):
    def __init__(self, db: Session):
        super().__init__(Student, db)

    def get_by_student_id(self, student_id: str) -> Optional[Student]:
        return self.db.query(Student).filter(Student.student_id == student_id).first()

    def get_by_qr_token(self, qr_token: str) -> Optional[Student]:
        return self.db.query(Student).filter(Student.qr_token == qr_token).first()

    def get_by_class(self, class_id: int, skip: int = 0, limit: int = 100) -> List[Student]:
        return self.db.query(Student).filter(Student.class_id == class_id).offset(skip).limit(limit).all()

    def get_active_students(self, skip: int = 0, limit: int = 100) -> List[Student]:
        return self.db.query(Student).filter(Student.status == StudentStatus.ACTIVE).offset(skip).limit(limit).all()

    def get_active_students_count(self) -> int:
        return self.db.query(Student).filter(Student.status == StudentStatus.ACTIVE).count()

    def search_by_name(self, name: str, skip: int = 0, limit: int = 100) -> List[Student]:
        # Use parameterized query to prevent SQL injection
        search_pattern = f"%{name}%"
        return self.db.query(Student).filter(
            Student.first_name.ilike(search_pattern) | 
            Student.last_name.ilike(search_pattern)
        ).offset(skip).limit(limit).all()

    def filter_students(
        self,
        skip: int = 0,
        limit: int = 100,
        class_id: Optional[int] = None,
        grade: Optional[str] = None,
        section: Optional[str] = None,
        status: Optional[StudentStatus] = None,
        search: Optional[str] = None,
        sort_by: Optional[str] = None,
        sort_order: Optional[str] = None
    ) -> List[Student]:
        query = self.db.query(Student)
        
        # Apply filters
        if class_id is not None:
            query = query.filter(Student.class_id == class_id)
        
        if grade is not None:
            query = query.filter(Student.grade == grade)
        
        if section is not None:
            query = query.filter(Student.section == section)
        
        if status is not None:
            query = query.filter(Student.status == status)
        
        if search is not None:
            # Use parameterized query to prevent SQL injection
            search_pattern = f"%{search}%"
            query = query.filter(
                or_(
                    Student.first_name.ilike(search_pattern),
                    Student.last_name.ilike(search_pattern),
                    Student.student_id.ilike(search_pattern)
                )
            )
        
        # Apply sorting
        if sort_by is not None:
            sort_column = getattr(Student, sort_by, None)
            if sort_column is not None:
                if sort_order == "desc":
                    query = query.order_by(sort_column.desc())
                else:
                    query = query.order_by(sort_column.asc())
        
        return query.offset(skip).limit(limit).all()

    def count_students(
        self,
        class_id: Optional[int] = None,
        grade: Optional[str] = None,
        section: Optional[str] = None,
        status: Optional[StudentStatus] = None,
        search: Optional[str] = None
    ) -> int:
        query = self.db.query(Student)
        
        # Apply filters
        if class_id is not None:
            query = query.filter(Student.class_id == class_id)
        
        if grade is not None:
            query = query.filter(Student.grade == grade)
        
        if section is not None:
            query = query.filter(Student.section == section)
        
        if status is not None:
            query = query.filter(Student.status == status)
        
        if search is not None:
            # Use parameterized query to prevent SQL injection
            search_pattern = f"%{search}%"
            query = query.filter(
                or_(
                    Student.first_name.ilike(search_pattern),
                    Student.last_name.ilike(search_pattern),
                    Student.student_id.ilike(search_pattern)
                )
            )
        
        return query.count()

    def calculate_attendance_percentage(self, student_id: int) -> float:
        """
        Calculate attendance percentage for a student.
        Formula: present sessions / applicable attendance sessions * 100
        Applicable sessions = CLOSED sessions for the student's class
        """
        # Get the student's class
        student = self.get_by_id(student_id)
        if not student or not student.class_id:
            return 0.0
        
        # Get all CLOSED sessions for the student's class
        from app.models.attendance_session import AttendanceSession
        applicable_sessions = self.db.query(AttendanceSession).filter(
            AttendanceSession.class_id == student.class_id,
            AttendanceSession.status == SessionStatus.CLOSED
        ).all()
        
        if not applicable_sessions:
            return 0.0
        
        applicable_session_ids = [s.id for s in applicable_sessions]
        
        # Count present attendance records for these sessions
        present_count = self.db.query(Attendance).filter(
            Attendance.student_id == student_id,
            Attendance.session_id.in_(applicable_session_ids),
            Attendance.status == AttendanceStatus.PRESENT
        ).count()
        
        # Calculate percentage
        percentage = (present_count / len(applicable_sessions)) * 100
        return round(percentage, 2)

    def get_critical_attendance_students(self, threshold: float = 50.0) -> List[Student]:
        """
        Get students with attendance percentage below the threshold.
        """
        students = self.get_active_students()
        critical_students = []
        
        for student in students:
            attendance_pct = self.calculate_attendance_percentage(student.id)
            if attendance_pct < threshold:
                critical_students.append(student)
        
        return critical_students
