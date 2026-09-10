from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.repositories.notification_repository import NotificationRepository
from app.models.notification import NotificationStatus
from app.security.dependencies import require_admin_or_teacher
from slowapi import Limiter
from slowapi.util import get_remote_address

router = APIRouter(prefix="/notifications", tags=["Notifications"])
limiter = Limiter(key_func=get_remote_address)

@router.get("/")
@limiter.limit("60/minute")
async def get_notifications(
    request: Request,
    status: NotificationStatus = None,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user = Depends(require_admin_or_teacher)
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
            detail="Failed to get notifications"
        )

@router.get("/student/{student_id}")
@limiter.limit("60/minute")
async def get_student_notifications(
    request: Request,
    student_id: int,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user = Depends(require_admin_or_teacher)
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
            detail="Failed to get student notifications"
        )
