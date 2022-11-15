from datetime import timedelta

from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import OAuth2PasswordRequestForm
from starlette import status

from backend.app.api import deps
from backend.app.core import security
from backend.app.core.config import settings
from backend.app.crud import crud_user

router = APIRouter()


@router.post("/signup")
async def signup(
        db=Depends(deps.get_async_db), form_data: OAuth2PasswordRequestForm = Depends()
):
    user = await crud_user.user.sign_up_new_user(db, form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Account already exists",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(
        minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES
    )
    data = security.create_access_token(sub=user.id, expires_delta=access_token_expires)
    return data
