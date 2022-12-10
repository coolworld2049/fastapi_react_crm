from asyncpg_utils.databases import Database
from sqlalchemy.ext.asyncio import AsyncSession, AsyncEngine, engine
from sqlalchemy.orm import sessionmaker

from backend.app.core.config import settings

async_engine: AsyncEngine = engine.create_async_engine(
    settings.ASYNC_POSTGRES_URL
)

AsyncSessionLocal = sessionmaker(
    async_engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autocommit=False,
    autoflush=False
)

asyncpg_database = Database(settings.POSTGRES_URL)
