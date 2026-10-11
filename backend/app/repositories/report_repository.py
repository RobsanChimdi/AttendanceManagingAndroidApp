from typing import List, Optional, Dict, Any
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, func
from datetime import date, datetime, timedelta
from app.models.attendance import Attendance, AttendanceStatus, AttendanceMethod
from app.models.attendance_session import AttendanceSession, SessionStatus
from app.models.student import Student
from app.models.class_model import Class

class ReportRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_attendance_records_with_filters(
        self,
        date: Optional[date] = None,
        date_from: Optional[date] = None,
        date_to: Optional[date] = None,
        grade: Optional[str] = None,
        class_id: Optional[int] = None,
        section: Optional[str] = None,
        student_id: Optional[int] = None,
        status: Optional[str] = None,
        method: Optional[str] = None,
        skip: int = 0,
        limit: int = 100
    ) -> tuple[List[Dict[str, Any]], int]:
        """
        Get attendance records with filters and pagination.
        Returns (records, total_count)
        """
        # Build base query with joins
        query = self.db.query(
            Attendance.id,
            AttendanceSession.date.label('date'),
            Attendance.student_id,
            Student.first_name.label('student_first_name'),
            Student.last_name.label('student_last_name'),
            Student.student_id.label('student_id_str'),
            Student.grade.label('grade'),
            Student.section.label('section'),
            Class.name.label('class_name'),
            Attendance.status.label('status'),
            Attendance.method.label('method'),
            Attendance.recognized_at.label('recognized_at')
        ).join(
            AttendanceSession, Attendance.session_id == AttendanceSession.id
        ).join(
            Student, Attendance.student_id == Student.id
        ).outerjoin(
            Class, Student.class_id == Class.id
        )

        # Apply filters
        conditions = []
        
        if date:
            conditions.append(AttendanceSession.date == date)
        elif date_from and date_to:
            conditions.append(AttendanceSession.date.between(date_from, date_to))
        elif date_from:
            conditions.append(AttendanceSession.date >= date_from)
        elif date_to:
            conditions.append(AttendanceSession.date <= date_to)
        
        if grade:
            conditions.append(Student.grade == grade)
        
        if class_id:
            conditions.append(Student.class_id == class_id)
        
        if section:
            conditions.append(Student.section == section)
        
        if student_id:
            conditions.append(Attendance.student_id == student_id)
        
        if status:
            conditions.append(Attendance.status == status)
        
        if method:
            conditions.append(Attendance.method == method)
        
        if conditions:
            query = query.filter(and_(*conditions))
        
        # Get total count
        total_count = query.count()
        
        # Apply pagination
        records = query.offset(skip).limit(limit).all()
        
        # Format records
        formatted_records = []
        for record in records:
            formatted_records.append({
                'id': record.id,
                'date': record.date,
                'student_id': record.student_id,
                'student_name': f"{record.student_first_name} {record.student_last_name}",
                'student_id_str': record.student_id_str,
                'grade': record.grade,
                'section': record.section,
                'class_name': record.class_name,
                'status': record.status.value if record.status else None,
                'method': record.method.value if record.method else None,
                'recognized_at': record.recognized_at
            })
        
        return formatted_records, total_count

    def get_daily_attendance_report(
        self,
        report_date: date,
        grade: Optional[str] = None,
        class_id: Optional[int] = None,
        section: Optional[str] = None,
        skip: int = 0,
        limit: int = 100
    ) -> tuple[List[Dict[str, Any]], int, Dict[str, Any]]:
        """
        Get daily attendance report with summary.
        Returns (records, total_count, summary)
        """
        records, total_count = self.get_attendance_records_with_filters(
            date=report_date,
            grade=grade,
            class_id=class_id,
            section=section,
            skip=skip,
            limit=limit
        )
        
        # Calculate summary
        summary = self._calculate_summary(records)
        
        return records, total_count, summary

    def get_weekly_attendance_report(
        self,
        week_start: date,
        grade: Optional[str] = None,
        class_id: Optional[int] = None,
        section: Optional[str] = None,
        skip: int = 0,
        limit: int = 100
    ) -> tuple[List[Dict[str, Any]], int, Dict[str, Any]]:
        """
        Get weekly attendance report (7 days from week_start).
        Returns (records, total_count, summary)
        """
        week_end = week_start + timedelta(days=6)
        
        records, total_count = self.get_attendance_records_with_filters(
            date_from=week_start,
            date_to=week_end,
            grade=grade,
            class_id=class_id,
            section=section,
            skip=skip,
            limit=limit
        )
        
        summary = self._calculate_summary(records)
        
        return records, total_count, summary

    def get_monthly_attendance_report(
        self,
        year: int,
        month: int,
        grade: Optional[str] = None,
        class_id: Optional[int] = None,
        section: Optional[str] = None,
        skip: int = 0,
        limit: int = 100
    ) -> tuple[List[Dict[str, Any]], int, Dict[str, Any]]:
        """
        Get monthly attendance report.
        Returns (records, total_count, summary)
        """
        date_from = date(year, month, 1)
        if month == 12:
            date_to = date(year + 1, 1, 1) - timedelta(days=1)
        else:
            date_to = date(year, month + 1, 1) - timedelta(days=1)
        
        records, total_count = self.get_attendance_records_with_filters(
            date_from=date_from,
            date_to=date_to,
            grade=grade,
            class_id=class_id,
            section=section,
            skip=skip,
            limit=limit
        )
        
        summary = self._calculate_summary(records)
        
        return records, total_count, summary

    def get_student_attendance_report(
        self,
        student_id: int,
        date_from: Optional[date] = None,
        date_to: Optional[date] = None,
        skip: int = 0,
        limit: int = 100
    ) -> tuple[List[Dict[str, Any]], int, Dict[str, Any]]:
        """
        Get attendance report for a specific student.
        Returns (records, total_count, summary)
        """
        records, total_count = self.get_attendance_records_with_filters(
            student_id=student_id,
            date_from=date_from,
            date_to=date_to,
            skip=skip,
            limit=limit
        )
        
        summary = self._calculate_summary(records)
        
        return records, total_count, summary

    def get_class_attendance_report(
        self,
        class_id: int,
        date_from: Optional[date] = None,
        date_to: Optional[date] = None,
        skip: int = 0,
        limit: int = 100
    ) -> tuple[List[Dict[str, Any]], int, Dict[str, Any]]:
        """
        Get attendance report for a specific class.
        Returns (records, total_count, summary)
        """
        records, total_count = self.get_attendance_records_with_filters(
            class_id=class_id,
            date_from=date_from,
            date_to=date_to,
            skip=skip,
            limit=limit
        )
        
        summary = self._calculate_summary(records)
        
        return records, total_count, summary

    def get_critical_attendance_report(
        self,
        threshold: float = 50.0,
        grade: Optional[str] = None,
        class_id: Optional[int] = None,
        section: Optional[str] = None,
        skip: int = 0,
        limit: int = 100
    ) -> tuple[List[Dict[str, Any]], int]:
        """
        Get report of students with critical attendance (below threshold).
        Returns (records, total_count)
        """
        from app.repositories.student_repository import StudentRepository
        student_repo = StudentRepository(self.db)
        
        # Get students with critical attendance
        critical_students = student_repo.get_critical_attendance_students(threshold)
        
        # Apply additional filters
        filtered_students = []
        for student in critical_students:
            if grade and student.grade != grade:
                continue
            if class_id and student.class_id != class_id:
                continue
            if section and student.section != section:
                continue
            filtered_students.append(student)
        
        # Apply pagination
        paginated_students = filtered_students[skip:skip + limit]
        
        # Format records
        records = []
        for student in paginated_students:
            attendance_pct = student_repo.calculate_attendance_percentage(student.id)
            records.append({
                'student_id': student.id,
                'student_name': f"{student.first_name} {student.last_name}",
                'student_id_str': student.student_id,
                'grade': student.grade,
                'section': student.section,
                'attendance_percentage': attendance_pct,
                'required_percentage': threshold,
                'guardian_name': student.guardian_name,
                'guardian_phone': student.guardian_phone,
                'is_critical': attendance_pct < threshold
            })
        
        return records, len(filtered_students)

    def _calculate_summary(self, records: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Calculate summary statistics from records."""
        total = len(records)
        if total == 0:
            return {
                'total_records': 0,
                'present_count': 0,
                'absent_count': 0,
                'present_percentage': 0.0,
                'absent_percentage': 0.0,
                'face_count': 0,
                'qr_count': 0,
                'manual_count': 0
            }
        
        present_count = sum(1 for r in records if r['status'] == AttendanceStatus.PRESENT.value)
        absent_count = sum(1 for r in records if r['status'] == AttendanceStatus.ABSENT.value)
        face_count = sum(1 for r in records if r['method'] == AttendanceMethod.FACE.value)
        qr_count = sum(1 for r in records if r['method'] == AttendanceMethod.QR.value)
        manual_count = sum(1 for r in records if r['method'] == AttendanceMethod.MANUAL.value)
        
        return {
            'total_records': total,
            'present_count': present_count,
            'absent_count': absent_count,
            'present_percentage': round((present_count / total) * 100, 2),
            'absent_percentage': round((absent_count / total) * 100, 2),
            'face_count': face_count,
            'qr_count': qr_count,
            'manual_count': manual_count
        }
