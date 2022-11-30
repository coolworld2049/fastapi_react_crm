from typing import Any, Dict, Optional, Union, List

import sqlalchemy
from sqlalchemy import select, or_
from sqlalchemy.engine import Result
from sqlalchemy.ext.asyncio import AsyncSession

from backend.app import schemas
from backend.app.core.security import get_password_hash, verify_password
from backend.app.crud.base import CRUDBase
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

    async def get_multi_by_filter(self, db: AsyncSession, request_params: RequestParams,   # noqa
                                  user_filter: schemas.UserFilter = None,
                                  role: Optional[str] = None,
                                  employees: Optional[bool] = None,
                                  ) -> List[User]:
        query = select(User)
        query = query.offset(request_params.skip).limit(request_params.limit).order_by(request_params.order_by)
        if user_filter:
            query = user_filter.filter(query)
            query = user_filter.sort(query)
        if role:
            query = query.where(User.role == role)
        if employees:
            query = query.filter(or_(User.role == schemas.userRole.manager_base, User.role == schemas.userRole.ranker_base))
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


user = CRUDUser(User)
