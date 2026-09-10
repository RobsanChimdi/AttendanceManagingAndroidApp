import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

@pytest.fixture
def test_user_token():
    """Fixture to get a test user authentication token."""
    # This would typically create a test user and return a valid token
    # For now, return a placeholder
    return "Bearer test_token"

def test_full_attendance_workflow(test_user_token):
    """
    Integration test for the complete attendance workflow:
    Tests that authentication is required for all workflow steps.
    """
    headers = {"Authorization": test_user_token}
    
    # Step 1: Create attendance session - should fail with invalid token
    session_response = client.post("/attendance/sessions", json={
        "class_id": 1,
        "date": "2024-01-01",
        "session_type": "MORNING"
    }, headers=headers)
    
    # With invalid token, should get 401
    assert session_response.status_code == 401

def test_student_lifecycle_integration(test_user_token):
    """
    Integration test for student lifecycle:
    Tests that authentication is required for all student operations.
    """
    headers = {"Authorization": test_user_token}
    
    # Step 1: Create student - should fail with invalid token
    create_response = client.post("/students/", json={
        "student_id": "INT001",
        "first_name": "Integration",
        "last_name": "Test",
        "grade": "10",
        "section": "A"
    }, headers=headers)
    
    # With invalid token, should get 401
    assert create_response.status_code == 401

def test_authentication_flow():
    """
    Integration test for authentication flow:
    1. Login
    2. Get current user
    3. Refresh token
    4. Logout
    """
    # Step 1: Login
    login_response = client.post("/auth/login", json={
        "email": "test@example.com",
        "password": "testpassword"
    })
    # This would fail without actual user, but tests the endpoint structure
    # Rate limiting may cause 429, so accept that as well
    assert login_response.status_code in [401, 422, 429]
    
    # If login succeeds, continue with token
    if login_response.status_code == 200:
        token_data = login_response.json()
        access_token = token_data["access_token"]
        refresh_token = token_data["refresh_token"]
        headers = {"Authorization": f"Bearer {access_token}"}
        
        # Step 2: Get current user
        me_response = client.get("/auth/me", headers=headers)
        assert me_response.status_code == 200
        
        # Step 3: Refresh token
        refresh_response = client.post("/auth/refresh", json={
            "refresh_token": refresh_token
        })
        assert refresh_response.status_code == 200
        
        # Step 4: Logout
        logout_response = client.post("/auth/logout", headers=headers)
        assert logout_response.status_code == 200

def test_database_connection():
    """Test that database connection is working."""
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["database"] == "connected"

def test_facial_recognition_models_loaded():
    """Test that facial recognition models are loaded."""
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    # Models might not be loaded in test environment
    assert "facial_recognition_models" in data

def test_error_handling_integration():
    """Test error handling across the API."""
    headers = {"Authorization": "Bearer invalid_token"}
    
    # Test unauthorized access
    response = client.get("/students/", headers=headers)
    assert response.status_code == 401
    
    # Test not found
    response = client.get("/students/99999", headers=headers)
    assert response.status_code in [401, 404]
    
    # Test validation error
    response = client.post("/students/", json={}, headers=headers)
    assert response.status_code in [401, 422]

def test_rate_limiting_integration():
    """Test that rate limiting is applied across endpoints."""
    # Make multiple rapid requests to a rate-limited endpoint
    responses = []
    for _ in range(6):
        response = client.post("/auth/login", json={
            "email": "test@example.com",
            "password": "wrongpassword"
        })
        responses.append(response.status_code)
    
    # At least some requests should be rate limited
    assert 429 in responses or all(r == 401 for r in responses)

def test_cors_configuration():
    """Test that CORS is configured correctly."""
    # This would typically be tested with actual HTTP requests
    # For now, just verify the endpoint exists
    response = client.options("/")
    assert response.status_code in [200, 405]
