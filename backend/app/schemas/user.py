from typing import Optional

from pydantic import BaseModel, EmailStr, validator
from pydantic.datetime_parse import datetime
from pydantic.types import constr

from backend.app.schemas import column_type


class UserBase(BaseModel):
    email: Optional[EmailStr] = None
    phone: Optional[constr(strip_whitespace=True, regex=r"^(\+)[1-9][0-9\-\(\)\.]{9,15}$", )] = None
    role: str = column_type.user_role_inst.user  # UserRole model
    is_active: Optional[bool] = True
    is_superuser: bool = False
    first_name: Optional[str] = None
    last_name: Optional[str] = None

    @validator("role")
    def role_validate(cls, value):  # noqa
        if value not in [x[1] for x in column_type.user_role_inst]:
            raise ValueError("Not valid user role")
        return value

    create_date: datetime = None

    class Config:
        use_enum_values = True


# Properties to receive via API on creation
class UserCreate(UserBase):
    email: EmailStr
    password: str


# Properties to receive via API on update
class UserUpdate(UserBase):
    ...


class UserInDBBase(UserBase):
    id: Optional[int] = None

    class Config:
        orm_mode = True


# Additional properties stored in DB but not returned by API
class UserInDB(UserInDBBase):
    hashed_password: str


# Additional properties to return via API
class User(UserInDBBase):
    ...
