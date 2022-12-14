from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field

from backend.app.db import models


class TaskStudentBase(BaseModel):
    points: Optional[int]
    comment: Optional[str]
    feedback: Optional[str]
    grade: Optional[str] = Field(
        None,
        description=models.classifiers.StudentTaskGrade.great.name.__str__()
    )
    deadline_date: Optional[datetime]
    start_date: Optional[datetime]
    completion_date: Optional[datetime]


# Properties to receive via API on creation
class TaskStudentCreate(TaskStudentBase):
    id: int


# Properties to receive via API on update
class TaskStudentUpdate(TaskStudentBase):
    id: int


class TaskStudentInDBBase(TaskStudentBase):
    id: Optional[int] = None

    class Config:
        orm_mode = True


# Additional properties stored in DB but not returned by API
class TaskStudentInDB(TaskStudentInDBBase):
    pass


# Additional properties to return via API
class TaskStudent(TaskStudentInDBBase):
    pass
