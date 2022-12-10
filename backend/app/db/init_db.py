from asyncpg import DuplicateTableError, DuplicateObjectError
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncConnection

from backend.app import crud, schemas
from backend.app.core.config import settings, ROOT_PATH
from backend.app.db import base  # noqa: F401
from backend.app.db.base_class import Base
from backend.app.db.session import async_engine, AsyncSessionLocal, asyncpg_database
from backend.app.main import logger
from backend.app.schemas import column_type


async def init_db() -> None:
    db = AsyncSessionLocal()
    async with async_engine.begin() as conn:
        try:
            conn: AsyncConnection
            Base.metadata.bind = async_engine
            await conn.execute(text('set timezone to "Europe/Moscow";'))
            await conn.run_sync(Base.metadata.create_all)
        except Exception as e:
            logger.error(f'init_db: Base.metadata.create_all(): {e}')

    conn_2 = await asyncpg_database.get_connection()
    try:
        with open(f"{ROOT_PATH}/db/sql/privileges.sql", encoding='utf-8') as file_2:
            await conn_2.execute(file_2.read())
    except DuplicateObjectError:
        logger.error('DuplicateObjectError')
    try:
        with open(f"{ROOT_PATH}/db/sql/automation.sql", encoding='utf-8') as file_1:
            await conn_2.execute(file_1.read())
    except DuplicateTableError:
        logger.error('DuplicateTableError')
    await conn_2.close()

    try:
        user = await crud.user.get_by_email(db, email=settings.FIRST_SUPERUSER_USERNAME)
        if not user:
            company_in_main = schemas.CompanyCreate(
                name='CRM',
                size=column_type.companySize.medium,
                city='Москва',
                address='site',
                website='https://localhost:300/'
            )
            company_obj_main = await crud.company.create(db, obj_in=company_in_main)

            user_in_admin = schemas.UserCreate(
                email=settings.FIRST_SUPERUSER_USERNAME + '@gmail.com',
                password=settings.FIRST_SUPERUSER_PASSWORD,
                is_superuser=True,
                full_name=settings.FIRST_SUPERUSER_USERNAME + ' root',
                username=settings.FIRST_SUPERUSER_USERNAME,
                phone='+79998880001',
                role=column_type.userRole.admin_base,
                company_id=company_obj_main.id
            )
            await crud.user.create(db, user_in_admin)

    except Exception as e:
        logger.exception(f'init_db: user is None: Exception: {e.args}')
