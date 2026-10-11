from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.orm import Session
from datetime import timedelta
from pydantic import BaseModel
from app.database import get_db
from app.schemas.user import UserLogin, UserResponse
from app.services.user_service import UserService
from app.security.password import verify_password
from app.security.jwt import create_access_token, create_refresh_token, decode_token
from app.security.dependencies import get_current_user_dependency
from app.config import settings
from slowapi import Limiter
from slowapi.util import get_remote_address

router = APIRouter(prefix="/auth", tags=["Authentication"])
limiter = Limiter(key_func=get_remote_address)

class RefreshTokenRequest(BaseModel):
    refresh_token: str

@router.post("/login")
@limiter.limit("5/minute")
def login(request: Request, user_credentials: UserLogin, db: Session = Depends(get_db)):
    """
    Authenticate user and return access and refresh tokens.
    """
    user_service = UserService(db)
    
    # Get user by email
    try:
        user = user_service.get_user_by_email(user_credentials.email)
    except HTTPException:
        # Don't reveal if user exists for security
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password"
        )
    
    # Verify password
    if not verify_password(user_credentials.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password"
        )
    
    # Create tokens
    access_token = create_access_token(
        data={"sub": str(user.id), "email": user.email, "role": user.role.value}
    )
    refresh_token = create_refresh_token(
        data={"sub": str(user.id)}
    )
    
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer",
        "user": UserResponse.model_validate(user)
    }

@router.get("/me", response_model=UserResponse)
def get_current_user(current_user: UserResponse = Depends(get_current_user_dependency)):
    """
    Get current authenticated user information.
    """
    return current_user

@router.post("/refresh")
def refresh_token(token_request: RefreshTokenRequest, db: Session = Depends(get_db)):
    """
    Refresh access token using refresh token.
    """
    # Decode refresh token
    payload = decode_token(token_request.refresh_token)
    if payload is None or payload.get("type") != "refresh":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid refresh token"
        )
    
    user_id = payload.get("sub")
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid refresh token"
        )
    
    # Get user
    user_service = UserService(db)
    try:
        user = user_service.get_user(int(user_id))
    except HTTPException:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found"
        )
    
    # Create new access token
    access_token = create_access_token(
        data={"sub": str(user.id), "email": user.email, "role": user.role.value}
    )
    
    return {
        "access_token": access_token,
        "token_type": "bearer"
    }

@router.post("/logout")
def logout():
    """
    Logout user (client-side token invalidation).
    """
    return {"message": "Successfully logged out"}
