from asyncpg_utils.databases import Database
from sqlalchemy.ext.asyncio import AsyncSession, AsyncEngine, engine
from sqlalchemy.orm import sessionmaker

from backend.app.core.config import settings

async_engine: AsyncEngine = engine.create_async_engine(
    settings.ASYNC_DATABASE_URL
)

AsyncSessionLocal = sessionmaker(
    async_engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autocommit=False,
    autoflush=False,
)

database = Database(settings.DATABASE_URL)
