from datetime import datetime
from typing import Optional

from pydantic import BaseModel, EmailStr, validator, Field
from pydantic.types import constr

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
    username: str

    @validator("username", pre=True)
    def username_validate(cls, value: str):  # noqa
        return value.lower().replace(' ', '_').replace('@', '').replace('$', '')

    company_id: Optional[int]
    type: Optional[str] = Field(
        None,
        description=f"required: {column_type.clientType.schema().get('required')}"
    )
    create_date: Optional[datetime]


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


