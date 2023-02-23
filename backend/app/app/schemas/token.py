from datetime import datetime
from typing import List
from typing import Optional

from pydantic import BaseModel
from pydantic import Field


class TokenBase(BaseModel):
    access_token: str = Field(None, alias="access_token")
    expires_delta: Optional[datetime]
    token_type: Optional[str] = "bearer"

    class Config:
        allow_population_by_field_name = True


class TokenPayload(TokenBase):
    sub: Optional[str]
    scopes: Optional[List[str]]


class Token(TokenPayload):
    class Config:
        fields = {
            "sub": {"exclude": True},
            "scopes": {"exclude": True},
            "expires_delta": {"exclude": True},
        }
