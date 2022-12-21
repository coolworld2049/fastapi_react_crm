import asyncio
import datetime
import random
import string
import time

from asyncpg import Connection, UndefinedFunctionError
from sqlalchemy.ext.asyncio import AsyncConnection

from backend.app import crud, schemas
from backend.app.db import classifiers, models, metadata
from backend.app.db.init_db import init_db
from backend.app.db.session import asyncpg_database, AsyncSessionFactory, engine
from backend.app.main import logger


async def init_db_test():
    db = AsyncSessionFactory()
    asyncpg_conn: Connection = await asyncpg_database.get_connection()
    try:
        users_count = 100 # 100 ~ 23 sec, 1000 ~ 230 sec
        ration_teachers_to_students = users_count // 2

        campus_list = ['B-78', 'В-86', 'C-20', 'П-1']
        disciplines_list = [
            'Программные средства манипулирования данными (часть 1/1) [I.22-23]',
            'Интерпретируемый язык программирования высокого уровня (часть 2/2) [I.22-23]',
            'Алгоритмы параллельных вычислений (часть 1/1) [I.22-23]',
            'Методы искусственного интеллекта (часть 1/1) [I.22-23]',
            'Моделирование систем (часть 1/1) [I.22-23]',
            'Программные средства решения прикладных задач искусственного интеллекта (ЦК)',
            'Средства моделирования разработки программного обеспечения (часть 1/1) [I.22-23]',
            'Философия (часть 1/1) [I.22-23]'
            'Матан',
            'Линал',
            'Дизайн',
            'C++',
            'Python',
            'C#'
        ]
        study_group_list = ['БСБО-04-20', 'БСБО-05-20', 'БСБО-06-20', 'БСБО-07-20', 'БСБО-08-20']
        username_parts = [
            'Coirdana'
            'Aralar',
            'Munris',
            'ＥＸＣＬＵＳＩＶ',
            '[NighT***FighteR]',
            '㋛☢▶▷Shooter◀◁☢㋛',
            'Yggrn',
            'Doomcliff',
            'Doule',
            'itzOzzi',
            '❶↔❶↔Жизньигра❶↔❶↔',
            '♥˙˙·٠●Благ☉βчувствﻉмере.●•٠·˙˙♥',
            'Andromaginn',
            'ЛисочкаКисочка'
        ]

        q_truncate = f'''SELECT truncate_tables('postgres');'''
        try:
            await asyncpg_conn.execute(q_truncate)
        except UndefinedFunctionError:
            await init_db()
            await asyncpg_conn.execute(q_truncate)
        async with engine.begin() as conn:
            conn: AsyncConnection
            try:
                metadata.bind = engine
                await conn.run_sync(metadata.drop_all, checkfirst=True)
            except Exception as e:
                logger.error(f'init_db: Base.metadata.drop_all: {e}')
        await init_db()
        logger.info(q_truncate)

        start = time.perf_counter()

        users: list[models.User] = []
        role = classifiers.UserRole.teacher.name
        for us in range(users_count):
            if us >= ration_teachers_to_students:
                role = classifiers.UserRole.student.name
            logger.info(f"UserCreate: {us}/{users_count}")
            user_in_student = schemas.UserCreate(
                email=f'{role}{us}@gmail.com',
                password=f'{role}{us}',
                username=f'{role}{us}_{random.choice(username_parts)}',
                full_name=f'i`m {role}{us}',
                age=random.randint(18, 25),
                phone='+7' + ''.join(random.choice(string.digits) for _ in range(10)),
                role=role,
            )
            user_in_student_obj = await crud.user.create(db, obj_in=user_in_student)
            users.append(user_in_student_obj)

        campuses: list[models.Campus] = []
        for c in campus_list:
            logger.info(f"CampusCreate: {c}/{len(campus_list)}")
            campus_in = schemas.CampusCreate(
                id=c,
                address='г.Москва'
            )
            campuses.append(await crud.campus.create(db, obj_in=campus_in))

        disciplines: list[models.Discipline] = []
        for d in disciplines_list:
            logger.info(f"DisciplineCreate, TypedDisciplineCreate: {d}/{len(disciplines_list)}")
            discipline_in = schemas.DisciplineCreate(
                title=d,
                assessment=random.choice(classifiers.TypeAssessment.to_list())
            )
            dscp: models.Discipline = await crud.discipline.create(db, obj_in=discipline_in)
            disciplines.append(dscp)

        study_group_ciphers: list[models.StudyGroupCipher] = []
        study_groups: list[models.StudyGroup] = []
        for sgc in study_group_list:
            logger.info(f"StudyGroupCipherCreate, StudyGroupCreate: {sgc}/{len(study_group_list)}")
            study_group_cipher_in = schemas.StudyGroupCipherCreate(
                id=sgc
            )
            study_group_cipher_in_obj: models.StudyGroupCipher = \
                await crud.study_group_cipher.create(db, obj_in=study_group_cipher_in)
            study_group_ciphers.append(study_group_cipher_in_obj)

            for sg_dscp in disciplines[:random.randint(3, len(disciplines))]:
                study_group_in = schemas.StudyGroupCreate(
                    id=study_group_cipher_in_obj.id,
                    discipline_id=sg_dscp.id
                )
                study_group_in_obj = await crud.study_group.create(db, obj_in=study_group_in)
                study_groups.append(study_group_in_obj)

        students: list[models.Student] = []
        teachers_list: list[models.Teacher] = []

        for us in users:
            if str(us.role) == classifiers.UserRole.student.name:
                logger.info(f"StudentCreate")
                sgc: models.StudyGroup = random.choice(study_group_ciphers)
                student_in = schemas.StudentCreate(
                    id=us.id,
                    study_group_cipher_id=sgc.id,
                    role=random.choice(classifiers.StudentRole.to_list())
                )
                students.append(await crud.student.create(db, obj_in=student_in))

            elif str(us.role) == classifiers.UserRole.teacher.name:
                logger.info(f"TeacherCreate")
                teacher_in = schemas.TeacherCreate(
                    user_id=us.id,
                    role=random.choice(classifiers.TeacherRole.to_list()),
                    discipline_id=random.choice(disciplines).id,
                    room_number=f"{random.choice(string.ascii_letters)}-{random.randint(1, 400)}",
                    campus_id=random.choice(campuses).id
                )
                teachers_list.append(await crud.teacher.create(db, obj_in=teacher_in))

        tasks: list[models.Task] = []
        student_tasks: list[models.StudentTask] = []
        student_task_stores: list[models.StudentTaskStore] = []
        study_group_tasks: list[models.StudyGroupTask] = []

        for teacher in teachers_list:
            logger.info(f"TaskCreate")
            task_in = schemas.TaskCreate(
                teacher_id=teacher.id,
                title=''.join(random.choice(string.ascii_letters) for _ in range(10)),
                description=''.join(random.choice(string.ascii_letters) for _ in range(300)),
                priority=random.choice(classifiers.TaskPriority.to_list())
            )
            task_in_obj: models.Task = await crud.task.create(db, obj_in=task_in)
            tasks.append(task_in_obj)

        for st in tasks[:len(tasks) // 2]:
            dt_now = datetime.datetime.now()
            student_task_in = schemas.StudentTaskCreate(
                id=st.id,
                student_id=random.choice(students).id,
                status=random.choice(classifiers.TaskStatus.to_list()),
                deadline_date=dt_now.replace(day=dt_now.day + abs(dt_now.day - random.randint(dt_now.day + 1, 30)))
            )
            student_task_in_obj: models.StudentTask = await crud.student_task.create(db, obj_in=student_task_in)
            student_tasks.append(student_task_in_obj)

            student_task_store_in = schemas.StudentTaskStoreCreate(
                task_id=st.id,
                student_id=random.choice(students).id,
                url='https://cloud.com/' + ''.join(random.choice(string.ascii_letters) for _ in range(100)),
                size=random.randint(100000, 100000000)
            )
            student_task_store_in_obj: models.StudentTaskStore = await crud.student_task_store.create(db, obj_in=student_task_store_in)
            student_task_stores.append(student_task_store_in_obj)

        for sgt in tasks[len(tasks) // 2:]:
            dt_now = datetime.datetime.now()
            study_group_task_in = schemas.StudyGroupTaskCreate(
                id=sgt.id,
                study_group_cipher_id=random.choice(study_group_ciphers).id,
                status=random.choice(classifiers.TaskStatus.to_list()),
                deadline_date=dt_now.replace(day=dt_now.day + abs(dt_now.day - random.randint(dt_now.day + 1, 30)))
            )
            study_group_task_in_in_obj: models.StudyGroupTask = await crud.study_group_task.create(db, obj_in=study_group_task_in)
            study_group_tasks.append(study_group_task_in_in_obj)

        end = time.perf_counter()
        logger.info(f"gen process_time: {end - start:2}")
    except Exception as e:
        logger.exception(e.args)


if __name__ == '__main__':
    asyncio.run(init_db_test())
