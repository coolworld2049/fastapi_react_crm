from typing import Optional

from pydantic import BaseModel

from backend.app import schemas


class TeacherBase(BaseModel):
    user_id: int
    role: str  # type teacher_role
    discipline_id: int | list
    room_number: Optional[str]
    campus_id: Optional[str]


# Properties to receive via API on creation
class TeacherCreate(TeacherBase):
    pass


# Properties to receive via API on update
class TeacherUpdate(TeacherBase):
    pass


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
