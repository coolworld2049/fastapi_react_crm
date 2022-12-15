from typing import Optional

from pydantic import BaseModel, EmailStr, Field

from backend.app import schemas
from backend.app.db import models


class UserBase(BaseModel):
    email: Optional[EmailStr]
    role: Optional[str] = Field(None, description=models.classifiers.UserRole.to_list().__str__())
    full_name: Optional[str]
    username: Optional[str]
    age: Optional[int]
    avatar: Optional[str]
    is_active: bool = True
    is_superuser: bool = False


# Properties to receive via API on creation
class UserCreate(UserBase):
    email: EmailStr
    username: str
    password: str


# Properties to receive via API on update
class UserUpdate(UserBase):
    password: str


class UserInDBBase(UserBase, schemas.StudentInDBBase, schemas.TeacherInDBBase):
    id: Optional[int] = None

    class Config:
        orm_mode = True


# Additional properties stored in DB but not returned by API
class UserInDB(UserInDBBase):
    hashed_password: str


# Additional properties to return via API
class User(UserInDBBase):
    class Config:
        fields = {'is_superuser': {'exclude': True}}
