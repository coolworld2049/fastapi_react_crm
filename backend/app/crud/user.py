from datetime import datetime
from typing import Any, Dict, Optional, Union, List

import sqlalchemy
from asyncpg import Connection
from pydantic.schema import Literal
from sqlalchemy import select, or_, and_
from sqlalchemy.engine import Result
from sqlalchemy.ext.asyncio import AsyncSession

from backend.app import schemas
from backend.app.core.config import ROOT_PATH
from backend.app.core.security import get_password_hash, verify_password
from backend.app.crud.base import CRUDBase
from backend.app.db.session import asyncpg_database
from backend.app.models.user import User
from backend.app.schemas.request_params import RequestParams
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

    async def get_by_id(self, db: AsyncSession, *, id: int) -> Optional[User]:  # noqa
        result: Result = await db.execute(sqlalchemy.select(User).where(User.id == id))
        return result.scalar()

    async def get_by_id_role(self, db: AsyncSession, *, id: int, role: str) -> Optional[User]:  # noqa
        result: Result = await db.execute(sqlalchemy.select(User).where(and_(User.id == id, User.role == role)))
        return result.scalar()

    async def get_by_email(self, db: AsyncSession, *, email: str) -> Optional[User]:  # noqa
        result: Result = await db.execute(sqlalchemy.select(User).where(User.email == email))
        return result.scalar()

    async def authenticate(
            self,
            *,
            email: str,
            password: str,
            db: AsyncSession,
    ) -> Optional[User]:
        user = await self.get_by_email(db, email=email)  # noqa
        if not user:
            return None
        if not verify_password(password, user.hashed_password):
            return None
        return user

    def is_active(self, user: User) -> bool:  # noqa
        return user.is_active

    def is_superuser(self, user: User) -> bool:  # noqa
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
            await conn.execute(q_csv)
        elif report_in.ext == 'json':
            await conn.execute(q_json)
        return {'path_in': path_in, 'path_out': path_out, 'filename': filename}


user = CRUDUser(User)
