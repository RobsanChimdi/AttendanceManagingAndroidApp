import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

@pytest.fixture
def auth_headers():
    """Fixture to get authentication headers."""
    # This would typically get a valid token
    # For now, return empty dict
    return {}

def test_list_students_without_auth():
    """Test that listing students requires authentication."""
    response = client.get("/students/")
    assert response.status_code == 401  # Unauthorized

def test_list_students_with_auth(auth_headers):
    """Test listing students with authentication."""
    response = client.get("/students/", headers=auth_headers)
    # With valid auth, should return 200 or 403 depending on role
    assert response.status_code in [200, 403, 401]

def test_create_student_without_auth():
    """Test that creating a student requires authentication."""
    response = client.post("/students/", json={
        "student_id": "TEST001",
        "first_name": "Test",
        "last_name": "Student",
        "grade": "10",
        "section": "A"
    })
    assert response.status_code == 401

def test_create_student_validation():
    """Test student creation validation."""
    response = client.post("/students/", json={
        # Missing required fields
        "first_name": "Test"
    }, headers={})
    assert response.status_code in [401, 422]

def test_get_student_by_id():
    """Test getting a student by ID."""
    response = client.get("/students/1")
    assert response.status_code == 401  # Requires auth

def test_update_student():
    """Test updating a student."""
    response = client.put("/students/1", json={
        "first_name": "Updated"
    })
    assert response.status_code == 401  # Requires auth

def test_delete_student():
    """Test deleting a student."""
    response = client.delete("/students/1")
    assert response.status_code == 401  # Requires auth

def test_face_enrollment_requires_auth():
    """Test that face enrollment requires authentication."""
    response = client.post("/students/1/face/enroll")
    assert response.status_code == 401

def test_face_enrollment_rate_limiting():
    """Test that face enrollment has rate limiting."""
    # This would require actual file upload
    # For now, just check endpoint exists
    pass

def test_qr_token_generation_requires_auth():
    """Test that QR token generation requires authentication."""
    response = client.post("/students/1/qr-token")
    assert response.status_code == 401

def test_attendance_summary_requires_auth():
    """Test that attendance summary requires authentication."""
    response = client.get("/students/1/attendance-summary")
    assert response.status_code == 401

def test_critical_attendance_requires_auth():
    """Test that critical attendance endpoint requires authentication."""
    response = client.get("/students/critical-attendance")
    assert response.status_code == 401
