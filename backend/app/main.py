import logging
from fastapi import FastAPI, Depends, status
from fastapi.middleware.cors import CORSMiddleware
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
from sqlalchemy.orm import Session
from app.config import settings
from app.database import Base, engine, get_db, check_db_connection

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("main")

# Rate limiter
limiter = Limiter(key_func=get_remote_address)


# Initialize FastAPI App
app = FastAPI(
    title="EDUTRACK AI API",
    description="Smart Student Attendance Management System REST API",
    version="1.0.0",
    debug=settings.DEBUG
)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# Include routers
from app.routers.auth import router as auth_router
from app.routers.students import router as students_router
from app.routers.classes import router as classes_router
from app.routers.attendance import router as attendance_router
from app.routers.notifications import router as notifications_router
from app.routers.dashboard import router as dashboard_router
from app.routers.reports import router as reports_router
from app.routers.websocket import router as websocket_router
app.include_router(auth_router)
app.include_router(students_router)
app.include_router(classes_router)
app.include_router(attendance_router)
app.include_router(notifications_router)
app.include_router(dashboard_router)
app.include_router(reports_router)
app.include_router(websocket_router)



# CORS configuration — reads from ALLOWED_ORIGINS env var (default: * for development)
allowed_origins = settings.get_allowed_origins_list()
app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=allowed_origins != ["*"],  # credentials only when specific origins set
    allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allow_headers=["*"],
)

@app.on_event("startup")
async def startup_event():
    logger.info("Starting up EDUTRACK AI Backend...")
    # Verify database connection (non-blocking)
    try:
        check_db_connection()
    except Exception as e:
        logger.warning(f"Database connection check failed during startup: {e}")
    
    # Check/download facial recognition models (non-blocking)
    try:
        from app.facial_recognition.service import face_recognition_service
        face_recognition_service.download_models_if_missing()
    except Exception as e:
        logger.warning(f"Facial recognition model setup failed during startup: {e}")

@app.get("/")
def read_root():
    return {
        "app": "EDUTRACK AI",
        "description": "Smart Student Attendance Management System REST API",
        "version": "1.0.0",
        "status": "online"
    }

@app.get("/health", status_code=status.HTTP_200_OK)
def health_check(db: Session = Depends(get_db)):
    """
    Detailed health check API checking connectivity to Database
    and status of Facial Recognition models.
    """
    db_connected = False
    try:
        from sqlalchemy import text
        db.execute(text("SELECT 1"))
        db_connected = True
    except Exception as e:
        logger.error(f"Database health check failed: {e}")
    
    models_ready = False
    try:
        from app.facial_recognition.service import face_recognition_service
        models_ready = face_recognition_service.verify_models_loaded()
    except Exception as e:
        logger.error(f"Facial recognition health check failed: {e}")

    health_status = {
        "status": "healthy" if (db_connected and models_ready) else "degraded",
        "database": "connected" if db_connected else "disconnected",
        "facial_recognition_models": "ready" if models_ready else "not_loaded",
    }
    
    return health_status
