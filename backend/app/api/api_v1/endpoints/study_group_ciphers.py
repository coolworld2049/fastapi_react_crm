from typing import Any, List

from fastapi import APIRouter, Depends, HTTPException, Response
from sqlalchemy.exc import ProgrammingError, IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from backend.app import crud, schemas
from backend.app.api import deps
from backend.app.db import models
from backend.app.schemas.request_params import RequestParams

router = APIRouter()


# noinspection PyUnusedLocal
@router.get("/", response_model=List[schemas.StudyGroupCipher])
async def read_study_group_ciphers(
        response: Response,
        db: AsyncSession = Depends(deps.get_db),
        current_user: models.User = Depends(deps.get_current_active_user),
        request_params: RequestParams = Depends(deps.parse_react_admin_params(models.StudyGroupCipher))
) -> Any:
    """
    Retrieve StudyGroupCipher.
    """
    items, total = await crud.study_group_cipher.get_multi(db, request_params=request_params)
    response.headers["Content-Range"] = f"{request_params.skip}-{request_params.skip + len(items)}/{total}"
    return items


# noinspection PyUnusedLocal
@router.post("/", response_model=schemas.StudyGroupCipher)
async def create_study_group_cipher(
        *,
        db: AsyncSession = Depends(deps.get_db),
        item_in: schemas.StudyGroupCipherCreate,
        current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Create new task.
    """
    try:
        item = await crud.study_group_cipher.create(db=db, obj_in=item_in)
        return item
    except AssertionError as e:
        raise HTTPException(400, e.args)
    except IntegrityError as ie:
        raise HTTPException(409, ie.detail)


# noinspection PyUnusedLocal
@router.put("/{id}", response_model=schemas.StudyGroupCipher)
async def update_study_group_cipher_id(
        *,
        db: AsyncSession = Depends(deps.get_db),
        id: str,
        item_in: schemas.StudyGroupCipherUpdate,
        current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Update an task.
    """
    item = await crud.study_group_cipher.get(db=db, id=id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    try:
        item = await crud.study_group_cipher.update(db=db, db_obj=item, obj_in=item_in)
        return item
    except ProgrammingError as e:
        raise HTTPException(405, detail=str(e.args))


# noinspection PyUnusedLocal
@router.get("/{id}", response_model=schemas.StudyGroupCipher)
async def read_study_group_cipher_id(
        *,
        db: AsyncSession = Depends(deps.get_db),
        id: str,
        current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Get task by ID.
    """
    item = await crud.study_group_cipher.get(db=db, id=id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    return item


# noinspection PyUnusedLocal
@router.delete("/{id}", response_model=schemas.StudyGroupCipher)
async def delete_study_group_cipher_id(
        *,
        db: AsyncSession = Depends(deps.get_db),
        id: str,
        current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Delete an task.
    """
    item = await crud.study_group_cipher.get(db=db, id=id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    item = await crud.study_group_cipher.remove(db=db, id=id)
    return item
