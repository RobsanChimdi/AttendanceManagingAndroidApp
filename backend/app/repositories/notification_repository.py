from typing import Optional, List
from sqlalchemy.orm import Session
from app.models.notification import Notification, NotificationStatus
from app.repositories.base_repository import BaseRepository

class NotificationRepository(BaseRepository[Notification]):
    def __init__(self, db: Session):
        super().__init__(Notification, db)

    def get_by_student(self, student_id: int, skip: int = 0, limit: int = 100) -> List[Notification]:
        return self.db.query(Notification).filter(
            Notification.student_id == student_id
        ).offset(skip).limit(limit).all()

    def get_pending_notifications(self, skip: int = 0, limit: int = 100) -> List[Notification]:
        return self.db.query(Notification).filter(
            Notification.status == NotificationStatus.PENDING
        ).offset(skip).limit(limit).all()

    def get_failed_notifications(self, skip: int = 0, limit: int = 100) -> List[Notification]:
        return self.db.query(Notification).filter(
            Notification.status == NotificationStatus.FAILED
        ).offset(skip).limit(limit).all()
