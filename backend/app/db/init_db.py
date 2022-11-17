import logging
from datetime import datetime

from sqlalchemy.ext.asyncio import AsyncConnection
from sqlalchemy.orm import Session  # noqa

from backend.app import crud, schemas
from backend.app.core.config import settings
from backend.app.db import base  # noqa: F401
from backend.app.db.base_class import Base
from backend.app.db.session import async_engine, AsyncSessionLocal  # noqa
from backend.app.schemas import column_type

logger = logging.getLogger(__name__)


# make sure all SQL Alchemy models are imported (app.db.base) before initializing DB
# otherwise, SQL Alchemy might fail to initialize relationships properly
# for more details: https://github.com/tiangolo/full-stack-fastapi-postgresql/issues/28


# noinspection PyBroadException
async def init_db() -> None:
    # Tables should be created with Alembic migrations
    # But if you don't want to use migrations, create
    # the tables un-commenting the next line
    db = AsyncSessionLocal()
    async with async_engine.begin() as conn:
        try:
            conn: AsyncConnection
            Base.metadata.bind = async_engine
            await conn.run_sync(Base.metadata.create_all)
        except Exception as e:
            logger.error(f'init_db: Base.metadata.create_all(): {e}')

    try:
        user = await crud.user.get_by_email(db, email=settings.FIRST_SUPERUSER_USERNAME)
        if not user:
            user_in = schemas.UserCreate(
                email=settings.FIRST_SUPERUSER_USERNAME,
                password=settings.FIRST_SUPERUSER_PASSWORD,
                is_superuser=True,
                first_name='John',
                last_name='Doe',
                phone='+79998880001',
                role=column_type.userRole.admin,
                create_date=datetime.today()
            )
            user = await crud.user.create(db, obj_in=user_in)  # noqa: F841
    except Exception:
        logger.info('init_db: user is None')
