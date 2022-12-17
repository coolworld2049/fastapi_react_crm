from typing import AsyncGenerator

from asyncpg_utils.databases import Database
from fastapi import HTTPException
from fastapi.encoders import jsonable_encoder
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.ext.asyncio import AsyncSession, AsyncEngine, engine
from sqlalchemy.orm import sessionmaker

from backend.app.core.config import settings

engine: AsyncEngine = engine.create_async_engine(
    settings.ASYNC_POSTGRES_URL,
    future=True,
    echo=False,
    json_serializer=jsonable_encoder,
)

AsyncSessionFactory = sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autocommit=False,
    autoflush=False
)


asyncpg_database = Database(settings.POSTGRES_URL)


async def get_async_db() -> AsyncGenerator:
    session: AsyncSession = AsyncSessionFactory()  # noqa
    try:
        yield session
    except SQLAlchemyError as sql_ex:
        await session.rollback()
        raise sql_ex
    except HTTPException as http_ex:
        await session.rollback()
        raise http_ex
    else:
        await session.commit()
    finally:
        await session.close()
