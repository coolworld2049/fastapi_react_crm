from typing import Optional

from pydantic import BaseModel


class CampusBase(BaseModel):
    address: str


# Properties to receive via API on creation
class CampusCreate(CampusBase):
    id: Optional[str]


# Properties to receive via API on update
class CampusUpdate(CampusBase):
    pass


class CampusInDBBase(CampusBase):
    id: Optional[str] = None

    class Config:
        orm_mode = True


# Additional properties stored in DB but not returned by API
class CampusInDB(CampusInDBBase):
    pass


# Additional properties to return via API
class Campus(CampusInDBBase):
    pass
