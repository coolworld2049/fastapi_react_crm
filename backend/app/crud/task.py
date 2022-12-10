from typing import Dict

from asyncpg import Connection
from sqlalchemy.ext.asyncio import AsyncSession

from backend.app import schemas
from backend.app.core.config import ROOT_PATH
from backend.app.crud.base import CRUDBase
from backend.app.db.session import asyncpg_database
from backend.app.models import Task
from backend.app.schemas import TaskCreate, TaskUpdate


class CRUDTask(CRUDBase[Task, TaskCreate, TaskUpdate]):
    async def create(
            self, db: AsyncSession, *, obj_in: TaskCreate
    ) -> Task:
        create_data: dict = obj_in.dict()
        db_obj = self.model(**create_data)  # noqa
        db.add(db_obj)
        await db.commit()
        return db_obj

    # noinspection PyMethodMayBeStatic,PyUnusedLocal
    async def generate_report(
            self,
            report_in: schemas.ReportTaskCreate
    ) -> Dict[str, str]:
        filename = f'user_{report_in.user_id}_report-delta_{report_in.start_timestamp.date()}_{report_in.end_timestamp.date()}.{report_in.ext}'
        path_in = f'/tmp/{filename}'
        path_out = f'{ROOT_PATH}/volumes/postgres/tmp/{filename}'

        q_csv = f'''
         COPY (select * from generate_report_by_period_and_employee(
            '{report_in.start_timestamp}'::timestamp,
            '{report_in.end_timestamp}'::timestamp,
            {report_in.user_id}
            )) to '{path_in}' delimiter ',' csv header;
        '''
        q_json = f'''
        COPY (select array_to_json(array_agg(row_to_json(results))) from generate_report_by_period_and_employee(
            '{report_in.start_timestamp}'::timestamp,
            '{report_in.end_timestamp}'::timestamp,
            {report_in.user_id}
            ) as results) to '{path_in}' with (format text, header false );
        '''
        conn: Connection = await asyncpg_database.get_connection()
        if report_in.ext == 'csv':
            await conn.execute(q_csv)
        elif report_in.ext == 'json':
            await conn.execute(q_json)
        return {'path_in': path_in, 'path_out': path_out, 'filename': filename}


task = CRUDTask(Task)
