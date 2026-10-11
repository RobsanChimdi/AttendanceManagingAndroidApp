from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func, and_, or_
from typing import Dict, Any, List
from datetime import datetime, timedelta
from app.database import get_db
from app.repositories.student_repository import StudentRepository
from app.repositories.class_repository import ClassRepository
from app.repositories.user_repository import UserRepository
from app.repositories.attendance_repository import AttendanceRepository
from app.repositories.attendance_session_repository import AttendanceSessionRepository
from app.repositories.notification_repository import NotificationRepository
from app.models.attendance import AttendanceStatus
from app.models.attendance_session import SessionStatus
from app.models.notification import NotificationStatus

router = APIRouter(prefix="/dashboard", tags=["Dashboard"])

@router.get("/statistics")
async def get_dashboard_statistics(db: Session = Depends(get_db)):
    """
    Get overall dashboard statistics for admin view.
    """
    try:
        student_repo = StudentRepository(db)
        class_repo = ClassRepository(db)
        user_repo = UserRepository(db)
        attendance_repo = AttendanceRepository(db)
        session_repo = AttendanceSessionRepository(db)
        notification_repo = NotificationRepository(db)
        
        # Total students
        total_students = student_repo.get_active_students_count()
        
        # Total teachers
        total_teachers = user_repo.get_teachers_count()
        
        # Total classes
        total_classes = class_repo.get_all_count()
        
        # Today's attendance
        today = datetime.utcnow().date()
        today_sessions = session_repo.get_sessions_by_date(today)
        
        present_today = 0
        absent_today = 0
        
        if today_sessions:
            session_ids = [s.id for s in today_sessions]
            for session_id in session_ids:
                present_today += attendance_repo.get_present_count(session_id)
                absent_today += attendance_repo.get_absent_count(session_id)
        
        # Average attendance percentage (overall)
        all_closed_sessions = session_repo.get_closed_sessions()
        total_sessions = len(all_closed_sessions)
        
        if total_sessions > 0:
            total_present = 0
            total_possible = 0
            for session in all_closed_sessions:
                present = attendance_repo.get_present_count(session.id)
                students_in_class = student_repo.get_by_class(session.class_id)
                total_possible += len(students_in_class)
                total_present += present
            
            average_attendance = (total_present / total_possible * 100) if total_possible > 0 else 0
        else:
            average_attendance = 0.0
        
        # Critical students (below 50% attendance)
        critical_students = student_repo.get_critical_attendance_students(threshold=50.0)
        critical_count = len(critical_students)
        
        return {
            "total_students": total_students,
            "total_teachers": total_teachers,
            "total_classes": total_classes,
            "present_today": present_today,
            "absent_today": absent_today,
            "average_attendance": round(average_attendance, 2),
            "critical_students": critical_count,
            "today_sessions": len(today_sessions)
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get dashboard statistics: {e}"
        )

@router.get("/teacher-statistics/{teacher_id}")
async def get_teacher_dashboard_statistics(teacher_id: int, db: Session = Depends(get_db)):
    """
    Get dashboard statistics for a specific teacher.
    """
    try:
        student_repo = StudentRepository(db)
        class_repo = ClassRepository(db)
        attendance_repo = AttendanceRepository(db)
        session_repo = AttendanceSessionRepository(db)
        
        # Get classes taught by this teacher
        teacher_classes = class_repo.get_by_teacher(teacher_id)
        class_ids = [c.id for c in teacher_classes]
        
        # Total students in teacher's classes
        total_students = 0
        for class_id in class_ids:
            students = student_repo.get_by_class(class_id)
            total_students += len(students)
        
        # Today's attendance for teacher's classes
        today = datetime.utcnow().date()
        today_sessions = [s for s in session_repo.get_sessions_by_date(today) if s.class_id in class_ids]
        
        present_today = 0
        absent_today = 0
        
        for session in today_sessions:
            present_today += attendance_repo.get_present_count(session.id)
            absent_today += attendance_repo.get_absent_count(session.id)
        
        # Average attendance for teacher's classes
        teacher_closed_sessions = [s for s in session_repo.get_closed_sessions() if s.class_id in class_ids]
        
        if teacher_closed_sessions:
            total_present = 0
            total_possible = 0
            for session in teacher_closed_sessions:
                present = attendance_repo.get_present_count(session.id)
                students_in_class = student_repo.get_by_class(session.class_id)
                total_possible += len(students_in_class)
                total_present += present
            
            average_attendance = (total_present / total_possible * 100) if total_possible > 0 else 0
        else:
            average_attendance = 0.0
        
        # Critical students in teacher's classes
        critical_students = []
        for class_id in class_ids:
            students = student_repo.get_by_class(class_id)
            for student in students:
                attendance_pct = student_repo.calculate_attendance_percentage(student.id)
                if attendance_pct < 50.0:
                    critical_students.append(student)
        
        return {
            "teacher_id": teacher_id,
            "total_students": total_students,
            "total_classes": len(class_ids),
            "present_today": present_today,
            "absent_today": absent_today,
            "average_attendance": round(average_attendance, 2),
            "critical_students": len(critical_students),
            "today_sessions": len(today_sessions)
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get teacher dashboard statistics: {e}"
        )

@router.get("/analytics/attendance-trend")
async def get_attendance_trend(
    days: int = 30,
    db: Session = Depends(get_db)
):
    """
    Get attendance trend over the specified number of days.
    """
    try:
        session_repo = AttendanceSessionRepository(db)
        attendance_repo = AttendanceRepository(db)
        student_repo = StudentRepository(db)
        
        end_date = datetime.utcnow().date()
        start_date = end_date - timedelta(days=days)
        
        trend_data = []
        
        current_date = start_date
        while current_date <= end_date:
            sessions = session_repo.get_sessions_by_date(current_date)
            
            total_present = 0
            total_possible = 0
            
            for session in sessions:
                present = attendance_repo.get_present_count(session.id)
                students = student_repo.get_by_class(session.class_id)
                total_possible += len(students)
                total_present += present
            
            attendance_rate = (total_present / total_possible * 100) if total_possible > 0 else 0
            
            trend_data.append({
                "date": current_date.isoformat(),
                "present": total_present,
                "total": total_possible,
                "attendance_rate": round(attendance_rate, 2)
            })
            
            current_date += timedelta(days=1)
        
        return {
            "trend": trend_data,
            "period": f"{days} days"
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get attendance trend: {e}"
        )

@router.get("/analytics/class-comparison")
async def get_class_comparison(db: Session = Depends(get_db)):
    """
    Get attendance comparison across all classes.
    """
    try:
        class_repo = ClassRepository(db)
        student_repo = StudentRepository(db)
        session_repo = AttendanceSessionRepository(db)
        attendance_repo = AttendanceRepository(db)
        
        classes = class_repo.get_all()
        comparison_data = []
        
        for cls in classes:
            students = student_repo.get_by_class(cls.id)
            total_students = len(students)
            
            # Get closed sessions for this class
            closed_sessions = [s for s in session_repo.get_closed_sessions() if s.class_id == cls.id]
            
            if closed_sessions:
                total_present = 0
                total_possible = 0
                
                for session in closed_sessions:
                    present = attendance_repo.get_present_count(session.id)
                    total_possible += total_students
                    total_present += present
                
                attendance_rate = (total_present / total_possible * 100) if total_possible > 0 else 0
            else:
                attendance_rate = 0.0
            
            # Critical students in this class
            critical_count = 0
            for student in students:
                attendance_pct = student_repo.calculate_attendance_percentage(student.id)
                if attendance_pct < 50.0:
                    critical_count += 1
            
            comparison_data.append({
                "class_id": cls.id,
                "class_name": cls.name,
                "grade": cls.grade,
                "section": cls.section,
                "total_students": total_students,
                "attendance_rate": round(attendance_rate, 2),
                "critical_students": critical_count,
                "total_sessions": len(closed_sessions)
            })
        
        return {
            "classes": comparison_data
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get class comparison: {e}"
        )

@router.get("/analytics/grade-comparison")
async def get_grade_comparison(db: Session = Depends(get_db)):
    """
    Get attendance comparison across grades.
    """
    try:
        student_repo = StudentRepository(db)
        session_repo = AttendanceSessionRepository(db)
        attendance_repo = AttendanceRepository(db)
        
        # Get all unique grades
        students = student_repo.get_all()
        grades = set()
        for student in students:
            if student.grade:
                grades.add(student.grade)
        
        grade_data = []
        
        for grade in sorted(grades):
            grade_students = [s for s in students if s.grade == grade]
            total_students = len(grade_students)
            
            # Calculate overall attendance for this grade
            total_present = 0
            total_possible = 0
            
            for student in grade_students:
                attendance_pct = student_repo.calculate_attendance_percentage(student.id)
                total_present += attendance_pct
                total_possible += 100
            
            average_attendance = (total_present / total_possible) if total_possible > 0 else 0
            
            # Critical students in this grade
            critical_count = 0
            for student in grade_students:
                attendance_pct = student_repo.calculate_attendance_percentage(student.id)
                if attendance_pct < 50.0:
                    critical_count += 1
            
            grade_data.append({
                "grade": grade,
                "total_students": total_students,
                "average_attendance": round(average_attendance, 2),
                "critical_students": critical_count
            })
        
        return {
            "grades": grade_data
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get grade comparison: {e}"
        )

@router.get("/analytics/present-absent-distribution")
async def get_present_absent_distribution(db: Session = Depends(get_db)):
    """
    Get present vs absent distribution for today.
    """
    try:
        session_repo = AttendanceSessionRepository(db)
        attendance_repo = AttendanceRepository(db)
        student_repo = StudentRepository(db)
        
        today = datetime.utcnow().date()
        today_sessions = session_repo.get_sessions_by_date(today)
        
        total_present = 0
        total_absent = 0
        total_expected = 0
        
        for session in today_sessions:
            present = attendance_repo.get_present_count(session.id)
            absent = attendance_repo.get_absent_count(session.id)
            students = student_repo.get_by_class(session.class_id)
            
            total_present += present
            total_absent += absent
            total_expected += len(students)
        
        # Students not yet marked (session still open)
        not_marked = total_expected - total_present - total_absent
        
        return {
            "present": total_present,
            "absent": total_absent,
            "not_marked": not_marked if not_marked > 0 else 0,
            "total_expected": total_expected,
            "distribution": {
                "present_percentage": round((total_present / total_expected * 100) if total_expected > 0 else 0, 2),
                "absent_percentage": round((total_absent / total_expected * 100) if total_expected > 0 else 0, 2),
                "not_marked_percentage": round((not_marked / total_expected * 100) if total_expected > 0 else 0, 2)
            }
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get present/absent distribution: {e}"
        )

@router.get("/analytics/critical-attendance-breakdown")
async def get_critical_attendance_breakdown(db: Session = Depends(get_db)):
    """
    Get breakdown of critical attendance by class and grade.
    """
    try:
        student_repo = StudentRepository(db)
        class_repo = ClassRepository(db)
        
        critical_students = student_repo.get_critical_attendance_students(threshold=50.0)
        
        # Breakdown by class
        class_breakdown = {}
        for student in critical_students:
            if student.class_id:
                if student.class_id not in class_breakdown:
                    cls = class_repo.get_by_id(student.class_id)
                    class_breakdown[student.class_id] = {
                        "class_name": cls.name if cls else "Unknown",
                        "grade": cls.grade if cls else "Unknown",
                        "section": cls.section if cls else "Unknown",
                        "count": 0
                    }
                class_breakdown[student.class_id]["count"] += 1
        
        # Breakdown by grade
        grade_breakdown = {}
        for student in critical_students:
            grade = student.grade or "Unknown"
            if grade not in grade_breakdown:
                grade_breakdown[grade] = 0
            grade_breakdown[grade] += 1
        
        return {
            "total_critical": len(critical_students),
            "by_class": list(class_breakdown.values()),
            "by_grade": [{"grade": k, "count": v} for k, v in grade_breakdown.items()]
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get critical attendance breakdown: {e}"
        )
