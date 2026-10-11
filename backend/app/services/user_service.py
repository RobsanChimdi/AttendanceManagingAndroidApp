from typing import List
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from passlib.context import CryptContext
from app.repositories.user_repository import UserRepository
from app.schemas.user import UserCreate
from app.models.user import User, UserRole

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

class UserService:
    def __init__(self, db: Session):
        self.db = db
        self.user_repo = UserRepository(db)

    def get_user(self, user_id: int) -> User:
        user = self.user_repo.get(user_id)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"User with id {user_id} not found"
            )
        return user

    def get_user_by_email(self, email: str) -> User:
        user = self.user_repo.get_by_email(email)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"User with email {email} not found"
            )
        return user

    def list_users(self, skip: int = 0, limit: int = 100) -> List[User]:
        return self.user_repo.get_all(skip=skip, limit=limit)

    def create_user(self, user_in: UserCreate) -> User:
        # Check if email already exists
        existing = self.user_repo.get_by_email(user_in.email)
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"User with email {user_in.email} already exists"
            )
        
        # Hash password
        password_hash = pwd_context.hash(user_in.password)
        
        user_data = user_in.model_dump(exclude={"password"})
        user_data["password_hash"] = password_hash
        
        return self.user_repo.create(user_data)

    def verify_password(self, plain_password: str, hashed_password: str) -> bool:
        return pwd_context.verify(plain_password, hashed_password)

    def get_users_by_role(self, role: UserRole, skip: int = 0, limit: int = 100) -> List[User]:
        return self.user_repo.get_by_role(role, skip=skip, limit=limit)
