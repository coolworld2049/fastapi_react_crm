import logging

from asyncpg import DuplicateTableError, DuplicateObjectError
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncConnection
from backend.app import crud, schemas
from backend.app.core.config import settings, ROOT_PATH
from backend.app.db import models, metadata
from backend.app.db.session import async_engine, AsyncSessionLocal, asyncpg_database


async def init_db() -> None:
    db = AsyncSessionLocal()
    async with async_engine.begin() as conn:
        try:
            conn: AsyncConnection
            metadata.bind = async_engine
            await conn.execute(text('set timezone to "Europe/Moscow";'))
            await conn.run_sync(metadata.create_all)
        except Exception as e:
            logging.error(f'init_db: Base.metadata.create_all(): {e}')

    conn_2 = await asyncpg_database.get_connection()

    try:
        with open(f"{ROOT_PATH}/db/sql/automation.sql", encoding='utf-8') as file_1:
            await conn_2.execute(file_1.read())
    except DuplicateObjectError:
        pass

    try:
        with open(f"{ROOT_PATH}/db/sql/roles.sql", encoding='utf-8') as file_2:
            await conn_2.execute(file_2.read())
    except DuplicateObjectError:
        pass

    try:
        with open(f"{ROOT_PATH}/db/sql/privileges.sql", encoding='utf-8') as file_2:
            await conn_2.execute(file_2.read())
    except DuplicateTableError:
        pass

    await conn_2.close()

    try:
        user = await crud.user.get_by_email(db, email=settings.FIRST_SUPERUSER_EMAIL)
        if not user:
            user_in_admin = schemas.UserCreate(
                email=settings.FIRST_SUPERUSER_EMAIL,
                password=settings.FIRST_SUPERUSER_PASSWORD,
                is_superuser=True,
                full_name='i`m' + settings.FIRST_SUPERUSER_USERNAME,
                username=settings.FIRST_SUPERUSER_USERNAME,
                phone='+79998880001',
                role=models.user_role.enums[0]
            )
            await crud.user.create(db, obj_in=user_in_admin)

    except Exception as e:
        logging.exception(f'init_db: user is None: Exception: {e.args}')
