from datetime import datetime, timedelta
from typing import Union, Any, List

from fastapi.security import OAuth2PasswordBearer
from jose import jwt
from passlib.context import CryptContext

from backend.app import schemas
from backend.app.core.config import settings

cryptContext = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2Scheme = OAuth2PasswordBearer(tokenUrl=f"{settings.API_V1_STR}/login/access-token")

def create_access_token(
        sub: Union[int, Any],
        scopes: List[str] = None,
        expires_delta: timedelta = None,
) -> dict:
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(
            minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES
        )
    to_encode = {"expires_delta": str(expire), "sub": str(sub), "scopes": scopes}
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)

    token = schemas.Token(access_token=encoded_jwt, token_type="bearer", **to_encode)
    return token.dict()

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return cryptContext.verify(plain_password, hashed_password)


def get_password_hash(password: str) -> str:
    return cryptContext.hash(password)
