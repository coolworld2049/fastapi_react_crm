from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field

from backend.app.db import models


class TaskBase(BaseModel):
    teacher_id: Optional[int]
    study_group_cipher_id: Optional[str]
    student_id: Optional[int]
    title: Optional[str]
    description: Optional[str]
    status: Optional[str] = Field(
        models.classifiers.TaskStatus.pending.name,
        description=models.classifiers.TaskStatus.to_list().__str__()
    )
    priority: Optional[str] = Field(
        models.classifiers.TaskPriority.high.name,
        description=models.classifiers.TaskPriority.to_list().__str__()
    )
    expiration_date: Optional[datetime]


# Properties to receive via API on creation
class TaskCreate(TaskBase):
    pass


# Properties to receive via API on update
class TaskUpdate(TaskBase):
    description: Optional[str]


class TaskInDBBase(TaskBase):
    id: Optional[int] = None

    class Config:
        orm_mode = True


# Additional properties stored in DB but not returned by API
class TaskInDB(TaskInDBBase):
    pass


# Additional properties to return via API
class Task(TaskInDBBase):
    pass
