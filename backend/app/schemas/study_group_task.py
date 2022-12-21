from datetime import datetime
from typing import Optional, List

from pydantic import BaseModel


class StudyGroupTaskBase(BaseModel):
    id: int
    study_group_cipher_id: str
    status: str
    deadline_date: Optional[datetime]


# Properties to receive via API on creation
class StudyGroupTaskCreate(StudyGroupTaskBase):
    id: int
    study_group_cipher_id: str


# Properties to receive via API on update
class StudyGroupTaskUpdate(StudyGroupTaskBase):
    id: int
    study_group_cipher_id: str


class StudyGroupTaskInDBBase(StudyGroupTaskBase):
    id: Optional[int] = None

    class Config:
        orm_mode = True


# Additional properties stored in DB but not returned by API
class StudyGroupTaskInDB(StudyGroupTaskInDBBase):
    pass


# Additional properties to return via API
class StudyGroupTask(StudyGroupTaskInDBBase):
    pass
