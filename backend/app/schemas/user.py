import json
import re
from difflib import SequenceMatcher
from typing import Optional

from pydantic import BaseModel, EmailStr, validator, root_validator

from backend.app.core.config import ROOT_PATH

password_exp = r"^(?=.*[A-Z].*[A-Z])(?=.*[!@#$&*])(?=.*[0-9].*[0-9])(?=.*[a-z].*[a-z].*[a-z]).{11,}$"
email_exp = r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'
username_exp = "[A-Za-z_0-9]*"

reserved_username_list = json.loads(open(f'{ROOT_PATH}/db/reserved_username.json').read())

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

    @root_validator
    def validate_all(cls, values):  # noqa
        assert re.match(email_exp, values.get('email')), \
            "Invalid email"
        assert re.match(username_exp, values.get('username')), \
            'Invalid characters in username'
        if values.get('username') and values.get('password') and values.get('email'):
            assert SequenceMatcher(None, values.get('username'), values.get('password')).ratio() < 0.5, \
                'Password must not match username'
            try:
                assert SequenceMatcher(None, values.get('password'), values.get('email').split("@")[0]).ratio() < 0.4, \
                    'Password must not match email'
            except AssertionError as e:
                print(e)
        return values

    @validator('username')
    def validate_password(cls, value):  # noqa
        assert value not in reserved_username_list,\
            'This username is reserved'
        return value

    @validator("phone")
    def validate_phone(cls, v):  # noqa
        regex = r"^(\+)[1-9][0-9\-\(\)\.]{9,15}$"
        if v and not re.search(regex, v, re.I):
            raise ValueError("Phone Number Invalid.")
        return v


# Properties to receive via API on creation
class UserCreate(UserBase):
    password: str

    @validator('password')
    def validate_password(cls, value):  # noqa
        assert re.match(password_exp, value), "Make sure the password is: 11 characters long," \
                                              " 2 uppercase and 3 lowercase letters, 1 special letter, 2 numbers"
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
