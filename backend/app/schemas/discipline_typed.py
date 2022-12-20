from typing import Optional

from pydantic import BaseModel


class TypedDisciplineBase(BaseModel):
    discipline_id: Optional[int]
    classroom_number: Optional[str]
    campus_id: Optional[str]
    type: Optional[str]


# Properties to receive via API on creation
class TypedDisciplineCreate(TypedDisciplineBase):
    pass


# Properties to receive via API on update
class TypedDisciplineUpdate(TypedDisciplineBase):
    pass


class TypedDisciplineInDBBase(TypedDisciplineBase):
    id: Optional[int] = None

    class Config:
        orm_mode = True


# Additional properties stored in DB but not returned by API
class TypedDisciplineInDB(TypedDisciplineInDBBase):
    pass


# Additional properties to return via API
class TypedDiscipline(TypedDisciplineInDBBase):
    pass


