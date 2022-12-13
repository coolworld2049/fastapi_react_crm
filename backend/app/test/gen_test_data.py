import asyncio
import logging
import time

from asyncpg import DuplicateTableError, DuplicateObjectError
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncConnection

from backend.app.core.config import ROOT_PATH
from backend.app.db import Base
from backend.app.db.session import async_engine, AsyncSessionLocal, asyncpg_database


async def init_db_test() -> None:
    db = AsyncSessionLocal()
    async with async_engine.begin() as conn:
        try:
            conn: AsyncConnection
            Base.metadata.bind = async_engine
            await conn.execute(text('set timezone to "Europe/Moscow";'))
            await conn.run_sync(Base.metadata.create_all)
        except Exception as e:
            logging.error(f'init_db: Base.metadata.create_all(): {e}')

    conn_2 = await asyncpg_database.get_connection()
    try:
        with open(f"{ROOT_PATH}/db/sql/privileges.sql", encoding='utf-8') as file_2:
            await conn_2.execute(file_2.read())
    except DuplicateObjectError:
        logging.error('DuplicateObjectError')
    try:
        with open(f"{ROOT_PATH}/db/sql/automation.sql", encoding='utf-8') as file_1:
            await conn_2.execute(file_1.read())
    except DuplicateTableError:
        logging.error('DuplicateTableError')
    await conn_2.close()

    try:
        q_truncate = f'''SELECT truncate_tables('postgres');'''
        await db.execute(q_truncate)
        st = time.process_time()
        logging.info(q_truncate)
        ...
        end = time.process_time()
        logging.info(f"gen process_time: {end - st}")
    except Exception as e:
        logging.exception(f'init_db_test: user is None: Exception: {e.args}')


if __name__ == '__main__':
    asyncio.run(init_db_test())
