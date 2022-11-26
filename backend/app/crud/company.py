from typing import Any, Dict, Union

from sqlalchemy.ext.asyncio import AsyncSession

from backend.app.crud.base import CRUDBase
from backend.app.models import Company
from backend.app.schemas import CompanyCreate, CompanyUpdate


class CRUDCompany(CRUDBase[Company, CompanyCreate, CompanyUpdate]):

    async def create(self, db: AsyncSession, *, obj_in: CompanyCreate) -> Company:
        create_data: dict = obj_in.dict()
        db_obj = Company(**create_data)
        db.add(db_obj)
        await db.commit()
        return db_obj

    async def update(
            self, db: AsyncSession, *, db_obj: Company, obj_in: Union[CompanyUpdate, Dict[str, Any]]
    ) -> Company:
        if isinstance(obj_in, dict):
            update_data = obj_in
        else:
            update_data = obj_in.dict(exclude_unset=True)
        result = await super().update(db, db_obj=db_obj, obj_in=update_data)
        return result


company = CRUDCompany(Company)
