from typing import Any, Dict, Generic, List, Optional, Type, TypeVar, Union, Tuple

from pydantic import BaseModel
from sqlalchemy import select, or_, func, and_
from sqlalchemy.engine import Result
from sqlalchemy.ext.asyncio import AsyncSession

from backend.app.db import Base
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

    async def constr_join_filter(self, query: Any, table_f_eq: Any = None, table_l: Any = None): # noqa
        return and_(table_f_eq == table_l) if table_f_eq and table_l else query

    async def constr_query_filter(self, query: Any, request_params: RequestParams, constr_filters: Any = None): # noqa
        if request_params.filter_by is not None:
            query = query.filter(request_params.filter_by)
        if constr_filters is not None:
            query = query.filter(constr_filters)
        query = query.offset(request_params.skip) \
            .limit(request_params.limit) \
            .order_by(request_params.order_by)
        return query

    async def get_multi(
            self, db: AsyncSession, request_params: RequestParams, filters: Any
    ) -> Tuple[List[ModelType], int]:
        query = select(self.model)
        query = await self.constr_query_filter(query, request_params, filters)
        result: Result = await db.execute(query)
        r = result.scalars().all()
        return r, len(r)

    async def create(self, db: AsyncSession, *, obj_in: CreateSchemaType) -> ModelType:
        # obj_in_data = jsonable_encoder(obj_in)
        db_obj = self.model(**obj_in.dict())
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
        obj_data: dict = db_obj.__dict__
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
