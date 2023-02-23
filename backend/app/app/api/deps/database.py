from collections.abc import AsyncGenerator

from app.db.session import SessionLocal


async def get_db() -> AsyncGenerator:
    session = SessionLocal()
    try:
        yield session
    finally:
        await session.close()
