from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class TaskBase(BaseModel):
    teacher_id: int
    title: str
    description: Optional[str]
    priority: str
    create_date: Optional[datetime]


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
    create_date: Optional[datetime]

