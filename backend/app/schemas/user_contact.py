from typing import Optional

from pydantic import BaseModel


class UserContactBase(BaseModel):
    phone: Optional[str]
    vk: Optional[str]
    telegram: Optional[str]
    discord: Optional[str]


# Properties to receive via API on creation
class UserContactCreate(UserContactBase):
    id: Optional[int]


# Properties to receive via API on update
class UserContactUpdate(UserContactBase):
    id: Optional[int]


class UserContactInDBBase(UserContactBase):
    id: Optional[int] = None

    class Config:
        orm_mode = True


# Additional properties stored in DB but not returned by API
class UserContactInDB(UserContactInDBBase):
    pass


# Additional properties to return via API
class UserContact(UserContactInDBBase):
    pass


