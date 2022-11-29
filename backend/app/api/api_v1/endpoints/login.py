from datetime import timedelta
from typing import Any

from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.ext.asyncio import AsyncSession
from starlette import status

from backend.app import schemas, crud
from backend.app.api import deps
from backend.app.core import security
from backend.app.core.config import settings

router = APIRouter()


@router.post("/login/access-token", response_model=schemas.TokenPayload)
async def login_access_token(
        db: AsyncSession = Depends(deps.get_async_session),
        form_data: OAuth2PasswordRequestForm = Depends()
) -> Any:
    """
    OAuth2 compatible token login, get an access token for future requests
    """
    try:
        user = await crud.user.authenticate(
            email=form_data.username, password=form_data.password, db=db
        )
    except HTTPException as e:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=e.detail)

    if not user:
        raise HTTPException(status_code=status.HTTP_402_PAYMENT_REQUIRED, detail="Incorrect email or password or role")
    elif not crud.user.is_active(user):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Inactive user")
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    data = security.create_access_token(sub=user.id, expires_delta=access_token_expires, scopes=form_data.scopes)
    return data
