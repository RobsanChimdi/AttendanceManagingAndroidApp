from pydantic import BaseModel, Field, ConfigDict
from datetime import datetime
from typing import Optional

class FaceEmbeddingBase(BaseModel):
    student_id: int = Field(..., gt=0)
    model_name: str = Field(..., min_length=1, max_length=50)
    model_version: str = Field(None, max_length=50)

class FaceEmbeddingCreate(FaceEmbeddingBase):
    embedding: bytes = Field(..., description="Face embedding as binary data")

class FaceEmbeddingResponse(BaseModel):
    id: int
    student_id: int
    model_name: str
    model_version: Optional[str]
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)
