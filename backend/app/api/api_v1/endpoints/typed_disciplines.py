from typing import Any, List

from fastapi import APIRouter, Depends, HTTPException, Response
from sqlalchemy.ext.asyncio import AsyncSession

from backend.app import crud, schemas
from backend.app.api import deps
from backend.app.db import models
from backend.app.schemas.request_params import RequestParams

router = APIRouter()


# noinspection PyUnusedLocal
@router.get("/", response_model=List[schemas.DisciplineTyped])
async def read_discipline_typed(
        response: Response,
        db: AsyncSession = Depends(deps.get_db),
        current_user: models.User = Depends(deps.get_current_active_user),
        request_params: RequestParams = Depends(deps.parse_react_admin_params(models.DisciplineTyped))
) -> Any:
    """
    Retrieve DisciplineTyped.
    """
    items, total = await crud.discipline_typed.get_multi(db, request_params=request_params)
    response.headers["Content-Range"] = f"{request_params.skip}-{request_params.skip + len(items)}/{total}"
    return items


# noinspection PyUnusedLocal
@router.post("/", response_model=schemas.DisciplineTyped)
async def create_discipline_typed(
        *,
        db: AsyncSession = Depends(deps.get_db),
        item_in: schemas.DisciplineTypedCreate,
        current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Create new DisciplineTyped.
    """
    item = await crud.discipline_typed.create(db=db, obj_in=item_in)
    return item


# noinspection PyUnusedLocal
@router.put("/{id}", response_model=schemas.DisciplineTyped)
async def update_discipline_typed_id(
        *,
        db: AsyncSession = Depends(deps.get_db),
        id: int,
        item_in: schemas.DisciplineTypedUpdate,
        current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Update an DisciplineTyped.
    """
    item = await crud.discipline_typed.get(db=db, id=id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    item = await crud.discipline_typed.update(db=db, db_obj=item, obj_in=item_in)
    return item


# noinspection PyUnusedLocal
@router.get("/{id}", response_model=schemas.DisciplineTyped)
async def read_discipline_typed_id(
        *,
        db: AsyncSession = Depends(deps.get_db),
        id: int,
        current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Get DisciplineTyped by ID.
    """
    item = await crud.discipline_typed.get(db=db, id=id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    return item


# noinspection PyUnusedLocal
@router.delete("/{id}", response_model=schemas.DisciplineTyped)
async def delete_discipline_typed_id(
        *,
        db: AsyncSession = Depends(deps.get_db),
        id: int,
        current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Delete an DisciplineTyped.
    """
    item = await crud.discipline_typed.get(db=db, id=id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    item = await crud.discipline_typed.remove(db=db, id=id)
    return item
