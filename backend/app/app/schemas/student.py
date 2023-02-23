from typing import Optional

from pydantic import BaseModel


class StudentBase(BaseModel):
    study_group_cipher_id: Optional[str]
    role: Optional[str]


# Properties to receive via API on creation
class StudentCreate(StudentBase):
    id: int


# Properties to receive via API on update
class StudentUpdate(StudentCreate):
    pass


class StudentInDBBase(StudentBase):
    id: Optional[int] = None

    class Config:
        orm_mode = True


# Additional properties stored in DB but not returned by API
class StudentInDB(StudentInDBBase):
    pass


# Additional properties to return via API
class Student(StudentInDBBase):
    pass
