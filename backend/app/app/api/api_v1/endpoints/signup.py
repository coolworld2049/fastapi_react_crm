from fastapi import APIRouter
from fastapi import Depends
from fastapi import HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from starlette import status

from app import crud
from app import schemas
from app.api.deps import database

router = APIRouter()


@router.post(
    "/signup",
    response_model=schemas.User,
    status_code=status.HTTP_201_CREATED,
    response_model_exclude_defaults=True,
    response_model_exclude_unset=True,
)
async def signup(
    user_in: schemas.UserCreateOpen, db: AsyncSession = Depends(database.get_db)
):
    user = await crud.user.get_by_email(db, email=user_in.email)
    if user:
        raise HTTPException(
            status_code=400,
            detail="The user with this username already exists.",
        )
    new_user = await crud.user.create(db, obj_in=user_in)
    return new_user
