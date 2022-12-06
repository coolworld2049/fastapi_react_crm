from datetime import datetime
from typing import Any, Dict, Optional, Union, List

import sqlalchemy
from asyncpg import Connection
from pydantic.schema import Literal
from sqlalchemy import select, or_
from sqlalchemy.engine import Result
from sqlalchemy.ext.asyncio import AsyncSession

from backend.app import schemas
from backend.app.core.config import ROOT_PATH
from backend.app.core.security import get_password_hash, verify_password
from backend.app.crud.base import CRUDBase
from backend.app.db.session import database
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

    async def get_by_email(self, db: AsyncSession, *, email: str) -> Optional[User]:  # noqa
        result: Result = await db.execute(sqlalchemy.select(User).where(User.email == email))
        return result.scalar()

    async def get_multi_by_filter(self, db: AsyncSession,  # noqa
                                  request_params: RequestParams,
                                  user_filter: schemas.UserFilter = None,
                                  role: Optional[str] = None,
                                  employees: Optional[bool] = None,
                                  ) -> List[User]:
        query = select(User)
        if user_filter:
            query = user_filter.filter(query)
            query = user_filter.sort(query)
        if role:
            query = query.where(User.role == role)
        if employees:
            query = query.filter(
                or_(User.role == schemas.userRole.manager_base, User.role == schemas.userRole.ranker_base))
        query = query.offset(request_params.skip).limit(request_params.limit).order_by(request_params.order_by)
        result: Result = await db.execute(query)
        return result.scalars().all()

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
    async def generate_report(
            self,
            id: int,
            start_timestamp: datetime,
            end_timestamp: datetime,
            ext: Literal['csv', 'json']
    ) -> Dict[str, str]:
        filename = f'user_{id}_report-delta_{start_timestamp.date()}_{end_timestamp.date()}.{ext}'
        path_in = f'/tmp/{filename}'
        path_out = f'{ROOT_PATH}/volumes/postgres/tmp/{filename}'

        q_csv = f'''
         COPY (select * from generate_report_by_period_and_employee(
            '{start_timestamp}'::timestamp,
            '{end_timestamp}'::timestamp,
            {id}
            )) to '{path_in}' delimiter ',' csv header;
        '''
        q_json = f'''
        COPY (select array_to_json(array_agg(row_to_json(results))) from generate_report_by_period_and_employee(
            '{start_timestamp}'::timestamp,
            '{end_timestamp}'::timestamp,
            {id}
            ) as results) to '{path_in}' with (format text, header false );
        '''
        conn: Connection = await database.get_connection()
        if ext == 'csv':
            await conn.execute(q_csv)
        elif ext == 'json':
            await conn.execute(q_json)

        return {'path_in': path_in, 'path_out': path_out, 'filename': filename}


user = CRUDUser(User)
