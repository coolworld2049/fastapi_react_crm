from typing import Any, List

from fastapi import APIRouter, Depends, HTTPException, Response
from sqlalchemy.ext.asyncio import AsyncSession


from app import crud, schemas, models
from app.schemas.request_params import RequestParams
from app.api.deps import auth, params, database

router = APIRouter()


# noinspection PyUnusedLocal
@router.get("/", response_model=List[schemas.StudentTaskStore])
async def read_task_stores(
    response: Response,
    db: AsyncSession = Depends(database.get_db),
    current_user: models.User = Depends(auth.get_current_active_user),
    request_params: RequestParams = Depends(
        params.parse_react_admin_params(models.StudentTaskStore)
    ),
) -> Any:
    """
    Retrieve StudentTaskStores.
    """
    items, total = await crud.student_task_store.get_multi(
        db, request_params=request_params
    )
    response.headers[
        "Content-Range"
    ] = f"{request_params.skip}-{request_params.skip + len(items)}/{total}"
    return items


# noinspection PyUnusedLocal
@router.post("/", response_model=schemas.StudentTaskStore)
async def create_task_store(
    *,
    db: AsyncSession = Depends(database.get_db),
    item_in: schemas.StudentTaskStoreCreate,
    current_user: models.User = Depends(auth.get_current_active_user),
) -> Any:
    """
    Create new task_store.
    """
    item = await crud.student_task_store.create(db=db, obj_in=item_in)
    return item


# noinspection PyUnusedLocal
@router.put("/{id}", response_model=schemas.StudentTaskStore)
async def update_task_store(
    *,
    db: AsyncSession = Depends(database.get_db),
    id: int,
    item_in: schemas.StudentTaskStoreUpdate,
    current_user: models.User = Depends(auth.get_current_active_user),
) -> Any:
    """
    Update an task_store.
    """
    item = await crud.student_task_store.get(db=db, id=id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    item = await crud.student_task_store.update(db=db, db_obj=item, obj_in=item_in)
    return item


# noinspection PyUnusedLocal
@router.get("/{id}", response_model=schemas.StudentTaskStore)
async def read_task_store(
    *,
    db: AsyncSession = Depends(database.get_db),
    id: int,
    current_user: models.User = Depends(auth.get_current_active_user),
) -> Any:
    """
    Get task_store by ID.
    """
    item = await crud.student_task_store.get(db=db, id=id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    return item


# noinspection PyUnusedLocal
@router.delete("/{id}", response_model=schemas.StudentTaskStore)
async def delete_task_store(
    *,
    db: AsyncSession = Depends(database.get_db),
    id: int,
    current_user: models.User = Depends(auth.get_current_active_user),
) -> Any:
    """
    Delete an task_store.
    """
    item = await crud.student_task_store.get(db=db, id=id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    item = await crud.student_task_store.remove(db=db, id=id)
    return item
