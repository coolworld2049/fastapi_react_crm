from typing import Optional

from pydantic import BaseModel


class StudyGroupBase(BaseModel):
    study_group_cipher_id: str
    discipline_id: int


# Properties to receive via API on creation
class StudyGroupCreate(StudyGroupBase):
    pass


# Properties to receive via API on update
class StudyGroupUpdate(StudyGroupBase):
    discipline_id: int


class StudyGroupInDBBase(StudyGroupBase):
    id: Optional[int] = None

    class Config:
        orm_mode = True


# Additional properties stored in DB but not returned by API
class StudyGroupInDB(StudyGroupInDBBase):
    pass


# Additional properties to return via API
class StudyGroup(StudyGroupInDBBase):
    pass


