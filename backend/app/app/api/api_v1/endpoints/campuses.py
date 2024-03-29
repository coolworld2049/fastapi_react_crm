from typing import Any, List

from fastapi import APIRouter, Depends, HTTPException, Response
from sqlalchemy.ext.asyncio import AsyncSession

from app import crud, schemas, models
from app.schemas.request_params import RequestParams
from app.api.deps import auth, params, database

router = APIRouter()


# noinspection PyUnusedLocal
@router.get("/", response_model=List[schemas.Campus])
async def read_campuss(
    response: Response,
    db: AsyncSession = Depends(database.get_db),
    current_user: models.User = Depends(auth.get_current_active_user),
    request_params: RequestParams = Depends(
        params.parse_react_admin_params(models.Campus)
    ),
) -> Any:
    """
    Retrieve Campuss.
    """
    items, total = await crud.campus.get_multi(db, request_params=request_params)
    response.headers[
        "Content-Range"
    ] = f"{request_params.skip}-{request_params.skip + len(items)}/{total}"
    return items


# noinspection PyUnusedLocal
@router.post("/", response_model=schemas.Campus)
async def create_campus(
    *,
    db: AsyncSession = Depends(database.get_db),
    item_in: schemas.CampusCreate,
    current_user: models.User = Depends(auth.get_current_active_user),
) -> Any:
    """
    Create new Campus.
    """
    item = await crud.campus.create(db=db, obj_in=item_in)
    return item


# noinspection PyUnusedLocal
@router.put("/{id}", response_model=schemas.Campus)
async def update_campus_id(
    *,
    db: AsyncSession = Depends(database.get_db),
    id: int,
    item_in: schemas.CampusUpdate,
    current_user: models.User = Depends(auth.get_current_active_user),
) -> Any:
    """
    Update an Campus.
    """
    item = await crud.campus.get(db=db, id=id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    item = await crud.campus.update(db=db, db_obj=item, obj_in=item_in)
    return item


# noinspection PyUnusedLocal
@router.get("/{id}", response_model=schemas.Campus)
async def read_campus_id(
    *,
    db: AsyncSession = Depends(database.get_db),
    id: str,
    current_user: models.User = Depends(auth.get_current_active_user),
) -> Any:
    """
    Get Campus by ID.
    """
    item = await crud.campus.get(db=db, id=id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    return item


# noinspection PyUnusedLocal
@router.delete("/{id}", response_model=schemas.Campus)
async def delete_campus_id(
    *,
    db: AsyncSession = Depends(database.get_db),
    id: int,
    current_user: models.User = Depends(auth.get_current_active_user),
) -> Any:
    """
    Delete an Campus.
    """
    item = await crud.campus.get(db=db, id=id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    item = await crud.campus.remove(db=db, id=id)
    return item
