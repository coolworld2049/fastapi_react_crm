from datetime import datetime
from typing import Optional, List

from pydantic import BaseModel, Field


class TokenBase(BaseModel):
    access_token: str = Field(None, alias="access_token")
    expires_delta: Optional[datetime]
    token_type: Optional[str] = "bearer"

    class Config:
        allow_population_by_field_name = True


class TokenPayload(TokenBase):
    sub: Optional[str]
    scopes: List[str]


class Token(TokenPayload):
    pass


