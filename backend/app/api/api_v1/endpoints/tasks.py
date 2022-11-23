from typing import Any, List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from backend.app import crud, models, schemas
from backend.app.api import deps

router = APIRouter()


@router.get("/", response_model=List[schemas.Task])
async def read_tasks(
        db: Session = Depends(deps.get_async_session),
        skip: int = 0,
        limit: int = 100,
        current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Retrieve Tasks.
    """
    if crud.user.is_superuser(current_user):
        items = crud.task.get_multi(db, skip=skip, limit=limit)
    else:
        items = await crud.task.get_multi_by_author(
            db=db, author_id=current_user.id, skip=skip, limit=limit
        )
    return items


# noinspection PyUnusedLocal
@router.post("/", response_model=schemas.Task)
async def create_task(
        *,
        db: Session = Depends(deps.get_async_session),
        item_in: schemas.TaskCreate,
        current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Create new task.
    """
    item = await crud.task.create_with_author(db=db, obj_in=item_in)
    return item


@router.put("/{id}", response_model=schemas.Task)
async def update_task(
        *,
        db: Session = Depends(deps.get_async_session),
        id: int,
        item_in: schemas.TaskUpdate,
        current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Update an task.
    """
    item = crud.task.get(db=db, id=id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    if not crud.user.is_superuser(current_user) and (item.owner_id != current_user.id):
        raise HTTPException(status_code=400, detail="Not enough permissions")
    item = crud.task.update(db=db, db_obj=item, obj_in=item_in)
    return item


@router.get("/{id}", response_model=schemas.Task)
async def read_task(
        *,
        db: Session = Depends(deps.get_async_session),
        id: int,
        current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Get task by ID.
    """
    item = crud.task.get(db=db, id=id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    if not crud.user.is_superuser(current_user) and (item.owner_id != current_user.id):
        raise HTTPException(status_code=400, detail="Not enough permissions")
    return item


@router.delete("/{id}", response_model=schemas.Task)
async def delete_task(
        *,
        db: Session = Depends(deps.get_async_session),
        id: int,
        current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Delete an task.
    """
    item = crud.task.get(db=db, id=id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    if not crud.user.is_superuser(current_user) and (item.owner_id != current_user.id):
        raise HTTPException(status_code=400, detail="Not enough permissions")
    item = crud.task.remove(db=db, id=id)
    return item
