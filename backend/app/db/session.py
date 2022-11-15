from sqlalchemy import create_engine
from sqlalchemy.engine import Engine
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, AsyncEngine
from sqlalchemy.orm import sessionmaker

from backend.app.core.config import settings

sync_engine: Engine = create_engine(settings.SYNC_DATABASE_URI, future=True)

async_engine: AsyncEngine = create_async_engine(settings.ASYNC_DATABASE_URL)

SessionLocal = sessionmaker(
    sync_engine,
    autocommit=False,
    autoflush=False
)

AsyncSessionLocal = sessionmaker(
    async_engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autocommit=False,
    autoflush=False,
)

