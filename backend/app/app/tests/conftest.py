import asyncio
from os import environ
from typing import AsyncGenerator

import pytest
import pytest_asyncio
from httpx import AsyncClient

from app.core.config import get_app_settings
from app.main import app
from app.tests.db.session import TestingSessionLocal

environ["APP_ENV"] = "test"


@pytest.fixture(scope="session")
def event_loop():
    return asyncio.get_event_loop()


@pytest_asyncio.fixture(scope="module")
async def client() -> AsyncGenerator:
    async with AsyncClient(
        app=app,
        base_url=f"http://{get_app_settings().DOMAIN}:{get_app_settings().PORT}",
    ) as c:
        yield c


@pytest_asyncio.fixture(scope="session")
async def db() -> AsyncGenerator:
    session = TestingSessionLocal()
    try:
        yield session
    finally:
        await session.close()
