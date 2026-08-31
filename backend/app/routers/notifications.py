from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.repositories.notification_repository import NotificationRepository
from app.models.notification import NotificationStatus

router = APIRouter(prefix="/notifications", tags=["Notifications"])

@router.get("/")
async def get_notifications(
    status: NotificationStatus = None,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    """
    Get all notifications with optional status filter.
    """
    try:
        notification_repo = NotificationRepository(db)
        
        if status == NotificationStatus.PENDING:
            notifications = notification_repo.get_pending_notifications(skip=skip, limit=limit)
        elif status == NotificationStatus.FAILED:
            notifications = notification_repo.get_failed_notifications(skip=skip, limit=limit)
        else:
            notifications = notification_repo.get_all(skip=skip, limit=limit)
        
        result = []
        for notif in notifications:
            result.append({
                "id": notif.id,
                "student_id": notif.student_id,
                "guardian_name": notif.guardian_name,
                "guardian_phone": notif.guardian_phone,
                "message": notif.message,
                "status": notif.status.value,
                "sent_at": notif.sent_at.isoformat() if notif.sent_at else None,
                "created_at": notif.created_at.isoformat()
            })
        
        return {
            "notifications": result,
            "total": len(notifications),
            "skip": skip,
            "limit": limit
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get notifications: {e}"
        )

@router.get("/student/{student_id}")
async def get_student_notifications(
    student_id: int,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    """
    Get all notifications for a specific student.
    """
    try:
        notification_repo = NotificationRepository(db)
        notifications = notification_repo.get_by_student(student_id, skip=skip, limit=limit)
        
        result = []
        for notif in notifications:
            result.append({
                "id": notif.id,
                "student_id": notif.student_id,
                "guardian_name": notif.guardian_name,
                "guardian_phone": notif.guardian_phone,
                "message": notif.message,
                "status": notif.status.value,
                "sent_at": notif.sent_at.isoformat() if notif.sent_at else None,
                "created_at": notif.created_at.isoformat()
            })
        
        return {
            "notifications": result,
            "total": len(notifications),
            "skip": skip,
            "limit": limit
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get student notifications: {e}"
        )
