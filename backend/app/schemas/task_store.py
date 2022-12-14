from typing import Optional

from pydantic import BaseModel


class TaskStoreBase(BaseModel):
    task_id: int
    url: str
    size: Optional[int]
    filename: Optional[str]
    media_type: Optional[str]


# Properties to receive via API on creation
class TaskStoreCreate(TaskStoreBase):
    pass


# Properties to receive via API on update
class TaskStoreUpdate(TaskStoreBase):
    pass


class TaskStoreInDBBase(TaskStoreBase):
    id: Optional[int] = None

    class Config:
        orm_mode = True


# Additional properties stored in DB but not returned by API
class TaskStoreInDB(TaskStoreInDBBase):
    pass


# Additional properties to return via API
class TaskStore(TaskStoreInDBBase):
    pass
