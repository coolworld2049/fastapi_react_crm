from typing import Optional

from pydantic import BaseModel


class StudentTaskStoreBase(BaseModel):
    task_id: int
    student_id: int
    url: str
    size: Optional[int]
    filename: Optional[str]


# Properties to receive via API on creation
class StudentTaskStoreCreate(StudentTaskStoreBase):
    task_id: int
    student_id: int


# Properties to receive via API on update
class StudentTaskStoreUpdate(StudentTaskStoreBase):
    task_id: int
    student_id: int


class StudentTaskStoreInDBBase(StudentTaskStoreBase):
    id: Optional[int] = None

    class Config:
        orm_mode = True


# Additional properties stored in DB but not returned by API
class StudentTaskStoreInDB(StudentTaskStoreInDBBase):
    pass


# Additional properties to return via API
class StudentTaskStore(StudentTaskStoreInDBBase):
    pass
