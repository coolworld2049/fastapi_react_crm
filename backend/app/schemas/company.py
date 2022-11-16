from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field

from backend.app.schemas import column_type


class CompanyBase(BaseModel):
    name: str = None
    sector: Optional[str] = Field(
        None,
        description=f"required: {column_type.marketSector.schema().get('required')}"
    )
    size: Optional[str] = Field(
        None,
        description=f"required: {column_type.companySize.schema().get('required')}"
    )
    address: Optional[str] = None
    website: Optional[str] = None
    create_date: datetime = None

    class Config:
        use_enum_values = True


# Properties to receive via API on creation
class CompanyCreate(CompanyBase):
    pass


# Properties to receive via API on update
class CompanyUpdate(CompanyBase):
    pass


class CompanyInDBBase(CompanyBase):
    id: Optional[int] = None

    class Config:
        orm_mode = True


# Additional properties stored in DB but not returned by API
class CompanyInDB(CompanyInDBBase):
    pass


# Additional properties to return via API
class Company(CompanyInDBBase):
    pass