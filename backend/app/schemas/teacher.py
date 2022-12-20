from typing import Optional

from pydantic import BaseModel


class TeacherBase(BaseModel):
    typed_discipline_id: Optional[int]
    user_id: Optional[int]


# Properties to receive via API on creation
class TeacherCreate(TeacherBase):
    typed_discipline_id: int
    user_id: int


# Properties to receive via API on update
class TeacherUpdate(TeacherBase):
    user_id: int

    typed_discipline_id: int


class TeacherInDBBase(TeacherBase):
    id: Optional[int] = None

    class Config:
        orm_mode = True


# Additional properties stored in DB but not returned by API
class TeacherInDB(TeacherInDBBase):
    pass


# Additional properties to return via API
class Teacher(TeacherInDBBase):
    pass


