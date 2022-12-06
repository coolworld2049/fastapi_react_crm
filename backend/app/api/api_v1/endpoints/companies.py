from typing import Any, List

from fastapi import APIRouter, Depends, HTTPException, Response
from sqlalchemy import select, func
from sqlalchemy.engine import Result
from sqlalchemy.exc import ProgrammingError
from sqlalchemy.ext.asyncio import AsyncSession

from backend.app import crud, models, schemas
from backend.app.api import deps
from backend.app.schemas.request_params import RequestParams

router = APIRouter()


@router.get("/", response_model=List[schemas.Company])
async def read_companies(
        response: Response,
        db: AsyncSession = Depends(deps.get_async_session),
        current_user: models.User = Depends(deps.get_current_active_user), # noqa
        request_params: RequestParams = Depends(deps.parse_react_admin_params(models.Company)) # noqa
) -> Any:
    """
    Retrieve Tasks.
    """
    try:
        total: Result = await db.execute(select(func.count(models.Company.id)))
    except ProgrammingError:
        raise HTTPException(status_code=404, detail="InsufficientPrivilegeError")
    items = await crud.company.get_multi(db, request_params=request_params)
    response.headers["Content-Range"] = f"{request_params.skip}-{request_params.skip + len(items)}/{len(total.scalars().all())}"
    return items


# noinspection PyUnusedLocal
@router.post("/", response_model=schemas.Company)
async def create_company(
        *,
        db: AsyncSession = Depends(deps.get_async_session),
        item_in: schemas.CompanyCreate,
        current_user: models.User = Depends(deps.get_current_active_superuser),
) -> Any:
    """
    Create new company.
    """
    item = await crud.company.create(db=db, obj_in=item_in)
    return item


@router.put("/{id}", response_model=schemas.Company)
async def update_company(
        *,
        db: AsyncSession = Depends(deps.get_async_session),
        id: int,
        item_in: schemas.CompanyUpdate,
        current_user: models.User = Depends(deps.get_current_active_superuser), # noqa
) -> Any:
    """
    Update a company.
    """
    item = await crud.company.get(db=db, id=id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    item = await crud.company.update(db=db, db_obj=item, obj_in=item_in)
    return item


@router.get("/{id}", response_model=schemas.Company)
async def read_company(
        *,
        db: AsyncSession = Depends(deps.get_async_session),
        id: int,
        current_user: models.User = Depends(deps.get_current_active_superuser), # noqa
) -> Any:
    """
    Get company by ID.
    """
    item = await crud.company.get(db=db, id=id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    return item


@router.delete("/{id}", response_model=schemas.Company)
async def delete_company(
        *,
        db: AsyncSession = Depends(deps.get_async_session),
        id: int,
        current_user: models.Company = Depends(deps.get_current_active_superuser), # noqa
) -> Any:
    """
    Delete a company.
    """
    item = await crud.company.get(db=db, id=id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    item = await crud.company.remove(db=db, id=id)
    return item
