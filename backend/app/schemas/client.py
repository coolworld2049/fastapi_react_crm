from typing import Optional

from pydantic import BaseModel, Field

from backend.app.schemas import column_type


class ClientBase(BaseModel):
    company_id: int = None
    type: Optional[str] = Field(
        ...,
        description=f"required: {column_type.clientType.schema().get('required')}"
    )


# Properties to receive via API on creation
class ClientCreate(ClientBase):
    id: Optional[int] = None


# Properties to receive via API on update
class ClientUpdate(ClientBase):
    pass


class ClientInDBBase(ClientBase):
    id: Optional[int] = None

    class Config:
        orm_mode = True


# Additional properties stored in DB but not returned by API
class ClientInDB(ClientInDBBase):
    pass


# Additional properties to return via API
class Client(ClientInDBBase):
    meta = [column_type.clientTypeEnum.to_list()]

