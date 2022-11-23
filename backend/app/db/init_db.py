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
            user_in_admin = schemas.UserCreate(
                email=settings.FIRST_SUPERUSER_USERNAME,
                password=settings.FIRST_SUPERUSER_PASSWORD,
                is_superuser=True,
                first_name='I',
                last_name='Am',
                phone='+79998880001',
                role=column_type.userRole.admin,
                create_date=datetime.today()
            )
            user_in_manager = schemas.UserCreate(
                email='alex@gmail.com',
                password='alex',
                first_name='alex',
                phone='+79998880002',
                role=column_type.userRole.manager,
                create_date=datetime.today()
            )
            user_in_ranker = schemas.UserCreate(
                email='mia@gmail.com',
                password='mia',
                first_name='mia',
                phone='+79998880003',
                role=column_type.userRole.ranker,
                create_date=datetime.today()
            )
            user_in_client = schemas.UserCreate(
                email='liam@gmail.com',
                password='liam',
                first_name='liam',
                phone='+79998880004',
                role=column_type.userRole.client,
                create_date=datetime.today()
            )
            for user in [user_in_admin, user_in_manager, user_in_ranker, user_in_client]:
                await crud.user.create(db, obj_in=user)
    except Exception:
        logger.info('init_db: user is None')
