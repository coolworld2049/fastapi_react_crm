import logging
import pathlib

from asyncpg import Connection
from sqlalchemy.ext.asyncio import AsyncConnection

from backend.app import crud, schemas
from backend.app.core.config import settings, ROOT_PATH
from backend.app.db import metadata, classifiers
from backend.app.db.session import engine, AsyncSessionFactory, asyncpg_database


async def exec_sql_file(path: pathlib.Path, conn: Connection):
    try:
        with open(path, encoding='utf-8') as rf:
            res = await conn.execute(rf.read())
            logging.info(f'{path.name}: {res}')
    except Exception as e:
        logging.error(f'{path.name}: {e.args}')

async def create_all():
    async with engine.begin() as conn:
        conn: AsyncConnection
        try:
            metadata.bind = engine
            await conn.run_sync(metadata.create_all)
        except Exception as e:
            logging.warning(e)

async def init_db():
    db = AsyncSessionFactory()
    await create_all()
    for sql_f in  list(pathlib.Path(f"{ROOT_PATH}/db/sql/").iterdir()):
        if not sql_f.is_dir():
            await exec_sql_file(sql_f, await asyncpg_database.get_connection())
    super_user = await crud.user.get_by_email(db, email=settings.FIRST_SUPERUSER_EMAIL)
    if not super_user:
        user_in_admin = schemas.UserCreate(
            email=settings.FIRST_SUPERUSER_EMAIL,
            password=settings.FIRST_SUPERUSER_PASSWORD,
            is_superuser=True,
            full_name='Super User',
            username=settings.FIRST_SUPERUSER_USERNAME,
            role=classifiers.UserRole.admin.name
        )
        await crud.user.create(db, obj_in=user_in_admin)
