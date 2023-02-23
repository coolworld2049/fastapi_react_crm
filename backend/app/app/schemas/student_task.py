from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class StudentTaskBase(BaseModel):
    id: int  # task_id
    student_id: int
    status: str
    priority: str
    points: Optional[int]
    comment: Optional[str]
    feedback: Optional[str]
    grade: Optional[str]
    deadline_date: Optional[datetime]
    completion_date: Optional[datetime]


# Properties to receive via API on creation
class StudentTaskCreate(StudentTaskBase):
    id: int
    student_id: int
    status: str
    priority: str


# Properties to receive via API on update
class StudentTaskUpdate(StudentTaskBase):
    id: int
    student_id: int


class StudentTaskInDBBase(StudentTaskBase):
    id: Optional[int] = None

    class Config:
        orm_mode = True


# Additional properties stored in DB but not returned by API
class StudentTaskInDB(StudentTaskInDBBase):
    pass


# Additional properties to return via API
class StudentTask(StudentTaskInDBBase):
    pass
