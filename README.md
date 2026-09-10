# EduTrack AI — Smart Student Attendance Management System

EduTrack AI is an enterprise-grade, production-ready school attendance management application leveraging automated face recognition and dynamic QR codes. Built for high-school demonstration to education officials, it is engineered for high speed, accuracy, zero false-positives, and seamless cross-platform functionality.

---

## 🏗️ System Architecture

```text
       ┌────────────────────────┐
       │   Flutter Mobile App   │
       │ (Riverpod, GoRouter)   │
       └───────────┬────────────┘
                   │
                   │ REST API (JSON / Multipart / JWT)
                   ▼
       ┌────────────────────────┐
       │      FastAPI App       │
       │  (Uvicorn Web Server)  │
       └───────────┬────────────┘
                   │
         ┌─────────┴─────────┐
         ▼                   ▼
┌─────────────────┐ ┌──────────────────┐
│ MySQL / SQLite  │ │ OpenCV DNN Face  │
│ (SQLAlchemy DB) │ │ Recognition Engine│
└─────────────────┘ └──────────────────┘
```

---

## 🛠️ Tech Stack

### Frontend (Mobile App)
- **Framework:** Flutter (3.24+)
- **State Management:** Riverpod (StateNotifier & Provider architecture)
- **Navigation & Routing:** GoRouter
- **HTTP Client:** Dio with Interceptors
- **Camera & Scanning:** `camera` package & `mobile_scanner`
- **Charts & UI:** FL Chart, Custom AppTheme Design System

### Backend (REST API Server)
- **Framework:** FastAPI (Python 3.10+)
- **Database & ORM:** SQLAlchemy with Alembic migrations
- **Authentication:** OAuth2 JWT bearer tokens with bcrypt password hashing
- **Facial Recognition:** OpenCV Deep Neural Network (DNN) using YuNet (Face Detection) and SFace (128-d Facial Embedding Extraction). No PyTorch/TensorFlow overhead required.

---

## 📁 Directory Structure

```text
EduTrack AI/
├── frontend/             # Flutter Application
│   ├── android/          # Native Android configuration (Permissions, Gradle)
│   ├── lib/
│   │   ├── core/         # System constants, design tokens
│   │   ├── features/     # Feature modules (Auth, Attendance, Students, Dashboard, Reports)
│   │   ├── models/       # Pydantic-compatible Dart data models
│   │   ├── network/      # Dio API Client with base URL configuration
│   │   ├── providers/    # Riverpod state providers
│   │   ├── services/     # REST API service wrappers
│   │   ├── storage/      # SecureStorageService (EncryptedSharedPreferences)
│   │   ├── theme/        # AppColors, AppTextStyles, AppSpacing tokens
│   │   └── widgets/      # Reusable UI components (AppButton, AppInput, AppEmptyState)
│   └── test/             # Unit and Widget tests
│
└── backend/              # FastAPI Application
    ├── app/
    │   ├── models/       # SQLAlchemy ORM Models (User, Student, Attendance, Session)
    │   ├── repositories/ # Data access repository layer
    │   ├── routers/      # FastAPI endpoint controllers
    │   ├── schemas/      # Pydantic request/response schemas
    │   ├── services/     # Business logic & Face Recognition engine
    │   ├── config.py     # Pydantic Settings configuration
    │   ├── database.py   # SQLAlchemy session factory
    │   └── main.py       # FastAPI application entrypoint
    ├── tests/            # Pytest suite
    ├── .env              # Application environment variables
    └── requirements.txt  # Python package requirements
```

---

## 🚀 Getting Started

### Prerequisites
1. **Flutter SDK:** Flutter v3.24+ added to your system `PATH`.
2. **Python:** Python 3.10+ installed.
3. **Android Studio / SDK:** Configured for Android emulator or physical device deployment.

---

### 1. Backend Setup

1. Navigate to the `backend` directory:
   ```bash
   cd backend
   ```

2. Create and activate a Python virtual environment:
   ```bash
   # Windows
   python -m venv .venv
   .venv\Scripts\activate

   # Linux/macOS
   python3 -m venv .venv
   source .venv/bin/activate
   ```

3. Install required Python packages:
   ```bash
   pip install -r requirements.txt
   ```

4. Configure environment variables in `.env`:
   ```env
   SECRET_KEY=your_production_secret_key_here
   DATABASE_URL=mysql+pymysql://root:password@localhost:3306/attendancemanagement
   DEBUG=True
   ENVIRONMENT=development
   ALLOWED_ORIGINS=*
   ```

5. Run database migrations or start the server:
   ```bash
   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```

---

### 2. Frontend Setup

1. Navigate to the `frontend` directory:
   ```bash
   cd frontend
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure API Base URL:
   - **Android Emulator:** Defaults automatically to `http://10.0.2.2:8000`.
   - **Physical Device:** Pass your development machine's local IP address via `--dart-define`:
     ```bash
     flutter run --dart-define=API_URL=http://192.168.1.100:8000
     ```

---

## 🔄 Verified End-to-End Workflow

The full production workflow has been validated step-by-step:

1. **Teacher Login:** Authenticate using teacher credentials to obtain a secure JWT stored in `SecureStorageService`.
2. **Student Creation:** Add a new student record (e.g., Student ID: `DEMO-001`, Name: `Demo Student`).
3. **Camera Permission:** Grant explicit camera permission via system dialog.
4. **Face Enrollment:** Capture 5 distinct facial sample photos. The OpenCV YuNet detector extracts 128-dimensional facial embeddings and stores them in the database.
5. **QR Code Generation:** Generate a unique, secure dynamic QR token for the enrolled student.
6. **Start Attendance Session:** Create and open a session for the target class section.
7. **Facial Recognition Attendance:**
   - Launch camera recognition mode in the session.
   - Present the student's face. OpenCV SFace calculates cosine embedding distance against enrolled samples.
   - On match (`confidence >= threshold`), attendance status is updated to **PRESENT**.
   - Presenting the face a second time returns `already_marked: true` to prevent duplicates.
   - Presenting an unknown face yields **UNKNOWN** and creates no attendance record.
8. **QR Attendance:** Scan the student's generated QR code to mark **PRESENT** via the `/attendance/sessions/{id}/qr` endpoint.
9. **Session Closure & Auto-Absence:** Close the attendance session. Remaining unmarked students in the class are automatically marked **ABSENT**.
10. **Critical Attendance Alerts:** Students whose attendance falls below 50% automatically trigger critical alerts and parent/guardian notification flags.

---

## 🧪 Testing & Code Quality

### Running Backend Unit & Integration Tests
```bash
cd backend
pytest tests/ -v
```

### Running Flutter Static Analysis
```bash
cd frontend
flutter analyze
```

### Running Flutter Unit & Widget Tests
```bash
cd frontend
flutter test
```

---

## 📦 Building Production APK

To build a standalone release APK for Android deployment:

```bash
cd frontend
flutter build apk --release --dart-define=API_URL=http://your-server-ip:8000
```

The compiled APK will be located at:
`frontend/build/app/outputs/flutter-apk/app-release.apk`
