from datetime import datetime, timezone
from sqlalchemy import Column, DateTime
from app.database import Base

class TimestampMixin:
    """
    Mixin to automatically add creation and update timestamps to tables.
    """
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), nullable=False)
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc), nullable=False)
