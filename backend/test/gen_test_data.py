import asyncio
import random
import string
import time
from contextlib import suppress
from datetime import datetime, timezone

from asyncpg import DuplicateTableError, DuplicateObjectError, Connection
from sqlalchemy.ext.asyncio import AsyncConnection

from backend.app import crud, schemas, models
from backend.app.core.config import settings, ROOT_PATH
from backend.app.db import base  # noqa: F401
from backend.app.db.base_class import Base
from backend.app.db.session import async_engine, AsyncSessionLocal, asyncpg_database  # noqa
from backend.app.main import logger
from backend.app.schemas import column_type


async def init_db_test() -> None:
    conn_2: Connection = await asyncpg_database.get_connection()
    res = await conn_2.fetch('''show timezone;''')
    await conn_2.execute('''set timezone to "Europe/Moscow";''')
    logger.info(res)
    async with async_engine.begin() as conn:
        try:
            conn: AsyncConnection
            Base.metadata.bind = async_engine
            await conn.run_sync(Base.metadata.create_all)
        except Exception as e:
            logger.error(f'init_db: Base.metadata.create_all(): {e}')

    try:
        with open(f"{ROOT_PATH}/db/sql/privileges.sql", encoding='utf-8') as file_2:
            await conn_2.execute(file_2.read())
        with open(f"{ROOT_PATH}/db/sql/automation.sql", encoding='utf-8') as file_1:
            await conn_2.execute(file_1.read())
    except DuplicateObjectError:
        logger.info('DuplicateObjectError')
    except DuplicateTableError:
        logger.info('DuplicateTableError')
    await conn_2.close()

    try:
        db = AsyncSessionLocal()
        await db.execute(f'''SELECT truncate_tables('postgres');''')
        await db.execute('''set timezone to "Europe/Moscow";''')

        with suppress(DuplicateObjectError):
            logger.info(f'''SELECT truncate_tables('postgres');''')
            company_in = schemas.CompanyCreate(
                name="CRM",
                size=random.choice(column_type.companySize.schema().get('required')),
                city='Москва',
                address="Москва, чистые пруды 1",
                website='https://localhost:8080'
            )
            company_obj_main = await crud.company.create(db, obj_in=company_in)

            user_in_admin = schemas.UserCreate(
                email=settings.FIRST_SUPERUSER_USERNAME,
                password=settings.FIRST_SUPERUSER_PASSWORD,
                is_superuser=True,
                full_name=''.join(random.choice(string.ascii_letters) for _ in range(5)),
                username="admin555",
                phone=f"+7" + ''.join(random.choice(string.digits) for _ in range(10)),
                role=column_type.userRole.admin_base,
                company_id=company_obj_main.id
            )
            user_in_manager = schemas.UserCreate(
                email="manager@gmail.com",
                password="manager",
                is_superuser=False,
                full_name=''.join(random.choice(string.ascii_letters) for _ in range(5)),
                username="manager666",
                phone=f"+7" + ''.join(random.choice(string.digits) for _ in range(10)),
                role=column_type.userRole.manager_base,
                company_id=company_obj_main.id
            )
            user_in_ranker = schemas.UserCreate(
                email="ranker@gmail.com",
                password="ranker",
                is_superuser=False,
                full_name=''.join(random.choice(string.ascii_letters) for _ in range(5)),
                username="ranker777",
                phone=f"+7" + ''.join(random.choice(string.digits) for _ in range(10)),
                role=column_type.userRole.ranker_base,
                company_id=company_obj_main.id
            )
            await crud.user.create(db, obj_in=user_in_admin)
            await crud.user.create(db, obj_in=user_in_manager)
            await crud.user.create(db, obj_in=user_in_ranker)

        count = 100
        st = time.process_time()
        for _ in range(count):
            logger.info(f"gen: {_}/{count}")
            companies: list[models.Company] = []
            for c in range(3):
                company_in = schemas.CompanyCreate(
                    name=''.join(random.choice(string.ascii_letters) for _ in range(5)),
                    size=random.choice(column_type.companySize.schema().get('required')),
                    city=''.join(random.choice(string.ascii_letters) for _ in range(5)),
                    address=''.join(random.choice(string.ascii_letters) for _ in range(5)),
                    website='https://' + ''.join(random.choice(string.ascii_letters) for _ in range(5)) + '.com',
                )
                companies.append(await crud.company.create(db, obj_in=company_in))

            for u in range(3):
                user_in_manager = schemas.UserCreate(
                    email=''.join(random.choice(string.ascii_letters) for _ in range(5)) + "@gmail.com",
                    password=''.join(random.choice(string.ascii_letters) for _ in range(10)),
                    full_name=''.join(random.choice(string.ascii_letters) for _ in range(5)),
                    username=f"{column_type.userRole.manager_base}_" + ''.join(
                        random.choice(string.ascii_letters) for _ in range(5)),
                    phone=f"+7" + ''.join(random.choice(string.digits) for _ in range(10)),
                    role=column_type.userRole.manager_base,
                    company_id=company_obj_main.id,
                )
                user_in_ranker = schemas.UserCreate(
                    email=''.join(random.choice(string.ascii_letters) for _ in range(5)) + "@gmail.com",
                    password=''.join(random.choice(string.ascii_letters) for _ in range(10)),
                    full_name=''.join(random.choice(string.ascii_letters) for _ in range(5)),
                    username=f"{column_type.userRole.ranker_base}_" + ''.join(
                        random.choice(string.ascii_letters) for _ in range(5)),
                    phone=f"+7" + ''.join(random.choice(string.digits) for _ in range(10)),
                    role=column_type.userRole.ranker_base,
                    company_id=company_obj_main.id,
                )
                rnd_company: models.Company = random.choice(companies)
                user_in_client = schemas.UserCreate(
                    email=''.join(random.choice(string.ascii_letters) for _ in range(5)) + "@gmail.com",
                    password=''.join(random.choice(string.ascii_letters) for _ in range(10)),
                    full_name=''.join(random.choice(string.ascii_letters) for _ in range(5)),
                    username=f"{column_type.userRole.client_base}_" + ''.join(
                        random.choice(string.ascii_letters) for _ in range(5)),
                    phone=f"+7" + ''.join(random.choice(string.digits) for _ in range(10)),
                    role=column_type.userRole.client_base,
                    company_id=rnd_company.id,
                    type=random.choice(column_type.clientType.schema().get('required')),
                )
                companies.remove(rnd_company)

                user_obj_manager = await crud.user.create(db, obj_in=user_in_manager)
                user_obj_ranker = await crud.user.create(db, obj_in=user_in_ranker)
                user_obj_client = await crud.user.create(db, obj_in=user_in_client)

                for t in range(3):
                    deadline_date = datetime.now(timezone.utc).replace(
                        day=datetime.now(timezone.utc).day + random.randint(3, 14)
                    )
                    task_in = schemas.TaskCreate(
                        client_id=user_obj_client.id,
                        author_id=user_obj_manager.id,
                        executor_id=user_obj_ranker.id,
                        name=f'do ' + ''.join(random.choice(string.ascii_letters) for _ in range(20)),
                        description=''.join(random.choice(string.ascii_letters) for _ in range(500)),
                        priority=random.choice(column_type.taskPriority.schema().get('required')),
                        status=random.choice(column_type.taskStatus.schema().get('required')),
                        deadline_date=deadline_date
                    )
                    await crud.task.create(db, obj_in=task_in)
        end = time.process_time()
        logger.info(f"gen process_time: {end - st}")
    except Exception as e:
        logger.exception(f'init_db_test: user is None: Exception: {e.args}')


if __name__ == '__main__':
    asyncio.run(init_db_test())
