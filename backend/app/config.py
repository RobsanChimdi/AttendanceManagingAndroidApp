import os
import logging
from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import Field

logger = logging.getLogger(__name__)

class Settings(BaseSettings):
    HOST: str = "0.0.0.0"
    PORT: int = 8000
    DEBUG: bool = False
    ENVIRONMENT: str = "production"

    # Security — MUST be set in .env for production
    SECRET_KEY: str = Field(..., description="JWT signing secret key. Must be set in .env.")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 1440
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7

    # Database — MUST be set in .env
    DATABASE_URL: str = Field(..., description="SQLAlchemy database URL. Must be set in .env.")

    # CORS
    ALLOWED_ORIGINS: str = "*"  # Comma-separated origins or * for all

    # AI Configurations (SFace and YuNet models)
    YUNET_MODEL_URL: str = "https://github.com/opencv/opencv_zoo/raw/master/models/face_detection_yunet/face_detection_yunet_2023mar.onnx"
    SFACE_MODEL_URL: str = "https://github.com/opencv/opencv_zoo/raw/master/models/face_recognition_sface/face_recognition_sface_2021dec.onnx"
    FACE_MATCH_THRESHOLD: float = 0.363
    FACE_RECOGNITION_THRESHOLD: float = 0.363

    # Models storage folder relative to current file or absolute
    MODELS_DIR: str = os.path.join(os.path.dirname(os.path.abspath(__file__)), "facial_recognition", "models")

    # Notifications
    ENABLE_NOTIFICATIONS: bool = False
    SMTP_HOST: str = "smtp.gmail.com"
    SMTP_PORT: int = 587
    SMTP_USER: str = ""
    SMTP_PASSWORD: str = ""

    model_config = SettingsConfigDict(
        env_file=os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), ".env"),
        env_file_encoding='utf-8'
    )

    def get_allowed_origins_list(self) -> list:
        """Parse ALLOWED_ORIGINS into a list."""
        if self.ALLOWED_ORIGINS == "*":
            return ["*"]
        return [o.strip() for o in self.ALLOWED_ORIGINS.split(",") if o.strip()]

# Instantiate settings
settings = Settings()
