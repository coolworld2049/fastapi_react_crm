from pydantic import BaseModel


class BlankBase(BaseModel):
    pass


# Properties to receive via API on creation
class BlankCreate(BlankBase):
    pass


# Properties to receive via API on update
class BlankUpdate(BlankBase):
    pass


class BlankInDBBase(BlankBase):
    pass


# Additional properties to return via API
class Blank(BlankInDBBase):
    pass


# Additional properties stored in DB but not returned by API
class BlankInDB(BlankInDBBase):
    pass
