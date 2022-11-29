from datetime import datetime
from typing import Optional

from fastapi_filter.contrib.sqlalchemy import Filter
from pydantic import BaseModel, EmailStr, validator, Field
from pydantic.types import constr

from backend.app import models
from backend.app.schemas import column_type


class UserBase(BaseModel):
    email: Optional[EmailStr] = None
    phone: Optional[constr(strip_whitespace=True, regex=r"^(\+)[1-9][0-9\-\(\)\.]{9,15}$", )] = None
    role: str = Field(
        default=column_type.userRole.user,
        description=f"required: {column_type.userRole.schema().get('required')}"
    )

    @validator("role")
    def role_validate(cls, value):  # noqa
        if value not in column_type.userRole.schema().get('required'):
            raise ValueError("Not valid user role")
        return value

    is_active: Optional[bool] = True
    is_superuser: bool = False
    full_name: str = None
    create_date: datetime


# Properties to receive via API on creation
class UserCreate(UserBase):
    email: EmailStr
    password: str


# Properties to receive via API on update
class UserUpdate(UserBase):
    password: Optional[str] = None
    full_name: str = True


class UserInDBBase(UserBase):
    id: Optional[int] = None

    class Config:
        orm_mode = True


# Additional properties stored in DB but not returned by API
class UserInDB(UserInDBBase):
    hashed_password: str


# Additional properties to return via API
class User(UserInDBBase):
    user_role = column_type.userRoleEnum.to_list()


class UserFilter(Filter):
    role: Optional[str]

    class Constants(Filter.Constants):
        model = models.User
