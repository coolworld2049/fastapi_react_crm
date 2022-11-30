from datetime import datetime

from asyncpg import DuplicateTableError
from asyncpg_utils.databases import Database
from sqlalchemy.ext.asyncio import AsyncConnection

from backend.app import crud, schemas
from backend.app.core.config import settings, ROOT
from backend.app.db import base  # noqa: F401
from backend.app.db.base_class import Base
from backend.app.db.session import async_engine, AsyncSessionLocal  # noqa
from backend.app.main import logger
from backend.app.schemas import column_type


async def init_db() -> None:
    async with async_engine.begin() as conn:
        try:
            conn: AsyncConnection
            Base.metadata.bind = async_engine
            await conn.run_sync(Base.metadata.create_all)
        except Exception as e:
            logger.error(f'init_db: Base.metadata.create_all(): {e}')

    try:
        database = Database(settings.DATABASE_URL)
        conn_2 = await database.get_connection()
        with open(f"{ROOT}/db/sql/automation.sql", encoding='utf-8') as file_1:
            await conn_2.execute(file_1.read())
        with open(f"{ROOT}/db/sql/polices.sql", encoding='utf-8') as file_2:
            await conn_2.execute(file_2.read())
        await conn_2.close()
    except DuplicateTableError:
        pass

    try:
        db = AsyncSessionLocal()
        user = await crud.user.get_by_email(db, email=settings.FIRST_SUPERUSER_USERNAME)
        if not user:
            user_in_admin = schemas.UserCreate(
                email=settings.FIRST_SUPERUSER_USERNAME,
                password=settings.FIRST_SUPERUSER_PASSWORD,
                is_superuser=True,
                full_name='I Am',
                phone='+79998880001',
                role=column_type.userRole.admin,
                create_date=datetime.strptime(datetime.now(tz=None).__str__(), '%Y-%m-%d %H:%M:%S.%f')
            )
            user_in_manager = schemas.UserCreate(
                email='alex@gmail.com',
                password='alex',
                full_name='alex',
                phone='+79998880002',
                role=column_type.userRole.manager,
                create_date=datetime.strptime(datetime.now(tz=None).__str__(), '%Y-%m-%d %H:%M:%S.%f')
            )
            user_in_ranker = schemas.UserCreate(
                email='mia@gmail.com',
                password='mia',
                full_name='mia',
                phone='+79998880003',
                role=column_type.userRole.ranker,
                create_date=datetime.strptime(datetime.now(tz=None).__str__(), '%Y-%m-%d %H:%M:%S.%f')
            )
            user_in_client_1 = schemas.UserCreate(
                email='sam@gmail.com',
                password='sam',
                full_name='sam',
                phone='+79998880005',
                role=column_type.userRole.client,
                create_date=datetime.strptime(datetime.now(tz=None).__str__(), '%Y-%m-%d %H:%M:%S.%f')
            )
            user_in_client_2 = schemas.UserCreate(
                email='karen@gmail.com',
                password='karen',
                full_name='karen',
                phone='+79998880006',
                role=column_type.userRole.client,
                create_date=datetime.strptime(datetime.now(tz=None).__str__(), '%Y-%m-%d %H:%M:%S.%f')
            )

            user_obj_admin = await crud.user.create(db, obj_in=user_in_admin) # noqa
            user_obj_manager = await crud.user.create(db, obj_in=user_in_manager)
            user_obj_ranker = await crud.user.create(db, obj_in=user_in_ranker)
            user_obj_client_1 = await crud.user.create(db, obj_in=user_in_client_1)
            user_obj_client_2 = await crud.user.create(db, obj_in=user_in_client_2)

            company_in_1 = schemas.CompanyCreate(
                name='Group IB',
                size=column_type.companySize.medium,
                address='Шарикоподшипниковская ул., 1, Москва, 115080',
                website='https://www.group-ib.ru/',
                create_date=datetime.strptime(datetime.now(tz=None).__str__(), '%Y-%m-%d %H:%M:%S.%f')
            )
            company_in_2 = schemas.CompanyCreate(
                name='Selectel',
                size=column_type.companySize.big,
                address='ул. Берзарина, д. 36, стр. 3, Москва, 123060',
                website='https://selectel.ru/',
                create_date=datetime.strptime(datetime.now(tz=None).__str__(), '%Y-%m-%d %H:%M:%S.%f')
            )
            company_obj_1 = await crud.company.create(db, obj_in=company_in_1)
            company_obj_2 = await crud.company.create(db, obj_in=company_in_2)

            client_in_1 = schemas.ClientCreate(
                id=user_obj_client_1.id,
                company_id=company_obj_1.id,
                type=schemas.clientType.current
            )
            client_in_2 = schemas.ClientCreate(
                id=user_obj_client_2.id,
                company_id=company_obj_2.id,
                type=schemas.clientType.potential
            )
            await crud.client.create(db, obj_in=client_in_1)
            await crud.client.create(db, obj_in=client_in_2)

            task_in_1 = schemas.TaskCreate(
                client_id=user_obj_client_1.id,
                author_id=user_obj_manager.id,
                executor_id=user_obj_ranker.id,
                name='test task',
                description='do',
                priority=column_type.taskPriority.medium,
                create_date=datetime.strptime(datetime.now(tz=None).__str__(), '%Y-%m-%d %H:%M:%S.%f'),
                deadline_date=None,
                completion_date=None
            )
            task_in_2 = schemas.TaskCreate(
                client_id=user_obj_client_2.id,
                author_id=user_obj_manager.id,
                executor_id=user_obj_manager.id,
                name='test task 2',
                description='do 2',
                priority=column_type.taskPriority.high,
                create_date=datetime.strptime(datetime.now(tz=None).__str__(), '%Y-%m-%d %H:%M:%S.%f'),
                deadline_date=None,
                completion_date=None
            )
            task_in_3 = schemas.TaskCreate(
                client_id=user_obj_client_2.id,
                author_id=user_obj_manager.id,
                executor_id=user_obj_ranker.id,
                name='test task 3',
                description='do 3',
                priority=column_type.taskPriority.high,
                create_date=datetime.strptime(datetime.now(tz=None).__str__(), '%Y-%m-%d %H:%M:%S.%f'),
                deadline_date=datetime.strptime('2022-12-25 08:00:00.000000', '%Y-%m-%d %H:%M:%S.%f'),
                completion_date=None
            )
            await crud.task.create(db, obj_in=task_in_1)
            await crud.task.create(db, obj_in=task_in_2)
            await crud.task.create(db, obj_in=task_in_3)

    except Exception as e:
        logger.exception(f'init_db: user is None: Exception: {e.args}')
