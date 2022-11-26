from typing import List

from sqlalchemy import select
from sqlalchemy.engine import Result
from sqlalchemy.ext.asyncio import AsyncSession

from backend.app.crud.base import CRUDBase
from backend.app.models import Task
from backend.app.schemas import TaskCreate, TaskUpdate


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
            self, db: AsyncSession, *, author_id: int, skip: int = 0, limit: int = 100
    ) -> List[Task]:
        query = (
            select(
                self.model
                .filter(Task.author_id == author_id)
                .offset(skip)
                .limit(limit)
            )
        )
        result: Result = await db.execute(query)
        return await result.scalars().all()


task = CRUDTask(Task)
