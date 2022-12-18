from typing import Any, Dict, Optional, Union, Tuple, List

import sqlalchemy
from sqlalchemy import and_
from sqlalchemy.engine import Result
from sqlalchemy.ext.asyncio import AsyncSession

from backend.app.core.security import get_password_hash, verify_password
from backend.app.crud.base import CRUDBase
from backend.app.db import User, Student, Teacher
from backend.app.schemas import RequestParams
from backend.app.schemas.student import StudentUpdate, StudentCreate
from backend.app.schemas.teacher import TeacherUpdate, TeacherCreate
from backend.app.schemas.user import UserCreate, UserUpdate


class CRUDUser(CRUDBase[User, UserCreate, UserUpdate]):

    async def create(self, db: AsyncSession, *, obj_in: UserCreate) -> User:
        create_data: dict = obj_in.dict()
        create_data.pop("password")
        db_obj = User(**create_data)
        db_obj.hashed_password = get_password_hash(obj_in.password)
        db.add(db_obj)
        await db.commit()
        return db_obj

    async def update(
            self, db: AsyncSession, *, db_obj: User, obj_in: Union[UserUpdate, Dict[str, Any]]
    ) -> User:
        if isinstance(obj_in, dict):
            update_data = obj_in
        else:
            update_data = obj_in.dict(exclude_unset=True)
        if update_data.get('password'):
            update_data.pop('password')
            update_data.update({'hashed_password': get_password_hash(obj_in.password)})
        result = await super().update(db, db_obj=db_obj, obj_in=update_data)
        return result

    # noinspection PyMethodMayBeStatic
    async def get_by_id(self, db: AsyncSession, *, id: int, role: str = None) -> Optional[User]:
        q = sqlalchemy.select(User)
        if role:
            q = q.filter(User.role == role)
        result: Result = await db.execute(q.where(User.id == id))
        return result.scalar()

    # noinspection PyMethodMayBeStatic
    async def get_by_email(self, db: AsyncSession, *, email: str) -> Optional[User]:
        result: Result = await db.execute(sqlalchemy.select(User).where(User.email == email))
        return result.scalar()

    async def constr_user_role_filter(self, roles: list[str], column: Any  = None):
        c_filter = None
        if roles:
            if column is None:
                c_filter = and_(self.model.role.in_(tuple(roles)))
            else:
                c_filter = and_(column.in_(tuple(roles)))
        return c_filter

    async def get_multi(
            self, db: AsyncSession, request_params: RequestParams, roles: list[str] = None,
    ) -> Tuple[List[User], int]:
        flt = await self.constr_user_role_filter(roles)
        users, total = await super().get_multi(db, request_params, flt)
        return users, total

    # noinspection PyShadowingNames
    async def authenticate(
            self,
            *,
            email: str,
            password: str,
            db: AsyncSession,
    ) -> Optional[User]:
        user = await self.get_by_email(db, email=email)
        if not user:
            return None
        if not verify_password(password, user.hashed_password):
            return None
        return user

    # noinspection PyMethodMayBeStatic,PyShadowingNames
    def is_active(self, user: User) -> bool:
        return user.is_active

    # noinspection PyMethodMayBeStatic,PyShadowingNames
    def is_superuser(self, user: User) -> bool:
        return user.is_superuser


user = CRUDUser(User)


class CRUDStudent(CRUDBase[Student, StudentCreate, StudentUpdate]):
    pass

student = CRUDStudent(Student)


class CRUDTeacher(CRUDBase[Teacher, TeacherCreate, TeacherUpdate]):
    pass


teacher = CRUDTeacher(Teacher)
