from typing import Optional

from backend.app import schemas


class UserContactBase(schemas.User):
    phone: Optional[str]
    vk: Optional[str]
    telegram: Optional[str]
    discord: Optional[str]


# Properties to receive via API on creation
class UserContactCreate(UserContactBase):
    pass


# Properties to receive via API on update
class UserContactUpdate(UserContactBase):
    pass


# Additional properties stored in DB but not returned by API
class UserContactInDB(UserContactBase, schemas.User):
    pass


# Additional properties to return via API
class UserContact(UserContactBase, schemas.User):
    pass


