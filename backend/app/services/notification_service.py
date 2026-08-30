from typing import List
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.repositories.notification_repository import NotificationRepository
from app.repositories.student_repository import StudentRepository
from app.schemas.notification import NotificationCreate, NotificationUpdate
from app.models.notification import Notification

class NotificationService:
    def __init__(self, db: Session):
        self.db = db
        self.notification_repo = NotificationRepository(db)
        self.student_repo = StudentRepository(db)

    def get_notification(self, notification_id: int) -> Notification:
        notification = self.notification_repo.get(notification_id)
        if not notification:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Notification with id {notification_id} not found"
            )
        return notification

    def list_notifications(self, skip: int = 0, limit: int = 100) -> List[Notification]:
        return self.notification_repo.get_all(skip=skip, limit=limit)

    def create_notification(self, notification_in: NotificationCreate) -> Notification:
        # Validate student exists
        if not self.student_repo.exists(notification_in.student_id):
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Student with id {notification_in.student_id} not found"
            )
        
        notification_data = notification_in.model_dump()
        return self.notification_repo.create(notification_data)

    def update_notification(self, notification_id: int, notification_in: NotificationUpdate) -> Notification:
        notification = self.get_notification(notification_id)
        update_data = notification_in.model_dump(exclude_unset=True)
        return self.notification_repo.update(notification, update_data)

    def delete_notification(self, notification_id: int) -> Notification:
        notification = self.get_notification(notification_id)
        return self.notification_repo.delete(notification_id)

    def get_notifications_by_student(self, student_id: int, skip: int = 0, limit: int = 100) -> List[Notification]:
        if not self.student_repo.exists(student_id):
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Student with id {student_id} not found"
            )
        return self.notification_repo.get_by_student(student_id, skip=skip, limit=limit)

    def get_pending_notifications(self, skip: int = 0, limit: int = 100) -> List[Notification]:
        return self.notification_repo.get_pending_notifications(skip=skip, limit=limit)

    def get_failed_notifications(self, skip: int = 0, limit: int = 100) -> List[Notification]:
        return self.notification_repo.get_failed_notifications(skip=skip, limit=limit)
