import os
from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import Field

class Settings(BaseSettings):
    HOST: str = "0.0.0.0"
    PORT: int = 8000
    DEBUG: bool = True
    ENVIRONMENT: str = "development"

    # Security
    SECRET_KEY: str = "django-insecure-edutrackai-attendance-system-secret-key-temporary"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 1440

    # PostgreSQL Database URL
    DATABASE_URL: str = "postgresql+psycopg://postgres:postgres@localhost:5432/edutrack_db"

    # AI Configurations (SFace and YuNet models)
    YUNET_MODEL_URL: str = "https://github.com/opencv/opencv_zoo/raw/master/models/face_detection_yunet/face_detection_yunet_2023mar.onnx"
    SFACE_MODEL_URL: str = "https://github.com/opencv/opencv_zoo/raw/master/models/face_recognition_sface/face_recognition_sface_2021dec.onnx"
    FACE_MATCH_THRESHOLD: float = 0.363
    FACE_RECOGNITION_THRESHOLD: float = 0.363  # Cosine similarity threshold for attendance recognition
    
    # Models storage folder relative to current file or absolute
    MODELS_DIR: str = os.path.join(os.path.dirname(os.path.abspath(__file__)), "facial_recognition", "models")

    # Notifications
    ENABLE_NOTIFICATIONS: bool = False
    SMTP_HOST: str = "smtp.gmail.com"
    SMTP_PORT: int = 587
    SMTP_USER: str = "your_email@gmail.com"
    SMTP_PASSWORD: str = "your_app_password"

    model_config = SettingsConfigDict(
        env_file=os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), ".env"),
        env_file_encoding='utf-8'
    )

# Instantiate settings
settings = Settings()
