from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field

from backend.app.db import models


class TaskBase(BaseModel):
    teacher_id: Optional[int]
    study_group_cipher_id: Optional[int]
    student_id: Optional[int]
    title: Optional[str]
    description: Optional[str]
    status: Optional[str] = Field(models.task_status.enums[0], description=models.task_status.enums.__str__())
    priority: Optional[str] = Field(models.task_priority.enums[0], description=models.task_priority.enums.__str__())
    expiration_date: Optional[datetime]


# Properties to receive via API on creation
class TaskCreate(TaskBase):
    pass


# Properties to receive via API on update
class TaskUpdate(TaskBase):
    pass

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
