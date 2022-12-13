from sqlalchemy.ext.asyncio import AsyncSession

from backend.app.crud.base import CRUDBase
from backend.app.db.models import Task
from backend.app.schemas import TaskCreate, TaskUpdate


class CRUDTask(CRUDBase[Task, TaskCreate, TaskUpdate]):
    async def create(
            self, db: AsyncSession, *, obj_in: TaskCreate
    ) -> Task:
        create_data: dict = obj_in.dict()
        db_obj = self.model(**create_data)  
        db.add(db_obj)
        await db.commit()
        return db_obj


task = CRUDTask(Task)
