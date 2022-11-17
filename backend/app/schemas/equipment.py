from typing import Optional

from pydantic import BaseModel


class EquipmentBase(BaseModel):
    owner_id: int = None
    title: Optional[str] = None
    description: Optional[str] = None

    class Config:
        pass


# Properties to receive via API on creation
class EquipmentCreate(EquipmentBase):
    pass


# Properties to receive via API on update
class EquipmentUpdate(EquipmentBase):
    title: Optional[str] = None
    description: Optional[str] = None


class EquipmentInDBBase(EquipmentBase):
    id: Optional[int] = None

    class Config:
        orm_mode = True


# Additional properties stored in DB but not returned by API
class EquipmentInDB(EquipmentInDBBase):
    pass


# Additional properties to return via API
class Equipment(EquipmentInDBBase):
    pass
