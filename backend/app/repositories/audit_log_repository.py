from typing import Optional, List
from sqlalchemy.orm import Session
from app.models.audit_log import AuditLog
from app.repositories.base_repository import BaseRepository

class AuditLogRepository(BaseRepository[AuditLog]):
    def __init__(self, db: Session):
        super().__init__(AuditLog, db)

    def get_by_user(self, user_id: int, skip: int = 0, limit: int = 100) -> List[AuditLog]:
        return self.db.query(AuditLog).filter(
            AuditLog.user_id == user_id
        ).order_by(AuditLog.created_at.desc()).offset(skip).limit(limit).all()

    def get_by_entity(self, entity_type: str, entity_id: int, skip: int = 0, limit: int = 100) -> List[AuditLog]:
        return self.db.query(AuditLog).filter(
            AuditLog.entity_type == entity_type,
            AuditLog.entity_id == entity_id
        ).order_by(AuditLog.created_at.desc()).offset(skip).limit(limit).all()

    def get_by_action(self, action: str, skip: int = 0, limit: int = 100) -> List[AuditLog]:
        return self.db.query(AuditLog).filter(
            AuditLog.action == action
        ).order_by(AuditLog.created_at.desc()).offset(skip).limit(limit).all()
