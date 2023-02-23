from typing import Any, List

from fastapi import APIRouter, Depends, HTTPException, Response
from sqlalchemy.ext.asyncio import AsyncSession

from app import crud, schemas, models
from app.schemas.request_params import RequestParams
from app.api.deps import auth, params, database

router = APIRouter()


# noinspection PyUnusedLocal
@router.get("/", response_model=List[schemas.StudyGroup])
async def read_study_group(
    response: Response,
    db: AsyncSession = Depends(database.get_db),
    current_user: models.User = Depends(auth.get_current_active_user),
    request_params: RequestParams = Depends(
        params.parse_react_admin_params(models.StudyGroup)
    ),
) -> Any:
    """
    Retrieve StudyGroups.
    """
    items, total = await crud.study_group.get_multi(db, request_params=request_params)
    response.headers[
        "Content-Range"
    ] = f"{request_params.skip}-{request_params.skip + len(items)}/{total}"
    return items


# noinspection PyUnusedLocal
@router.post("/", response_model=List[schemas.StudyGroup])
async def create_study_group(
    *,
    db: AsyncSession = Depends(database.get_db),
    item_in: schemas.StudyGroupCreate,
    current_user: models.User = Depends(auth.get_current_active_user),
) -> Any:
    """
    Create new StudyGroup.
    """
    item = await crud.study_group.create_with_disciplines(db=db, obj_in=item_in)
    return item


# noinspection PyUnusedLocal
@router.put("/{id}", response_model=schemas.StudyGroup)
async def update_study_group_id(
    *,
    db: AsyncSession = Depends(database.get_db),
    id: str,
    item_in: schemas.StudyGroupUpdate,
    current_user: models.User = Depends(auth.get_current_active_user),
) -> Any:
    """
    Update an StudyGroup.
    """
    item = await crud.study_group.get(db=db, id=id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    item = await crud.study_group.update(db=db, db_obj=item, obj_in=item_in)
    return item


# noinspection PyUnusedLocal
@router.get("/{id}", response_model=schemas.StudyGroup)
async def read_study_group_id(
    *,
    db: AsyncSession = Depends(database.get_db),
    id: str,
    current_user: models.User = Depends(auth.get_current_active_user),
) -> Any:
    """
    Get StudyGroup by ID.
    """
    item = await crud.study_group.get(db=db, id=id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    return item


# noinspection PyUnusedLocal
@router.delete("/{id}", response_model=schemas.StudyGroup)
async def delete_study_group_id(
    *,
    db: AsyncSession = Depends(database.get_db),
    id: str,
    current_user: models.User = Depends(auth.get_current_active_user),
) -> Any:
    """
    Delete an StudyGroup.
    """
    item = await crud.study_group.get(db=db, id=id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    item = await crud.study_group.remove(db=db, id=id)
    return item