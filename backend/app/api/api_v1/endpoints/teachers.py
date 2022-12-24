from typing import Any, List, Union

from fastapi import APIRouter, Depends, HTTPException, Response
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from backend.app import crud, schemas
from backend.app.api import deps
from backend.app.db import models
from backend.app.schemas.request_params import RequestParams

router = APIRouter()


# noinspection PyUnusedLocal
@router.get("/", response_model=List[schemas.Teacher])
async def read_teachers(
        response: Response,
        db: AsyncSession = Depends(deps.get_db),
        current_user: models.User = Depends(deps.get_current_active_user),
        request_params: RequestParams = Depends(deps.parse_react_admin_params(models.Teacher))
) -> Any:
    """
    Retrieve Tasks.
    """
    items, total = await crud.teacher.get_multi(db, request_params=request_params)
    response.headers["Content-Range"] = f"{request_params.skip}-{request_params.skip + len(items)}/{total}"
    return items


# noinspection PyUnusedLocal
@router.post("/", response_model=schemas.Teacher)
async def create_teacher(
        *,
        db: AsyncSession = Depends(deps.get_db),
        item_in: Union[Any, schemas.UserCreate],
        current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Create new Teacher.
    """
    try:
        item = await crud.teacher.create_multi(db=db, obj_in=item_in)
        return item
    except IntegrityError as ie:
        raise HTTPException(409, ie.detail)

# noinspection PyUnusedLocal
@router.get("/me", response_model=List[schemas.Teacher])
async def read_teacher_me(
        response: Response,
        db: AsyncSession = Depends(deps.get_db),
        current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Get current teacher.
    """
    teacher = await crud.teacher.get(db, user_id=current_user.id)
    response.headers["Content-Range"] = f"{0}-{len(teacher)}/{len(teacher)}"
    return teacher

# noinspection PyUnusedLocal
@router.put("/{id}", response_model=schemas.Teacher)
async def update_teacher_id(
        *,
        db: AsyncSession = Depends(deps.get_db),
        id: int,
        item_in: schemas.TeacherUpdate,
        current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Update a Teacher.
    """
    item = await crud.teacher.get(db=db, user_id=id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    item = await crud.teacher.update(db=db, db_obj=item, obj_in=item_in)
    return item


# noinspection PyUnusedLocal
@router.get("/{id}", response_model=schemas.Teacher)
async def read_teacher_id(
        *,
        db: AsyncSession = Depends(deps.get_db),
        id: int,
        current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Get Teacher by ID.
    """
    item = await crud.teacher.get(db=db, user_id=id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    return item


# noinspection PyUnusedLocal
@router.delete("/{id}", response_model=schemas.Teacher)
async def delete_teacher_id(
        *,
        db: AsyncSession = Depends(deps.get_db),
        id: int,
        current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Delete an Teacher.
    """
    item = await crud.teacher.get(db=db, user_id=id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    item = await crud.teacher.remove(db=db, id=id)
    return item
