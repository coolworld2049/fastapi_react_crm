from typing import Optional

from pydantic import BaseModel


class DisciplineTypedBase(BaseModel):
    discipline_id: int
    classroom_number: Optional[str]
    campus_id: Optional[str]
    type: Optional[str]


# Properties to receive via API on creation
class DisciplineTypedCreate(DisciplineTypedBase):
    pass


# Properties to receive via API on update
class DisciplineTypedUpdate(DisciplineTypedBase):
    pass


class DisciplineTypedInDBBase(DisciplineTypedBase):
    id: Optional[int] = None

    class Config:
        orm_mode = True


# Additional properties stored in DB but not returned by API
class DisciplineTypedInDB(DisciplineTypedInDBBase):
    pass


# Additional properties to return via API
class DisciplineTyped(DisciplineTypedInDBBase):
    pass


