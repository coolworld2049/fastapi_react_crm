from typing import List

from sqlalchemy import select
from sqlalchemy.engine import Result
from sqlalchemy.ext.asyncio import AsyncSession

from backend.app.crud.base import CRUDBase
from backend.app.models import Task
from backend.app.schemas import TaskCreate, TaskUpdate
from backend.app.schemas.request_params import RequestParams


class CRUDTask(CRUDBase[Task, TaskCreate, TaskUpdate]):
    async def create(
            self, db: AsyncSession, *, obj_in: TaskCreate
    ) -> Task:
        create_data: dict = obj_in.dict()
        db_obj = self.model(**create_data) # noqa
        db.add(db_obj)
        await db.commit()
        return db_obj

    async def get_multi_by_author(
            self, db: AsyncSession, *, author_id: int, request_params: RequestParams
    ) -> List[Task]:
        query = select(self.model).filter(self.model.author_id == author_id)\
            .offset(request_params.skip)\
            .limit(request_params.limit) \
            .order_by(request_params.order_by)
        result: Result = await db.execute(query)
        return result.scalars().all()


task = CRUDTask(Task)
