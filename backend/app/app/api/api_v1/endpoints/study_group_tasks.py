from typing import Any, List

from fastapi import APIRouter, Depends, HTTPException, Response
from sqlalchemy.ext.asyncio import AsyncSession

from app import crud, schemas, models
from app.schemas.request_params import RequestParams
from app.api.deps import auth, params, database

router = APIRouter()


# noinspection PyUnusedLocal
@router.get("/", response_model=List[schemas.StudyGroupTask])
async def read_study_group_discipline(
    response: Response,
    db: AsyncSession = Depends(database.get_db),
    current_user: models.User = Depends(auth.get_current_active_user),
    request_params: RequestParams = Depends(
        params.parse_react_admin_params(models.StudyGroupTask)
    ),
) -> Any:
    """
    Retrieve StudyGroupTasks.
    """
    items, total = await crud.study_group_task.get_multi(
        db, request_params=request_params
    )
    response.headers[
        "Content-Range"
    ] = f"{request_params.skip}-{request_params.skip + len(items)}/{total}"
    return items


# noinspection PyUnusedLocal
@router.put("/{id}", response_model=schemas.StudyGroupTask)
async def update_study_group_discipline_id(
    *,
    db: AsyncSession = Depends(database.get_db),
    id: int,
    item_in: schemas.StudyGroupTaskUpdate,
    current_user: models.User = Depends(auth.get_current_active_user),
) -> Any:
    """
    Update an StudyGroupTask.
    """
    item = await crud.study_group_task.get(db=db, id=id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    item = await crud.study_group_task.update(db=db, db_obj=item, obj_in=item_in)
    return item


# noinspection PyUnusedLocal
@router.get("/{id}", response_model=schemas.StudyGroupTask)
async def read_study_group_discipline_id(
    *,
    db: AsyncSession = Depends(database.get_db),
    id: int,
    current_user: models.User = Depends(auth.get_current_active_user),
) -> Any:
    """
    Get StudyGroupTask by ID.
    """
    item = await crud.study_group_task.get(db=db, id=id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    return item


# noinspection PyUnusedLocal
@router.delete("/{id}", response_model=schemas.StudyGroupTask)
async def delete_study_group_discipline_id(
    *,
    db: AsyncSession = Depends(database.get_db),
    id: int,
    current_user: models.User = Depends(auth.get_current_active_user),
) -> Any:
    """
    Delete an StudyGroupTask.
    """
    item = await crud.study_group_task.get(db=db, id=id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    item = await crud.study_group_task.remove(db=db, id=id)
    return item
