from typing import Optional

from pydantic import BaseModel


class TeacherBase(BaseModel):
    user_id: int
    role: str  # type teacher_role
    discipline_id: int
    room_number: Optional[str]
    campus_id: Optional[str]


# Properties to receive via API on creation
class TeacherCreate(TeacherBase):
    user_id: int
    role: str  # type teacher_role
    discipline_id: int


# Properties to receive via API on update
class TeacherUpdate(TeacherBase):
    user_id: int
    role: str  # type teacher_role
    discipline_id: str


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
