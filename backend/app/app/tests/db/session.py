from asyncpg_utils.databases import Database
from fastapi.encoders import jsonable_encoder
from sqlalchemy.ext.asyncio import AsyncEngine, create_async_engine
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import sessionmaker

from app.core.config import get_app_settings

test_db = get_app_settings().get_test_postgres_asyncpg_dsn

test_engine: AsyncEngine = create_async_engine(
    test_db,
    future=True,
    echo=False,
    json_serializer=jsonable_encoder,
)


TestingSessionLocal = sessionmaker(
    test_engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autocommit=False,
    autoflush=False,
)

test_pg_database = Database(test_db.replace(f"+{get_app_settings().PG_DRIVER}", ""))
