from app.repositories.student_repository import StudentRepository
from app.repositories.class_repository import ClassRepository
from app.repositories.user_repository import UserRepository
from app.repositories.attendance_repository import AttendanceRepository
from app.repositories.attendance_session_repository import AttendanceSessionRepository
from app.repositories.notification_repository import NotificationRepository
from app.repositories.audit_log_repository import AuditLogRepository
from app.repositories.face_embedding_repository import FaceEmbeddingRepository

__all__ = [
    "StudentRepository",
    "ClassRepository",
    "UserRepository",
    "AttendanceRepository",
    "AttendanceSessionRepository",
    "NotificationRepository",
    "AuditLogRepository",
    "FaceEmbeddingRepository"
]
