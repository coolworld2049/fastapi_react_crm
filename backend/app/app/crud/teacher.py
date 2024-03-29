from typing import Any, Union, List

from sqlalchemy import select
from sqlalchemy.engine import Result
from sqlalchemy.ext.asyncio import AsyncSession

import app.models.domain
from app import schemas, crud, models
from app.crud import CRUDBase
from app.schemas import TeacherCreate, TeacherUpdate


class CRUDTeacher(CRUDBase[models.Teacher, TeacherCreate, TeacherUpdate]):
    async def get(self, db: AsyncSession, user_id: Any) -> List[models.Teacher]:
        q = select(self.model).filter(self.model.user_id == user_id)
        result: Result = await db.execute(q)
        return result.scalars().all()

    async def create_multi(
        self, db: AsyncSession, *, obj_in: Union[Any, schemas.UserCreate]
    ) -> models.Teacher | List[models.Teacher]:
        user_in = schemas.UserCreate(**obj_in)
        user_in.role = (
            obj_in.get("user_role") if obj_in.get("user_role") else user_in.role
        )
        user_db_obj: app.db.models.User = await crud.user.get_by_email(
            db, email=user_in.email
        )
        if not user_db_obj:
            user_db_obj = await crud.user.create(db, obj_in=user_in)

        teacher_in = schemas.TeacherCreate(user_id=user_db_obj.id, **obj_in)
        if isinstance(teacher_in.discipline_id, list):
            teachers: list[models.Teacher] = [
                models.Teacher(
                    **schemas.TeacherCreate(user_id=teacher_in.user_id, **d).dict(
                        exclude_none=True
                    )
                )
                for d in teacher_in.discipline_id
            ]
            db.add_all(teachers)
            await db.commit()
            for t in teachers:
                await db.refresh(t)
            return teachers
        elif isinstance(teacher_in.discipline_id, int):
            return await super().create(db, obj_in=teacher_in)


teacher = CRUDTeacher(models.Teacher)
