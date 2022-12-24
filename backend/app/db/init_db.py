import logging
import pathlib

from asyncpg import DuplicateObjectError, Connection, UndefinedTableError, DuplicateTableError
from sqlalchemy import text
from sqlalchemy.exc import ProgrammingError
from sqlalchemy.ext.asyncio import AsyncConnection

from backend.app import crud, schemas
from backend.app.core.config import settings, ROOT_PATH
from backend.app.db import metadata, classifiers
from backend.app.db.session import engine, AsyncSessionFactory, asyncpg_database
from backend.app.main import logger

async def exec_sql_files(sql: pathlib.Path, asyncpg_conn: Connection):
    try:
        with open(sql, encoding='utf-8') as rf:
            res = await asyncpg_conn.execute(rf.read())
            logging.error(f'{sql.name}: {res}')
    except Exception as e:
        logging.error(f'{sql.name}: {e.args}')

async def create_all():
    async with engine.begin() as conn:
        conn: AsyncConnection
        try:
            metadata.bind = engine
            await conn.run_sync(metadata.create_all)
        except Exception as e:
            logging.exception(f'init_db: Base.metadata.create_all(): {e}')

async def init_db():
    db = AsyncSessionFactory()
    asyncpg_conn: Connection = await asyncpg_database.get_connection()
    sql_files = pathlib.Path(f"{ROOT_PATH}/db/sql/").iterdir()
    for sql in sql_files:
        if not sql.is_dir():
            if int(sql.name[0]) <= 3:
                await exec_sql_files(sql, asyncpg_conn)
            elif int(sql.name[0]) == 4:
                try:
                    await create_all()
                except ProgrammingError:
                    pass
                await exec_sql_files(sql, asyncpg_conn)
    try:
        user = await crud.user.get_by_email(db, email=settings.FIRST_SUPERUSER_EMAIL)
        if not user:
            user_in_admin = schemas.UserCreate(
                email=settings.FIRST_SUPERUSER_EMAIL,
                password=settings.FIRST_SUPERUSER_PASSWORD,
                is_superuser=True,
                full_name='i`m' + settings.FIRST_SUPERUSER_USERNAME,
                username=settings.FIRST_SUPERUSER_USERNAME,
                age=20,
                phone='+79998880001',
                role=classifiers.UserRole.admin.name
            )
            await crud.user.create(db, obj_in=user_in_admin)

    except Exception as e:
        logging.exception(f'create first superuser: {e.args}')
