from datetime import datetime
from typing import Any, List

from fastapi import APIRouter, Body, Depends, HTTPException, Response
from fastapi.encoders import jsonable_encoder
from fastapi.params import Query
from fastapi.responses import FileResponse
from pydantic.networks import EmailStr
from pydantic.schema import Literal
from sqlalchemy import select, func, or_
from sqlalchemy.engine import Result
from sqlalchemy.ext.asyncio import AsyncSession

from backend.app import crud, models, schemas
from backend.app.api import deps
from backend.app.core.config import settings
from backend.app.schemas import column_type
from backend.app.schemas.request_params import RequestParams

router = APIRouter()


# noinspection PyUnusedLocal
@router.get("/", response_model=List[schemas.User])
async def read_users(
        response: Response,
        db: AsyncSession = Depends(deps.get_async_session),
        current_user: models.User = Depends(deps.get_current_active_user),
        request_params: RequestParams = Depends(deps.parse_react_admin_params(models.User))  # noqa
) -> Any:
    """
    Retrieve users.
    """
    total: Result = await db.execute(select(func.count(models.User.id)))
    users = await crud.user.get_multi_by_filter(db, request_params)
    response.headers["Content-Range"] = \
        f"{request_params.skip}-{request_params.skip + len(users)}/{len(total.scalars().all())}"
    return users


# noinspection PyUnusedLocal
@router.get(
    "/{rolname}",
    response_model=List[schemas.User],
    description=f"roles: {column_type.userRoleEnum.to_list().__str__()}",
)
async def read_users_by_role(
        response: Response,
        db: AsyncSession = Depends(deps.get_async_session),
        current_user: models.User = Depends(deps.get_current_active_user),
        request_params: schemas.RequestParams = Depends(deps.parse_react_admin_params(models.User)),  # noqa
        rolname: str = Query(None, example=f"{column_type.userRoleEnum.to_list()}"),
) -> Any:
    """
    Retrieve users.
    """
    total: Result = await db.execute(select(func.count(models.User.id)).where(models.User.role == rolname))
    users = await crud.user.get_multi_by_filter(db, request_params, role=rolname)
    response.headers["Content-Range"] = \
        f"{request_params.skip}-{request_params.skip + len(users)}/{len(total.scalars().all())}"
    return users


# noinspection PyUnusedLocal
@router.get("/employees", response_model=List[schemas.User])
async def read_users_employees(
        response: Response,
        db: AsyncSession = Depends(deps.get_async_session),
        current_user: models.User = Depends(deps.get_current_active_user),
        request_params: RequestParams = Depends(deps.parse_react_admin_params(models.User))  # noqa
) -> Any:
    """
    Retrieve users.
    """
    total: Result = await db.execute(select(func.count(models.User.id))
                                     .filter(or_(models.User.role == schemas.userRole.manager_base,
                                                 models.User.role == schemas.userRole.ranker_base)))
    users = await crud.user.get_multi_by_filter(db, request_params, employees=True)
    response.headers["Content-Range"] = \
        f"{request_params.skip}-{request_params.skip + len(users)}/{len(total.scalars().all())}"
    return users


# noinspection PyUnusedLocal
@router.post("/", response_model=schemas.User)
async def create_user(
        *,
        db: AsyncSession = Depends(deps.get_async_session),
        user_in: schemas.UserCreate,
        current_user: models.User = Depends(deps.get_current_active_superuser),
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
        db: AsyncSession = Depends(deps.get_async_session),
        password: str = Body(None),
        email: EmailStr = Body(None),
        role: schemas.column_type.userRoleEnum = Body(None),
        current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Update own user.
    """
    current_user_data = jsonable_encoder(current_user)
    user_in = schemas.UserUpdate(**current_user_data)
    if password:
        user_in.password = password
    if email:
        user_in.email = email
    if role:
        user_in.role = role
    user = await crud.user.update(db, db_obj=current_user, obj_in=user_in)
    return user


# noinspection PyUnusedLocal
@router.get("/me", response_model=schemas.User)
async def read_user_me(
        db: AsyncSession = Depends(deps.get_async_session),
        current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Get current user.
    """
    return current_user


@router.get("/{id}", response_model=schemas.User)
async def read_user_by_id(
        id: int,
        current_user: models.User = Depends(deps.get_current_active_user),
        db: AsyncSession = Depends(deps.get_async_session),
) -> Any:
    """
    Get a specific user by id.
    """
    user = await crud.user.get(db, id=id)
    if user == current_user:
        return user
    if not crud.user.is_superuser(current_user):
        raise HTTPException(
            status_code=400, detail="The user doesn't have enough privileges"
        )
    return user


@router.get("/{id}/report", response_class=FileResponse)
async def read_user_report(
        id: int,
        ext: Literal['csv', 'json'],
        start_timestamp: datetime = Query(datetime
                                          .now(tz=settings.SERVER_TZ)
                                          .replace(year=datetime.now().year - 1)
                                          .isoformat()),
        end_timestamp: datetime = Query(datetime
                                        .now(tz=settings.SERVER_TZ)
                                        .replace(year=datetime.now().year + 1)
                                        .isoformat()),
        current_user: models.User = Depends(deps.get_current_active_user),  # noqa
) -> Any:
    """
    Generate report by user id.\n
    """
    user_report_path = await crud.user.generate_report(
        id,
        start_timestamp,
        end_timestamp,
        ext
    )
    return FileResponse(
        user_report_path.get('path_out'),
        media_type=f'text/{ext}',
        filename=user_report_path.get('filename'),
    )


# noinspection PyUnusedLocal
@router.put("/{id}", response_model=schemas.User)
async def update_user(
        *,
        db: AsyncSession = Depends(deps.get_async_session),
        id: int,
        user_in: schemas.UserUpdate,
        current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Update a user.
    """
    user = await crud.user.get(db, id=id)
    if not user:
        raise HTTPException(
            status_code=404,
            detail="The user with this username does not exist in the system",
        )
    user = await crud.user.update(db, db_obj=user, obj_in=user_in)
    return user
