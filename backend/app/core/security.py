from datetime import datetime, timedelta
from typing import Union, Any, List

from fastapi.security import OAuth2PasswordBearer
from jose import jwt
from passlib.hash import bcrypt
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


def _create_token(
        token_type: str,
        lifetime: timedelta,
        sub: str,
) -> str:
    payload = {}
    expire = datetime.utcnow() + lifetime
    payload["type"] = token_type

    # https://datatracker.ietf.org/doc/html/rfc7519#section-4.1.3
    # The "exp" (expiration time) claim identifies the expiration time on
    # or after which the JWT MUST NOT be accepted for processing
    payload["exp"] = expire

    # The "iat" (issued at) claim identifies the time at which the
    # JWT was issued.
    payload["iat"] = datetime.utcnow()

    # The "sub" (subject) claim identifies the principal that is the
    # subject of the JWT
    payload["sub"] = str(sub)
    return jwt.encode(payload, settings.SECRET_KEY, algorithm=settings.ALGORITHM)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    return cryptContext.verify(plain_password, hashed_password)


def get_password_hash(password: str) -> str:
    return cryptContext.hash(password)
