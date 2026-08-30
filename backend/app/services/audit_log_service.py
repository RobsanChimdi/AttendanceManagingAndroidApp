from typing import List
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.repositories.audit_log_repository import AuditLogRepository
from app.repositories.user_repository import UserRepository
from app.schemas.audit_log import AuditLogCreate
from app.models.audit_log import AuditLog

class AuditLogService:
    def __init__(self, db: Session):
        self.db = db
        self.audit_log_repo = AuditLogRepository(db)
        self.user_repo = UserRepository(db)

    def get_audit_log(self, audit_log_id: int) -> AuditLog:
        audit_log = self.audit_log_repo.get(audit_log_id)
        if not audit_log:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Audit log with id {audit_log_id} not found"
            )
        return audit_log

    def list_audit_logs(self, skip: int = 0, limit: int = 100) -> List[AuditLog]:
        return self.audit_log_repo.get_all(skip=skip, limit=limit)

    def create_audit_log(self, audit_log_in: AuditLogCreate) -> AuditLog:
        # Validate user exists
        if not self.user_repo.exists(audit_log_in.user_id):
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"User with id {audit_log_in.user_id} not found"
            )
        
        audit_log_data = audit_log_in.model_dump()
        return self.audit_log_repo.create(audit_log_data)

    def get_audit_logs_by_user(self, user_id: int, skip: int = 0, limit: int = 100) -> List[AuditLog]:
        if not self.user_repo.exists(user_id):
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"User with id {user_id} not found"
            )
        return self.audit_log_repo.get_by_user(user_id, skip=skip, limit=limit)

    def get_audit_logs_by_entity(self, entity_type: str, entity_id: int, skip: int = 0, limit: int = 100) -> List[AuditLog]:
        return self.audit_log_repo.get_by_entity(entity_type, entity_id, skip=skip, limit=limit)

    def get_audit_logs_by_action(self, action: str, skip: int = 0, limit: int = 100) -> List[AuditLog]:
        return self.audit_log_repo.get_by_action(action, skip=skip, limit=limit)
