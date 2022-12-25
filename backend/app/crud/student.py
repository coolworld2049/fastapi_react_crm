from typing import Any, Union

from sqlalchemy.ext.asyncio import AsyncSession

from backend.app import schemas, crud
from backend.app.crud import CRUDBase
from backend.app.db import Student, models
from backend.app.schemas import StudentUpdate, StudentCreate


class CRUDStudent(CRUDBase[Student, StudentCreate, StudentUpdate]):
    async def create(self, db: AsyncSession, *, obj_in: Union[Any, schemas.UserCreate]) -> Student:
        user_in = schemas.UserCreate(**obj_in)
        user_in.role = obj_in.get('user_role') if obj_in.get('user_role') else user_in.role
        user_db_obj: models.User = await  crud.user.get_by_email(db, email=user_in.email)
        if not user_db_obj:
            user_db_obj = await crud.user.create(db, obj_in=user_in)

        student_in = schemas.StudentUpdate(
            id=user_db_obj.id,
            **obj_in.dict(exclude_none=True)
        )
        db_obj: models.Student = await crud.student.get(db, id=user_db_obj.id)
        await crud.student.update(db, db_obj=db_obj ,obj_in=student_in)
        await db.refresh(db_obj)
        return db_obj

student = CRUDStudent(Student)
