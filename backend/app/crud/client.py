from typing import Any, Dict, Union

from sqlalchemy.ext.asyncio import AsyncSession

from backend.app.crud.base import CRUDBase
from backend.app.models import Client
from backend.app.schemas import ClientCreate, ClientUpdate


class CRUDClient(CRUDBase[Client, ClientCreate, ClientUpdate]):

    async def create(self, db: AsyncSession, *, obj_in: ClientCreate) -> Client:
        create_data: dict = obj_in.dict()
        db_obj = Client(**create_data)
        db.add(db_obj)
        await db.commit()
        return db_obj

    async def update(
            self, db: AsyncSession, *, db_obj: Client, obj_in: Union[ClientUpdate, Dict[str, Any]]
    ) -> Client:
        if isinstance(obj_in, dict):
            update_data = obj_in
        else:
            update_data = obj_in.dict(exclude_unset=True)
        result = await super().update(db, db_obj=db_obj, obj_in=update_data)
        return result


client = CRUDClient(Client)
