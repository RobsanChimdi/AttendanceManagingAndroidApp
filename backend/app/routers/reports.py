from fastapi import APIRouter, Depends, HTTPException, status, Query
from fastapi.responses import Response
from sqlalchemy.orm import Session
from typing import Optional
from datetime import date
from app.database import get_db
from app.repositories.report_repository import ReportRepository
from app.schemas.report import ReportFilter, AttendanceReportRecord, AttendanceReportResponse, ReportSummary
from app.utils.csv_export import CSVExportUtility
from app.utils.pdf_export import PDFExportUtility

router = APIRouter(prefix="/reports", tags=["Reports"])


def _attendance_report_response(records, total_count, skip, limit, summary=None):
    response = {"records": records, "total": total_count, "skip": skip, "limit": limit}
    if summary is not None:
        response["summary"] = summary
    return response


@router.get("/attendance")
async def get_attendance_report(
    report_date: Optional[date] = Query(None),
    date_from: Optional[date] = Query(None),
    date_to: Optional[date] = Query(None),
    grade: Optional[str] = Query(None),
    class_id: Optional[int] = Query(None),
    section: Optional[str] = Query(None),
    student_id: Optional[int] = Query(None),
    status: Optional[str] = Query(None),
    method: Optional[str] = Query(None),
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    db: Session = Depends(get_db),
):
    """Return real attendance records using the complete report filter set."""
    if report_date and (date_from or date_to):
        raise HTTPException(status_code=400, detail="Use report_date or a date range, not both")
    try:
        repository = ReportRepository(db)
        records, total_count = repository.get_attendance_records_with_filters(
            date=report_date, date_from=date_from, date_to=date_to, grade=grade,
            class_id=class_id, section=section, student_id=student_id,
            status=status, method=method, skip=skip, limit=limit,
        )
        return _attendance_report_response(
            records, total_count, skip, limit, repository._calculate_summary(records)
        )
    except HTTPException:
        raise
    except Exception:
        raise HTTPException(status_code=500, detail="Failed to generate attendance report")


@router.get("/attendance/csv")
async def export_attendance_csv(
    report_date: Optional[date] = Query(None),
    date_from: Optional[date] = Query(None),
    date_to: Optional[date] = Query(None),
    grade: Optional[str] = Query(None),
    class_id: Optional[int] = Query(None),
    section: Optional[str] = Query(None),
    student_id: Optional[int] = Query(None),
    status: Optional[str] = Query(None),
    method: Optional[str] = Query(None),
    db: Session = Depends(get_db),
):
    """Export the complete filtered attendance report as CSV."""
    if report_date and (date_from or date_to):
        raise HTTPException(status_code=400, detail="Use report_date or a date range, not both")
    try:
        records, _ = ReportRepository(db).get_attendance_records_with_filters(
            date=report_date, date_from=date_from, date_to=date_to, grade=grade,
            class_id=class_id, section=section, student_id=student_id,
            status=status, method=method, skip=0, limit=100000,
        )
        filename, csv_content = CSVExportUtility.generate_attendance_csv(records)
        return Response(content=csv_content, media_type="text/csv", headers={
            "Content-Disposition": f"attachment; filename={filename}"
        })
    except HTTPException:
        raise
    except Exception:
        raise HTTPException(status_code=500, detail="Failed to export attendance report")


@router.get("/attendance/pdf")
async def export_attendance_pdf(
    report_date: Optional[date] = Query(None),
    date_from: Optional[date] = Query(None),
    date_to: Optional[date] = Query(None),
    grade: Optional[str] = Query(None),
    class_id: Optional[int] = Query(None),
    section: Optional[str] = Query(None),
    student_id: Optional[int] = Query(None),
    status: Optional[str] = Query(None),
    method: Optional[str] = Query(None),
    db: Session = Depends(get_db),
):
    """Export the complete filtered attendance report as PDF."""
    if report_date and (date_from or date_to):
        raise HTTPException(status_code=400, detail="Use report_date or a date range, not both")
    try:
        records, _ = ReportRepository(db).get_attendance_records_with_filters(
            date=report_date, date_from=date_from, date_to=date_to, grade=grade,
            class_id=class_id, section=section, student_id=student_id,
            status=status, method=method, skip=0, limit=100000,
        )
        filename, pdf_content = PDFExportUtility.generate_attendance_pdf(
            records=records, title="Attendance Report"
        )
        return Response(content=pdf_content, media_type="application/pdf", headers={
            "Content-Disposition": f"attachment; filename={filename}"
        })
    except HTTPException:
        raise
    except Exception:
        raise HTTPException(status_code=500, detail="Failed to export attendance report")


@router.get("/attendance/daily")
async def get_daily_attendance_report(
    report_date: date = Query(..., description="Date of the report"),
    grade: Optional[str] = Query(None, description="Filter by grade"),
    class_id: Optional[int] = Query(None, description="Filter by class ID"),
    section: Optional[str] = Query(None, description="Filter by section"),
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    db: Session = Depends(get_db)
):
    """
    Get daily attendance report with optional filters.
    """
    try:
        report_repo = ReportRepository(db)
        records, total_count, summary = report_repo.get_daily_attendance_report(
            report_date=report_date,
            grade=grade,
            class_id=class_id,
            section=section,
            skip=skip,
            limit=limit
        )
        
        return {
            "date": report_date.isoformat(),
            "records": records,
            "total": total_count,
            "skip": skip,
            "limit": limit,
            "summary": summary
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to generate daily report: {e}"
        )

@router.get("/attendance/weekly")
async def get_weekly_attendance_report(
    week_start: date = Query(..., description="Start date of the week"),
    grade: Optional[str] = Query(None, description="Filter by grade"),
    class_id: Optional[int] = Query(None, description="Filter by class ID"),
    section: Optional[str] = Query(None, description="Filter by section"),
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    db: Session = Depends(get_db)
):
    """
    Get weekly attendance report (7 days from week_start).
    """
    try:
        report_repo = ReportRepository(db)
        records, total_count, summary = report_repo.get_weekly_attendance_report(
            week_start=week_start,
            grade=grade,
            class_id=class_id,
            section=section,
            skip=skip,
            limit=limit
        )
        
        return {
            "week_start": week_start.isoformat(),
            "week_end": (week_start + __import__('datetime').timedelta(days=6)).isoformat(),
            "records": records,
            "total": total_count,
            "skip": skip,
            "limit": limit,
            "summary": summary
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to generate weekly report: {e}"
        )

@router.get("/attendance/monthly")
async def get_monthly_attendance_report(
    year: int = Query(..., description="Year of the report"),
    month: int = Query(..., ge=1, le=12, description="Month of the report"),
    grade: Optional[str] = Query(None, description="Filter by grade"),
    class_id: Optional[int] = Query(None, description="Filter by class ID"),
    section: Optional[str] = Query(None, description="Filter by section"),
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    db: Session = Depends(get_db)
):
    """
    Get monthly attendance report.
    """
    try:
        report_repo = ReportRepository(db)
        records, total_count, summary = report_repo.get_monthly_attendance_report(
            year=year,
            month=month,
            grade=grade,
            class_id=class_id,
            section=section,
            skip=skip,
            limit=limit
        )
        
        return {
            "year": year,
            "month": month,
            "records": records,
            "total": total_count,
            "skip": skip,
            "limit": limit,
            "summary": summary
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to generate monthly report: {e}"
        )

@router.get("/attendance/student/{student_id}")
async def get_student_attendance_report(
    student_id: int,
    date_from: Optional[date] = Query(None, description="Start date for filtering"),
    date_to: Optional[date] = Query(None, description="End date for filtering"),
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    db: Session = Depends(get_db)
):
    """
    Get attendance report for a specific student.
    """
    try:
        report_repo = ReportRepository(db)
        records, total_count, summary = report_repo.get_student_attendance_report(
            student_id=student_id,
            date_from=date_from,
            date_to=date_to,
            skip=skip,
            limit=limit
        )
        
        return {
            "student_id": student_id,
            "date_from": date_from.isoformat() if date_from else None,
            "date_to": date_to.isoformat() if date_to else None,
            "records": records,
            "total": total_count,
            "skip": skip,
            "limit": limit,
            "summary": summary
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to generate student report: {e}"
        )

@router.get("/attendance/class/{class_id}")
async def get_class_attendance_report(
    class_id: int,
    date_from: Optional[date] = Query(None, description="Start date for filtering"),
    date_to: Optional[date] = Query(None, description="End date for filtering"),
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    db: Session = Depends(get_db)
):
    """
    Get attendance report for a specific class.
    """
    try:
        report_repo = ReportRepository(db)
        records, total_count, summary = report_repo.get_class_attendance_report(
            class_id=class_id,
            date_from=date_from,
            date_to=date_to,
            skip=skip,
            limit=limit
        )
        
        return {
            "class_id": class_id,
            "date_from": date_from.isoformat() if date_from else None,
            "date_to": date_to.isoformat() if date_to else None,
            "records": records,
            "total": total_count,
            "skip": skip,
            "limit": limit,
            "summary": summary
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to generate class report: {e}"
        )

@router.get("/critical-attendance")
async def get_critical_attendance_report(
    threshold: float = Query(50.0, description="Attendance threshold percentage"),
    grade: Optional[str] = Query(None, description="Filter by grade"),
    class_id: Optional[int] = Query(None, description="Filter by class ID"),
    section: Optional[str] = Query(None, description="Filter by section"),
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    db: Session = Depends(get_db)
):
    """
    Get report of students with critical attendance (below threshold).
    """
    try:
        report_repo = ReportRepository(db)
        records, total_count = report_repo.get_critical_attendance_report(
            threshold=threshold,
            grade=grade,
            class_id=class_id,
            section=section,
            skip=skip,
            limit=limit
        )
        
        return {
            "threshold": threshold,
            "records": records,
            "total": total_count,
            "skip": skip,
            "limit": limit
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to generate critical attendance report: {e}"
        )

@router.get("/attendance/daily/csv")
async def export_daily_attendance_csv(
    report_date: date = Query(..., description="Date of the report"),
    grade: Optional[str] = Query(None, description="Filter by grade"),
    class_id: Optional[int] = Query(None, description="Filter by class ID"),
    section: Optional[str] = Query(None, description="Filter by section"),
    db: Session = Depends(get_db)
):
    """
    Export daily attendance report as CSV.
    """
    try:
        report_repo = ReportRepository(db)
        records, total_count, _ = report_repo.get_daily_attendance_report(
            report_date=report_date,
            grade=grade,
            class_id=class_id,
            section=section,
            skip=0,
            limit=10000  # Higher limit for export
        )
        
        filename, csv_content = CSVExportUtility.generate_attendance_csv(records)
        
        return Response(
            content=csv_content,
            media_type="text/csv",
            headers={
                "Content-Disposition": f"attachment; filename={filename}"
            }
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"_FAILED to export daily report: {e}"
        )

@router.get("/critical-attendance/csv")
async def export_critical_attendance_csv(
    threshold: float = Query(50.0, description="Attendance threshold percentage"),
    grade: Optional[str] = Query(None, description="Filter by grade"),
    class_id: Optional[int] = Query(None, description="Filter by class ID"),
    section: Optional[str] = Query(None, description="Filter by section"),
    db: Session = Depends(get_db)
):
    """
    Export critical attendance report as CSV.
    """
    try:
        report_repo = ReportRepository(db)
        records, total_count = report_repo.get_critical_attendance_report(
            threshold=threshold,
            grade=grade,
            class_id=class_id,
            section=section,
            skip=0,
            limit=10000  # Higher limit for export
        )
        
        filename, csv_content = CSVExportUtility.generate_critical_attendance_csv(records)
        
        return Response(
            content=csv_content,
            media_type="text/csv",
            headers={
                "Content-Disposition": f"attachment; filename={filename}"
            }
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to export critical attendance report: {e}"
        )

@router.get("/attendance/daily/pdf")
async def export_daily_attendance_pdf(
    report_date: date = Query(..., description="Date of the report"),
    grade: Optional[str] = Query(None, description="Filter by grade"),
    class_id: Optional[int] = Query(None, description="Filter by class ID"),
    section: Optional[str] = Query(None, description="Filter by section"),
    db: Session = Depends(get_db)
):
    """
    Export daily attendance report as PDF document.
    """
    try:
        report_repo = ReportRepository(db)
        records, total_count, _ = report_repo.get_daily_attendance_report(
            report_date=report_date,
            grade=grade,
            class_id=class_id,
            section=section,
            skip=0,
            limit=10000
        )
        
        filename, pdf_content = PDFExportUtility.generate_attendance_pdf(
            records=records,
            title=f"Daily Attendance Report ({report_date.isoformat()})"
        )
        
        return Response(
            content=pdf_content,
            media_type="application/pdf",
            headers={
                "Content-Disposition": f"attachment; filename={filename}"
            }
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to export daily PDF report: {e}"
        )

@router.get("/critical-attendance/pdf")
async def export_critical_attendance_pdf(
    threshold: float = Query(50.0, description="Attendance threshold percentage"),
    grade: Optional[str] = Query(None, description="Filter by grade"),
    class_id: Optional[int] = Query(None, description="Filter by class ID"),
    section: Optional[str] = Query(None, description="Filter by section"),
    db: Session = Depends(get_db)
):
    """
    Export critical attendance report as PDF document.
    """
    try:
        report_repo = ReportRepository(db)
        records, total_count = report_repo.get_critical_attendance_report(
            threshold=threshold,
            grade=grade,
            class_id=class_id,
            section=section,
            skip=0,
            limit=10000
        )
        
        filename, pdf_content = PDFExportUtility.generate_critical_attendance_pdf(
            records=records,
            threshold=threshold
        )
        
        return Response(
            content=pdf_content,
            media_type="application/pdf",
            headers={
                "Content-Disposition": f"attachment; filename={filename}"
            }
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to export critical PDF report: {e}"
        )

