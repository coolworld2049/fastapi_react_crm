from typing import Optional

from pydantic import BaseModel, EmailStr, Field

from backend.app.db import models


class UserBase(BaseModel):
    email: EmailStr
    role: str = Field(models.user_role.enums[1], description=models.user_role.enums.__str__())
    full_name: Optional[str]
    username: str
    age: Optional[int] = None
    avatar: Optional[str] = None
    is_active: bool = True
    is_superuser: bool = False


# Properties to receive via API on creation
class UserCreate(UserBase):
    email: EmailStr
    password: str


# Properties to receive via API on update
class UserUpdate(UserBase):
    password: Optional[str]


class UserInDBBase(UserBase):
    id: Optional[int] = None

    class Config:
        orm_mode = True


# Additional properties stored in DB but not returned by API
class UserInDB(UserInDBBase):
    hashed_password: str


# Additional properties to return via API
class User(UserInDBBase):
    pass


