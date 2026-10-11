import logging
from sqlalchemy import create_engine, text
from sqlalchemy.orm import declarative_base, sessionmaker
from app.config import settings

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("database")

# Setup SQLAlchemy engine
# Use PostgreSQL with psycopg2
SQLALCHEMY_DATABASE_URL = settings.DATABASE_URL

# Create engine
engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    pool_pre_ping=True,
    # Check_same_thread is only needed for SQLite, but good to omit for Postgres
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

def get_db():
    """
    Database session generator dependency.
    Yields database session and guarantees closure on exit.
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def check_db_connection() -> bool:
    """
    Checks the database connection on startup.
    Returns True if connection is successful, False otherwise.
    Logs warning instead of throwing exception to allow app to start.
    """
    try:
        # Create a temporary session to execute a simple SELECT 1
        with SessionLocal() as session:
            session.execute(text("SELECT 1"))
        logger.info("Successfully connected to the PostgreSQL database.")
        return True
    except Exception as e:
        logger.warning(
            f"Failed to connect to the PostgreSQL database at {settings.DATABASE_URL}. "
            f"Error details: {e}. "
            f"The application will start, but database-dependent features will be unavailable."
        )
        return False
