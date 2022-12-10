from typing import Any, Dict, Generic, List, Optional, Type, TypeVar, Union, Tuple

from fastapi.encoders import jsonable_encoder
from pydantic import BaseModel
from sqlalchemy import select, or_, func
from sqlalchemy.engine import Result
from sqlalchemy.ext.asyncio import AsyncSession

from backend.app.db.base_class import Base
from backend.app.schemas.request_params import RequestParams

ModelType = TypeVar("ModelType", bound=Base)
CreateSchemaType = TypeVar("CreateSchemaType", bound=BaseModel)
UpdateSchemaType = TypeVar("UpdateSchemaType", bound=BaseModel)


class CRUDBase(Generic[ModelType, CreateSchemaType, UpdateSchemaType]):
    def __init__(self, model: Type[ModelType]):
        """
        CRUD object with default methods to Create, Read, Update, Delete (CRUD).
        **Parameters**
        * `model`: A SQLAlchemy model class
        * `schema`: A Pydantic model (schema) class
        """
        self.model = model

    async def get(self, db: AsyncSession, id: Any) -> Optional[ModelType]:
        result: Result = await db.execute(select(self.model).where(self.model.id == id))
        return result.scalar()

    async def get_multi(
            self, db: AsyncSession, request_params: RequestParams, role: str = None, roles: tuple[str] = None,
    ) -> Tuple[List[ModelType], int]:
        query = select(self.model)
        query_count = select(func.count(self.model.id))
        if request_params.filter_by is not None:
            query = query.filter(request_params.filter_by)
            query_count = query_count.filter(request_params.filter_by)
        if role and not roles:
            query = query.filter(self.model.role == role)
            query_count = query_count.filter(self.model.role == role)
        elif roles:
            f = [self.model.role == r for r in roles]
            query = query.filter(or_(*f))
            query_count = query_count.filter(or_(*f))
        total: Result = await db.execute(query_count)
        query = query.offset(request_params.skip) \
            .limit(request_params.limit) \
            .order_by(request_params.order_by)
        result: Result = await db.execute(query)
        return result.scalars().all(), total.scalar()

    async def create(self, db: AsyncSession, *, obj_in: CreateSchemaType) -> ModelType:
        obj_in_data = jsonable_encoder(obj_in)
        db_obj = self.model(**obj_in_data)
        db.add(db_obj)
        await db.commit()
        await db.refresh(db_obj)
        return db_obj

    async def update(
            self,
            db: AsyncSession,
            *,
            db_obj: ModelType,
            obj_in: Union[UpdateSchemaType, Dict[str, Any]]
    ) -> ModelType:
        obj_data = jsonable_encoder(db_obj)
        if isinstance(obj_in, dict):
            update_data = obj_in
        else:
            update_data = obj_in.dict(exclude_unset=True)
        for field in obj_data:
            if field in update_data:
                setattr(db_obj, field, update_data[field])
        db.add(db_obj)
        await db.commit()
        await db.refresh(db_obj)
        return db_obj

    async def remove(self, db: AsyncSession, *, id: int) -> ModelType:
        obj = await self.get(db, id)
        await db.delete(obj)
        await db.commit()
        return obj
