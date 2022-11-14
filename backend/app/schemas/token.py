from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field


class TokenBase(BaseModel):
    access_token: str = Field(..., alias="access_token")
    expires_in: datetime
    token_type: Optional[str] = "bearer"

    class Config:
        allow_population_by_field_name = True


class Token(BaseModel):
    access_token: str
    token_type: str


class TokenPayload(BaseModel):
    username: Optional[str] = None
    expires_in: Optional[datetime] = None
