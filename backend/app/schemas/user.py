import re
from typing import Optional

from pydantic import BaseModel, EmailStr, validator

from backend.app.db import classifiers


class UserBase(BaseModel):
    email: EmailStr
    role: str
    username: str
    full_name: Optional[str]
    age: Optional[int]
    avatar: Optional[str]
    phone: Optional[str]
    is_active: bool = True
    is_superuser: bool = False

    @validator('username')
    def validate_username(cls, value):  # noqa
        assert re.match("[A-Za-z_0-9]*", value), 'Invalid characters in username'
        return value

    @validator("phone")
    def validate_phone(cls, v):
        regex = r"^(\+)[1-9][0-9\-\(\)\.]{9,15}$"
        if v and not re.search(regex, v, re.I):
            raise ValueError("Phone Number Invalid.")
        return v


password_regexp = r"^(?=.*[A-Z].*[A-Z])(?=.*[!@#$&*])(?=.*[0-9].*[0-9])(?=.*[a-z].*[a-z].*[a-z]).{11,}$"


# Properties to receive via API on creation
class UserCreate(UserBase):
    password: str

    @validator('password')
    def validate_password(cls, value):  # noqa
        info_text = """Ensure string has: 2 uppercase letters, 1 special case letter, 2digits, 3 lowercase letters, length 11"""
        assert re.match(password_regexp, value), info_text
        return value



# Properties to receive via API on update
class UserUpdate(UserBase):
    pass


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
        fields = {
            'is_superuser': {'exclude': True}
        }
