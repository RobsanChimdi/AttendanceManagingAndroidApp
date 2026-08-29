from datetime import datetime
from sqlalchemy import Column, DateTime
from app.database import Base

class TimestampMixin:
    """
    Mixin to automatically add creation and update timestamps to tables.
    """
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
