import asyncio
import datetime
import random
import string
import time

from asyncpg import Connection
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
        multiplier = 100  # 500 ~ 86 sec
        users_target = multiplier // 2
        task_target = multiplier * 3
        campus_list = ['B-78', 'В-86', 'C-20', 'П-1']
        disciplines_list = [
            'Программные средства манипулирования данными (часть 1/1) [I.22-23]',
            'Интерпретируемый язык программирования высокого уровня (часть 2/2) [I.22-23]'
        ]
        study_group_list = ['БСБО-04-20', 'БСБО-05-20', 'БСБО-06-20', 'БСБО-07-20', 'БСБО-08-20']

        # await init_db()
        q_truncate = f'''SELECT truncate_tables('postgres');'''
        await asyncpg_conn.execute(q_truncate)
        async with engine.begin() as conn:
            conn: AsyncConnection
            try:
                metadata.bind = engine
                await conn.run_sync(metadata.drop_all, checkfirst=True)
            except Exception as e:
                logger.error(f'init_db: Base.metadata.drop_all: {e}')
        await init_db()
        start = time.perf_counter()
        logger.info(q_truncate)
        users: list[models.User] = []
        user_roles = [*classifiers.user_role_student_subtypes, *classifiers.user_role_teacher_subtypes]
        for us in range(0, users_target):
            logger.info(f"UserCreate, UserContactCreate: {us}/{users_target}")
            role = random.choice(user_roles)
            user_in_student = schemas.UserCreate(
                email=f'{role}{us}@gmail.com',
                password=f'{role}{us}',
                username=f'{role}{us}',
                age=random.randint(18, 25),
                role=role,
            )
            user_in_student_obj = await crud.user.create(db, obj_in=user_in_student)
            users.append(user_in_student_obj)

            user_contacts_in = schemas.UserContactCreate(
                id=user_in_student_obj.id,
                phone=f"+7" + ''.join(random.choice(string.digits) for _ in range(10)),
                telegram=f"https://t.me/{random.randint(222555666, 99988877766)}"
            )
            await crud.user_contact.create(db, obj_in=user_contacts_in)

        user_student_list = list(filter(lambda u: u.role in classifiers.user_role_student_subtypes, users))
        user_teacher_list = list(filter(lambda u: u.role in classifiers.user_role_teacher_subtypes, users))

        campuses: list[models.Campus] = []
        for c in campus_list:
            logger.info(f"CampusCreate: {c}/{len(campus_list)}")
            campus_in = schemas.CampusCreate(
                id=c,
                address='г.Москва'
            )
            campuses.append(await crud.campus.create(db, obj_in=campus_in))

        disciplines: list[models.Discipline] = []
        disciplines_typed: list[models.DisciplineTyped] = []

        for d in disciplines_list:
            logger.info(f"DisciplineCreate, DisciplineTypedCreate: {d}/{len(disciplines_list)}")
            discipline_in = schemas.DisciplineCreate(
                title=d,
                assessment_type=classifiers.TypeAssessment.exam.name
            )
            dscp: models.Discipline = await crud.discipline.create(db, obj_in=discipline_in)
            disciplines.append(dscp)
            for dt in classifiers.TypeDiscipline.to_list():
                discipline_typed_in = schemas.DisciplineTypedCreate(
                    discipline_id=dscp.id,
                    type=dt,
                    classroom_number=f'{random.choice(string.ascii_letters)} {random.randint(0, 400)}',
                    campus_id=random.choice(campuses).id,
                )
                disciplines_typed.append(await crud.discipline_typed.create(db, obj_in=discipline_typed_in))

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
            for sg_dscp in disciplines:
                study_group_in = schemas.StudyGroupCreate(
                    study_group_cipher_id=study_group_cipher_in_obj.id,
                    discipline_id=sg_dscp.id
                )
                study_group_in_obj = \
                    await crud.study_group.create(db, obj_in=study_group_in)
                study_groups.append(study_group_in_obj)

        students: list[models.Student] = []
        for us in user_student_list:
            logger.info(f"StudentCreate: {us.id}/{len(user_student_list)}")
            sg_cph: models.StudyGroupCipher = random.choice(study_group_ciphers)
            student_in = schemas.StudentCreate(
                id=us.id,
                study_group_cipher_id=sg_cph.id
            )
            students.append(await crud.student.create(db, obj_in=student_in))

        teachers: list[models.Teacher] = []
        for ut in user_teacher_list:
            logger.info(f"TeacherCreate: {ut.id}/{len(user_teacher_list)}")
            for _ in range(2):
                t_dscp: models.Discipline = random.choice(disciplines)
                teacher_in = schemas.TeacherCreate(
                    user_id=ut.id,
                    discipline_id=t_dscp.id
                )
                teachers.append(await crud.teacher.create(db, obj_in=teacher_in))

        tasks: list[models.Task] = []
        student_tasks: list[models.TaskStudent] = []
        for ts in range(task_target):
            logger.info(f"TaskCreate: {ts}/{task_target}")
            dt_now = datetime.datetime.now()
            dt_fut = dt_now.replace(day=dt_now.day + abs(dt_now.day - random.randint(dt_now.day + 1, 30)))

            rnd_sg: models.StudyGroup = random.choice(study_group_ciphers)
            rnd_st: models.Student = random.choice(students)

            rnd_arg: dict = random.choice([
                {'study_group_cipher_id': rnd_sg.id},
                {'student_id': rnd_st.id}
            ])
            task_in = schemas.TaskCreate(
                teacher_id=random.choice(teachers).id,
                **rnd_arg,
                title=''.join(random.choice(string.ascii_letters) for _ in range(10)),
                description=''.join(random.choice(string.ascii_letters) for _ in range(300)),
                status=classifiers.TaskStatus.started.name,
                priority=random.choice(classifiers.TaskPriority.to_list()),
                expiration_date=dt_fut
            )
            task_in_obj: models.Task = await crud.task.create(db, obj_in=task_in)
            tasks.append(task_in_obj)
            task: models.Task = await crud.task.get(db, id=task_in_obj.id)

            if rnd_arg.get('student_id'):
                logger.info(f"TaskStudentCreate: {ts}/{task_target}")
                student_task_in = schemas.TaskStudentCreate(
                    id=task_in_obj.id,
                    comment=''.join(random.choice(string.ascii_letters) for _ in range(50)),
                    deadline_date=task.expiration_date,
                )
                student_task_in_obj = await crud.task_student.create(db, obj_in=student_task_in)
                student_tasks.append(student_task_in_obj)
                student_task: models.TaskStudent = await crud.task_student.get(db, id=student_task_in_obj.id)

                if task_in.status == classifiers.TaskStatus.started.name:
                    logger.info(f"task_in.status: `started`")
                    student_task_in_upd_first = schemas.TaskStudentUpdate(
                        id=task_in_obj.id,
                        start_date=datetime.datetime.now()
                    )
                    await crud.task_student.update(db, db_obj=student_task,
                                                   obj_in=student_task_in_upd_first.dict(exclude_unset=True))

                    logger.info(f"task_in.status: `accepted`")
                    logger.info(f"TaskStoreCreate")

                    # ...status = accepted
                    task_store_in_started = schemas.TaskStoreCreate(
                        task_id=task_in_obj.id,
                        url=f'https://cloud.storage.com/files/{task_in_obj.id}/',
                        filename=f'report{task_in_obj.id}',
                        size=random.randint(1000, 1000000)
                    )
                    await crud.task_store.create(db, obj_in=task_store_in_started)

                    logger.info(f"verifying")
                    task_in_verifying = schemas.TaskUpdate(
                        id=task_in_obj.id,
                        status=classifiers.TaskStatus.verifying.name,
                    )
                    await crud.task.update(db, db_obj=task, obj_in=task_in_verifying.dict(exclude_unset=True))

                    logger.info(f"completed")
                    task_in_completed = schemas.TaskUpdate(
                        id=task_in_obj.id,
                        status=classifiers.TaskStatus.completed.name,
                    )
                    await crud.task.update(db, db_obj=task, obj_in=task_in_completed.dict(exclude_unset=True))

                    if student_task_in:
                        logger.info(f"TaskStudentUpdate")
                        student_task_in_upd_last = schemas.TaskStudentUpdate(
                            id=task_in_obj.id,
                            points=random.randint(0, 2),
                            grade=random.choice(classifiers.StudentTaskGrade.to_list()),
                            feedbak='good job dude/shawty',
                            completion_date=datetime.datetime.now()
                        )
                        await crud.task_student.update(db, db_obj=student_task,
                                                       obj_in=student_task_in_upd_last.dict(exclude_unset=True))

        end = time.perf_counter()
        logger.info(f"gen process_time: {end - start:2}")
    except Exception as e:
        logger.exception(e.args)


if __name__ == '__main__':
    asyncio.run(init_db_test())
