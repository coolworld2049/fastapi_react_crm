from typing import Optional, List

from pydantic import BaseModel


class StudyGroupBase(BaseModel):
    id: str  # sgc_id
    discipline_id: int


# Properties to receive via API on creation
class StudyGroupCreate(StudyGroupBase):
    id: str
    discipline_id: int | List[int]


# Properties to receive via API on update
class StudyGroupUpdate(StudyGroupBase):
    pass


class StudyGroupInDBBase(StudyGroupBase):
    id: Optional[str] = None

    class Config:
        orm_mode = True


# Additional properties stored in DB but not returned by API
class StudyGroupInDB(StudyGroupInDBBase):
    pass


# Additional properties to return via API
class StudyGroup(StudyGroupInDBBase):
    pass
