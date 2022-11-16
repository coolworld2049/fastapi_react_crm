from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field


class TokenBase(BaseModel):
    access_token: str = Field(..., alias="access_token")
    expires_in: datetime = None
    token_type: Optional[str] = "bearer"

    class Config:
        allow_population_by_field_name = True


class TokenInDBBase(TokenBase):
    sub: Optional[int] = None

    class Config:
        orm_mode = True


class TokenPayload(TokenInDBBase):
    sub: Optional[str] = None  # user_id
    expires_in: Optional[datetime] = None
    token_type: Optional[str] = "bearer"


class Token(TokenInDBBase):
    sub: Optional[int] = None
    access_token: str
    token_type: str
