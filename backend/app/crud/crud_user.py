from datetime import datetime
from typing import Any, Dict, Optional, Union

import sqlalchemy
from sqlalchemy.engine import Result
from sqlalchemy.ext.asyncio import AsyncSession

from backend.app import schemas
from backend.app.core.security import get_password_hash, verify_password
from backend.app.crud.base import CRUDBase
from backend.app.models.user import User
from backend.app.schemas.user import UserCreate, UserUpdate


class CRUDUser(CRUDBase[User, UserCreate, UserUpdate]):

    async def create(self, db: AsyncSession, *, obj_in: UserCreate) -> User:
        obj_in.create_date.replace(tzinfo=None)
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

        return await super().update(db, db_obj=db_obj, obj_in=update_data)

    async def get_by_id(self, db: AsyncSession, *, id: int) -> Optional[User]:  # noqa
        result: Result = await db.execute(sqlalchemy.select(User).where(User.id == id))
        return result.scalar()

    async def get_by_email(self, db: AsyncSession, *, email: str) -> Optional[User]:  # noqa
        result: Result = await db.execute(sqlalchemy.select(User).where(User.email == email))
        return result.scalar()

    async def authenticate(  # noqa
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

    async def sign_up_new_user(self, db: AsyncSession, email: str, password: str):
        user = await self.get_by_email(db, email=email)  # noqa
        if user:
            return False  # User already exists
        obj_in = schemas.UserCreate(
            email=email,
            password=password
        )
        new_user = await self.create(
            db=db, obj_in=obj_in
        )
        return new_user

    def is_active(self, user: User) -> bool:  # noqa
        return user.is_active

    def is_superuser(self, user: User) -> bool:  # noqa
        return user.is_superuser


user = CRUDUser(User)
