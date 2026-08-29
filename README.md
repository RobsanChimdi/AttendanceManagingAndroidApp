# EDUTRACK AI
### Smart Student Attendance Management System

EDUTRACK AI is a production-quality school attendance management application leveraging automated face recognition and dynamic QR codes. Built for high-school demonstration to government education officials, it is designed for maximum reliability, speed, and clean software architecture.

## System Architecture

```text
       ┌────────────────────────┐
       │   Flutter Mobile App   │
       │ (Riverpod, GoRouter)   │
       └───────────┬────────────┘
                   │
                   │ REST API (JSON / Multipart)
                   ▼
       ┌────────────────────────┐
       │      FastAPI App       │
       │  (Uvicorn Web Server)  │
       └───────────┬────────────┘
                   │
         ┌─────────┴─────────┐
         ▼                   ▼
┌─────────────────┐ ┌──────────────────┐
│   PostgreSQL    │ │ OpenCV DNN Face  │
│ (SQLAlchemy DB) │ │ Recognition Service│
└─────────────────┘ └──────────────────┘
```

## Tech Stack

### Frontend
- **Framework:** Flutter (v3.41.3)
- **State Management:** Riverpod
- **Routing:** GoRouter
- **HTTP Client:** Dio
- **Charting:** FL Chart
- **Camera & Scanning:** Camera API, Mobile Scanner

### Backend
- **Framework:** FastAPI (Python v3.13)
- **Database ORM:** SQLAlchemy with Alembic Migrations
- **Database:** PostgreSQL
- **Facial Recognition:** OpenCV Deep Neural Network (DNN) with YuNet (Face Detection) and SFace (Face Recognition/Embeddings). No heavy PyTorch/TensorFlow dependencies.

---

## Directory Structure

```text
EDUTRACK AI/
├── frontend/             # Flutter Application
│   ├── lib/
│   │   ├── core/         # Core system helpers, constants
│   │   ├── config/       # Dependency injection, setup configurations
│   │   ├── routing/      # GoRouter configuration
│   │   ├── theme/        # Light/Dark material 3 themes
│   │   ├── network/      # Dio API Client
│   │   ├── storage/      # Local SharedPreferences cache
│   │   ├── models/       # Data serialization models
│   │   ├── services/     # API Service integration layers
│   │   ├── repositories/ # Repository state orchestration
│   │   ├── features/     # Feature-specific MVVM layers
│   │   └── widgets/      # Shared application widgets
│
├── backend/              # FastAPI Application
│   ├── app/
│   │   ├── main.py       # FastAPI Entrypoint
│   │   ├── config.py     # Environment config parser
│   │   ├── database.py   # PostgreSQL engine & session config
│   │   ├── models/       # SQLAlchemy tables
│   │   ├── schemas/      # Pydantic validation schemas
│   │   ├── routers/      # API Route controllers
│   │   └── services/     # Business logic & Facial Recognition Core
│   └── requirements.txt  # Python requirements list
```

## Getting Started

### Prerequisites
1. **Flutter SDK:** Ensure `flutter` is added to your environment variables PATH.
2. **Python:** Version 3.13+ is installed.

### Backend Setup
1. Change directory to `backend/`:
   ```bash
   cd backend
   ```
2. Create and activate a virtual environment:
   ```bash
   python -m venv .venv
   .venv\Scripts\activate
   ```
3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
4. Copy environment files and configure:
   ```bash
   copy .env.example .env
   ```
5. Start the FastAPI server:
   ```bash
   uvicorn app.main:app --reload
   ```

### Frontend Setup
1. Change directory to `frontend/`:
   ```bash
   cd frontend
   ```
2. Fetch package dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```
