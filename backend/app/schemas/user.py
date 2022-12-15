from typing import Optional

from pydantic import BaseModel, EmailStr, Field

from backend.app.db import models, classifiers


class UserBase(BaseModel):
    email: EmailStr
    role: str = Field(classifiers.UserRole.anon, description=models.classifiers.UserRole.to_list().__str__())
    full_name: Optional[str]
    username: str
    age: Optional[int]
    avatar: Optional[str]
    is_active: bool = True
    is_superuser: bool = False


# Properties to receive via API on creation
class UserCreate(UserBase):
    password: str


# Properties to receive via API on update
class UserUpdate(UserBase):
    password: str


class UserInDBBase(UserBase):
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
