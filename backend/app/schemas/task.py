from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field

from backend.app.schemas import column_type


class TaskBase(BaseModel):
    client_id: int = None
    author_id: int = None
    executor_id: Optional[int] = None
    name: Optional[str] = None
    description: Optional[str] = None
    type: Optional[str] = Field(
        ...,
        description=f"required: {column_type.taskType.schema().get('required')}"
    )
    priority: Optional[str] = Field(
        ...,
        description=f"required: {column_type.taskPriority.schema().get('required')}"
    )
    create_date: datetime
    deadline_date: Optional[datetime]
    completion_date: Optional[datetime]


# Properties to receive via API on creation
class TaskCreate(TaskBase):
    pass


# Properties to receive via API on update
class TaskUpdate(TaskBase):
    executor_id: int
    description: Optional[str]
    completion_date: Optional[datetime]


class TaskInDBBase(TaskBase):
    id: Optional[int] = None

    class Config:
        orm_mode = True


# Additional properties stored in DB but not returned by API
class TaskInDB(TaskInDBBase):
    pass


# Additional properties to return via API
class Task(TaskInDBBase):
    meta = [column_type.taskTypeEnum.dict(), column_type.taskPriorityEnum.dict()]
