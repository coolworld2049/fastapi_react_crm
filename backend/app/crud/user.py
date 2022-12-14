from typing import Any, Dict, Optional, Union

import sqlalchemy
from asyncpg import Connection
from sqlalchemy.engine import Result
from sqlalchemy.ext.asyncio import AsyncSession

from backend.app import schemas
from backend.app.core.config import ROOT_PATH
from backend.app.core.security import get_password_hash, verify_password
from backend.app.crud.base import CRUDBase
from backend.app.db import User, Student, Teacher, UserContact
from backend.app.db.session import asyncpg_database
from backend.app.schemas import StudentUpdate, StudentCreate, TeacherCreate, TeacherUpdate, UserContactUpdate, \
    UserContactCreate
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
    async def get_by_id(self, db: AsyncSession, *, id: int) -> Optional[User]:
        result: Result = await db.execute(sqlalchemy.select(User).where(User.id == id))
        return result.scalar()

    # noinspection PyMethodMayBeStatic
    async def get_by_id_role(self, db: AsyncSession, *, id: int, role: str) -> Optional[User]:
        query = sqlalchemy.select(User).filter(User.role == role).filter(User.id == id)
        result: Result = await db.execute(query)
        return result.scalar()

    # noinspection PyMethodMayBeStatic
    async def get_by_email(self, db: AsyncSession, *, email: str) -> Optional[User]:
        result: Result = await db.execute(sqlalchemy.select(User).where(User.email == email))
        return result.scalar()

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

    # noinspection PyMethodMayBeStatic,PyUnusedLocal
    async def generate_report_user(
            self,
            report_in: schemas.ReportUserCreate
    ) -> Dict[str, str]:
        filename = f'user_{report_in.id}_report-delta_{report_in.start_timestamp.date()}_{report_in.end_timestamp.date()}.{report_in.ext}'
        path_in = f'/tmp/{filename}'
        path_out = f'{ROOT_PATH}/volumes/postgres/tmp/{filename}'

        q_csv = f'''
         COPY (select * from generate_report_by_period_and_employee(
            '{report_in.start_timestamp}',
            '{report_in.end_timestamp},
            {report_in.id}
            )) to '{path_in}' delimiter ',' csv header;
        '''
        q_json = f'''
        COPY (select array_to_json(array_agg(row_to_json(results))) from generate_report_by_period_and_employee(
            '{report_in.start_timestamp}',
            '{report_in.end_timestamp}',
            {report_in.id}
            ) as results) to '{path_in}' with (format text, header false );
        '''
        conn: Connection = await asyncpg_database.get_connection()
        if report_in.ext == 'csv':
            res = await conn.fetch(q_csv)
        elif report_in.ext == 'json':
            res = await conn.fetch(q_json)
        return {'path_in': path_in, 'path_out': path_out, 'filename': filename}


user = CRUDUser(User)


class CRUDUserContact(CRUDBase[UserContact, UserContactCreate, UserContactUpdate]):
   pass

user_contact = CRUDUserContact(UserContact)

class CRUDStudent(CRUDBase[Student, StudentCreate, StudentUpdate]):
   pass

student = CRUDStudent(Student)

class CRUDTeacher(CRUDBase[Teacher, TeacherCreate, TeacherUpdate]):
   pass

teacher = CRUDTeacher(Teacher)
