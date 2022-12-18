from typing import Optional

from pydantic import BaseModel


class StudyGroupCipherBase(BaseModel):
    id: Optional[str]


# Properties to receive via API on creation
class StudyGroupCipherCreate(StudyGroupCipherBase):
    pass


# Properties to receive via API on update
class StudyGroupCipherUpdate(StudyGroupCipherBase):
    pass


class StudyGroupCipherInDBBase(StudyGroupCipherBase):
    id: Optional[str] = None

    class Config:
        orm_mode = True


# Additional properties stored in DB but not returned by API
class StudyGroupCipherInDB(StudyGroupCipherInDBBase):
    pass


# Additional properties to return via API
class StudyGroupCipher(StudyGroupCipherInDBBase):
    pass


