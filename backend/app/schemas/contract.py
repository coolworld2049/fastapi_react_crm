from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field

from backend.app.core.config import settings
from backend.app.schemas import column_type


class ContractBase(BaseModel):
    task_id: int = None
    equipment_id: int = None
    stage: Optional[str] = Field(
        None,
        description=f"required: {column_type.contractStage.schema().get('required')}"
    )
    name: Optional[str] = None
    description: Optional[str] = None
    create_date: datetime
    completion_date: datetime

    class Config:
        use_enum_values = True


# Properties to receive via API on creation
class ContractCreate(ContractBase):
    pass


# Properties to receive via API on update
class ContractUpdate(ContractBase):
    pass


class ContractInDBBase(ContractBase):
    id: Optional[int] = None

    class Config:
        orm_mode = True


# Additional properties stored in DB but not returned by API
class ContractInDB(ContractInDBBase):
    pass


# Additional properties to return via API
class Contract(ContractInDBBase):
    pass
