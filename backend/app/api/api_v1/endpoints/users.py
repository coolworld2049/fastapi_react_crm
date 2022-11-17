from typing import Any, List, Optional

from fastapi import APIRouter, Body, Depends, HTTPException, Response
from fastapi.encoders import jsonable_encoder
from pydantic.networks import EmailStr
from sqlalchemy import select, func
from sqlalchemy.engine import Result
from sqlalchemy.ext.asyncio import AsyncSession

from backend.app import crud, models, schemas
from backend.app.api import deps
from backend.app.core.config import settings
from backend.app.schemas import column_type

router = APIRouter()


# noinspection PyUnusedLocal
@router.get("/", response_model=List[schemas.User])
async def read_users(
        response: Response,
        db: AsyncSession = Depends(deps.get_async_db),
        current_user: models.User = Depends(deps.get_current_active_superuser_async),
        skip: int = 0,
        limit: int = 100,
) -> Any:
    """
    Retrieve users.
    """
    total: Result = await db.execute(select(func.count(models.User.id)))
    users = await crud.user.get_multi(db, skip=skip, limit=limit)
    response.headers["Content-Range"] = f"{skip}-{skip + len(users)}/{len(total.scalars().all())}"
    return users


# noinspection PyUnusedLocal
@router.post("/", response_model=schemas.User)
async def create_user(
        *,
        db: AsyncSession = Depends(deps.get_async_db),
        user_in: schemas.UserCreate,
        current_user: models.User = Depends(deps.get_current_active_superuser_async),
) -> Any:
    """
    Create new user.
    """
    user = await crud.user.get_by_email(db, email=user_in.email)
    if user:
        raise HTTPException(
            status_code=400,
            detail="The user with this username already exists in the system.",
        )
    user = await crud.user.create(db, obj_in=user_in)
    return user


@router.put("/me", response_model=schemas.User)
async def update_user_me(
        *,
        db: AsyncSession = Depends(deps.get_async_db),
        password: str = Body(None),
        email: EmailStr = Body(None),
        current_user: models.User = Depends(deps.get_current_active_user_async),
) -> Any:
    """
    Update own user.
    """
    current_user_data = jsonable_encoder(current_user)
    user_in = schemas.UserUpdate(**current_user_data)
    if password is not None:
        user_in.password = password
    if email is not None:
        user_in.email = email
    user = await crud.user.update(db, db_obj=current_user, obj_in=user_in)
    return user


# noinspection PyUnusedLocal
@router.get("/me", response_model=schemas.User)
async def read_user_me(
        db: AsyncSession = Depends(deps.get_async_db),
        current_user: models.User = Depends(deps.get_current_active_user_async),
) -> Any:
    """
    Get current user.
    """
    return current_user


@router.post("/open", response_model=schemas.User)
async def create_user_open(
        *,
        db: AsyncSession = Depends(deps.get_async_db),
        password: str = Body(...),
        email: EmailStr = Body(...),
        first_name: Optional[str] = Body(None),
        last_name: Optional[str] = Body(None),
        role: str = Body('user')
) -> Any:
    """
    Create new user without the need to be logged in.
    """
    if not settings.USERS_OPEN_REGISTRATION:
        raise HTTPException(
            status_code=403,
            detail="Open user registration is forbidden on this server",
        )
    user = await crud.user.get_by_email(db, email=email)
    if user:
        raise HTTPException(
            status_code=400,
            detail="The user with this username already exists in the system",
        )
    if role != column_type.userRole.user:
        raise HTTPException(
            status_code=400,
            detail="'role' is invalid",
        )
    user_in = schemas.UserCreateOpen(
        password=password,
        email=email,
        first_name=first_name,
        last_name=last_name,
        role=role
    )
    user = await crud.user.create(db, obj_in=user_in)
    return user


@router.get("/{user_id}", response_model=schemas.User)
async def read_user_by_id(
        user_id: int,
        current_user: models.User = Depends(deps.get_current_active_user_async),
        db: AsyncSession = Depends(deps.get_async_db),
) -> Any:
    """
    Get a specific user by id.
    """
    user = await crud.user.get(db, id=user_id)
    if user == current_user:
        return user
    if not crud.user.is_superuser(current_user):
        raise HTTPException(
            status_code=400, detail="The user doesn't have enough privileges"
        )
    return user


# noinspection PyUnusedLocal
@router.put("/{user_id}", response_model=schemas.User)
async def update_user(
        *,
        db: AsyncSession = Depends(deps.get_async_db),
        user_id: int,
        user_in: schemas.UserUpdate,
        current_user: models.User = Depends(deps.get_current_active_superuser_async),
) -> Any:
    """
    Update a user.
    """
    user = await crud.user.get(db, id=user_id)
    if not user:
        raise HTTPException(
            status_code=404,
            detail="The user with this username does not exist in the system",
        )
    user = await crud.user.update(db, db_obj=user, obj_in=user_in)
    return user
