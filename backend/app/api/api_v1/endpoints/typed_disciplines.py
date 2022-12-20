from typing import Any, List

from fastapi import APIRouter, Depends, HTTPException, Response
from sqlalchemy.ext.asyncio import AsyncSession

from backend.app import crud, schemas
from backend.app.api import deps
from backend.app.db import models
from backend.app.schemas.request_params import RequestParams

router = APIRouter()


# noinspection PyUnusedLocal
@router.get("/", response_model=List[schemas.TypedDiscipline])
async def read_typed_discipline(
        response: Response,
        db: AsyncSession = Depends(deps.get_db),
        current_user: models.User = Depends(deps.get_current_active_user),
        request_params: RequestParams = Depends(deps.parse_react_admin_params(models.TypedDiscipline))
) -> Any:
    """
    Retrieve TypedDiscipline.
    """
    items, total = await crud.typed_discipline.get_multi(db, request_params=request_params)
    response.headers["Content-Range"] = f"{request_params.skip}-{request_params.skip + len(items)}/{total}"
    return items


# noinspection PyUnusedLocal
@router.post("/", response_model=schemas.TypedDiscipline)
async def create_typed_discipline(
        *,
        db: AsyncSession = Depends(deps.get_db),
        item_in: schemas.TypedDisciplineCreate,
        current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Create new TypedDiscipline.
    """
    item = await crud.typed_discipline.create(db=db, obj_in=item_in)
    return item


# noinspection PyUnusedLocal
@router.put("/{id}", response_model=schemas.TypedDiscipline)
async def update_typed_discipline_id(
        *,
        db: AsyncSession = Depends(deps.get_db),
        id: int,
        item_in: schemas.TypedDisciplineUpdate,
        current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Update an TypedDiscipline.
    """
    item = await crud.typed_discipline.get(db=db, id=id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    item = await crud.typed_discipline.update(db=db, db_obj=item, obj_in=item_in)
    return item


# noinspection PyUnusedLocal
@router.get("/{id}", response_model=schemas.TypedDiscipline)
async def read_typed_discipline_id(
        *,
        db: AsyncSession = Depends(deps.get_db),
        id: int,
        current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Get TypedDiscipline by ID.
    """
    item = await crud.typed_discipline.get(db=db, id=id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    return item


# noinspection PyUnusedLocal
@router.delete("/{id}", response_model=schemas.TypedDiscipline)
async def delete_typed_discipline_id(
        *,
        db: AsyncSession = Depends(deps.get_db),
        id: int,
        current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Delete an TypedDiscipline.
    """
    item = await crud.typed_discipline.get(db=db, id=id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    item = await crud.typed_discipline.remove(db=db, id=id)
    return item
