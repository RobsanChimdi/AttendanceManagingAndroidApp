from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from typing import Optional
from app.database import get_db
from app.security.jwt import decode_token
from app.services.user_service import UserService
from app.schemas.user import UserResponse
from app.models.user import UserRole

security = HTTPBearer()

def get_current_user_dependency(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
) -> UserResponse:
    """
    Dependency to get the current authenticated user from JWT token.
    """
    token = credentials.credentials
    
    # Decode token
    payload = decode_token(token)
    if payload is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials"
        )
    
    # Check token type
    if payload.get("type") != "access":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token type"
        )
    
    # Get user ID from token
    user_id: Optional[str] = payload.get("sub")
    if user_id is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials"
        )
    
    # Get user from database
    user_service = UserService(db)
    try:
        user = user_service.get_user(int(user_id))
    except HTTPException:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found"
        )
    
    return UserResponse.model_validate(user)

def require_role(required_role: UserRole):
    """
    Dependency factory to require specific user role.
    """
    def role_checker(current_user: UserResponse = Depends(get_current_user_dependency)) -> UserResponse:
        if current_user.role != required_role:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Access denied. {required_role.value} role required"
            )
        return current_user
    return role_checker

def require_admin(current_user: UserResponse = Depends(get_current_user_dependency)) -> UserResponse:
    """
    Dependency to require ADMIN role.
    """
    if current_user.role != UserRole.ADMIN:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied. ADMIN role required"
        )
    return current_user

def require_teacher(current_user: UserResponse = Depends(get_current_user_dependency)) -> UserResponse:
    """
    Dependency to require TEACHER role.
    """
    if current_user.role != UserRole.TEACHER:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied. TEACHER role required"
        )
    return current_user

def require_admin_or_teacher(current_user: UserResponse = Depends(get_current_user_dependency)) -> UserResponse:
    """
    Dependency to require either ADMIN or TEACHER role.
    """
    if current_user.role not in [UserRole.ADMIN, UserRole.TEACHER]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied. ADMIN or TEACHER role required"
        )
    return current_user
