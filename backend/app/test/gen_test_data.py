import asyncio
import datetime
import json
import random
import string
import time

from asyncpg import Connection, UndefinedFunctionError
from faker import Faker
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncConnection, AsyncSession

from backend.app import crud, schemas
from backend.app.db import classifiers, models, metadata
from backend.app.db.init_db import init_db
from backend.app.db.session import asyncpg_database, AsyncSessionFactory, engine
from backend.app.main import logger

fake: Faker = Faker()


def gen_rand_password(number: int, rnd_str_length: int = 4):
    r_str = ''.join(random.choice(string.ascii_letters) for _ in range(rnd_str_length)).capitalize()
    return f"{''.join(random.choice(string.ascii_letters) for _ in range(rnd_str_length)).capitalize()}" \
           f"{r_str}{number}{number * 2}" \
           f"{''.join(random.choice(string.ascii_letters) for _ in range(rnd_str_length)).capitalize()}" \
           f"{random.choice(['!', '@', '#', '$', '&', '*'])}"

async def init_db_test():
    db: AsyncSession = AsyncSessionFactory()
    asyncpg_conn: Connection = await asyncpg_database.get_connection()
    try:
        users_count = 500  # 500 ~ 115 sec
        ration_teachers_to_students = users_count // 2
        campus_count = 10

        disciplines_list = [
            'Software Modeling',
            'C++',
            'Python',
            'C#',
            'Java',
            'Kotlin'
        ]
        study_group_list = [f"ABCD-{0 if x < 10 else ''}{x}-22" for x in range(1, 21)]

        q_truncate = f'''select truncate_tables('postgres')'''
        logger.info(q_truncate)
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
                logger.error(f'metadata.drop_all: {e.args}')
        await init_db()

        start = time.perf_counter()

        users: list[models.User] = []
        users_cred_list = []
        role = classifiers.UserRole.teacher.name
        for us in range(users_count):
            logger.info(f"UserCreate: {us}/{users_count}")
            us += 2
            if us >= ration_teachers_to_students:
                role = classifiers.UserRole.student.name

            user_in = schemas.UserCreate(
                email=f'{role}{us}@gmail.com',
                password=gen_rand_password(us),
                username=f'{role}{us}{random.randint(1000,10000)}',
                full_name=fake.name(),
                age=random.randint(18, 25),
                phone='+7' + ''.join(random.choice(string.digits) for _ in range(10)),
                role=role
            )
            users_cred_list.append({
                user_in.role: {
                    'email': user_in.email,
                    'password': user_in.password
                }
            })
            user_in_obj = await crud.user.create(db, obj_in=user_in)
            users.append(user_in_obj)

        with open(f"users_cred_list.json", 'w') as wr:
            wr.write(json.dumps(users_cred_list, indent=4))

        campuses: list[models.Campus] = []
        for c in range(campus_count):
            logger.info(f"CampusCreate: {c}/{campus_count}")
            campus_in = schemas.CampusCreate(
                id=''.join(random.choice(string.ascii_uppercase) for _ in range(2)) +
                   f"-{random.randint(1, campus_count)}",
                address=fake.address()
            )
            campuses.append(await crud.campus.create(db, obj_in=campus_in))

        disciplines: list[models.Discipline] = []
        for d in disciplines_list:
            logger.info(f"DisciplineCreate, TypedDisciplineCreate: {d}/{len(disciplines_list)}")
            discipline_in = schemas.DisciplineCreate(
                title=d
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

            for sg_dscp in disciplines[:random.randint(2, len(disciplines))]:
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
                user_student = await crud.student.get(db, id=us.id)
                student_in = schemas.StudentUpdate(
                    id=us.id,
                    study_group_cipher_id=sgc.id,
                    role=random.choice(classifiers.StudentRole.to_list())
                )
                students.append(await crud.student.update(db, db_obj=user_student, obj_in=student_in))

            elif str(us.role) == classifiers.UserRole.teacher.name:
                logger.info(f"TeacherCreate")
                teacher_in = schemas.TeacherCreate(
                    user_id=us.id,
                    role=random.choice(classifiers.TeacherRole.to_list()),
                    discipline_id=random.choice(disciplines).id,
                    room_number=f"{random.choice(string.ascii_letters)}-{random.randint(1, 400)}",
                    campus_id=random.choice(campuses).id
                )
                teacher_in_obj = await crud.teacher.create(db, obj_in=teacher_in)
                teachers_list.append(teacher_in_obj)

        tasks: list[models.Task] = []
        student_tasks: list[models.StudentTask] = []
        student_task_stores: list[models.StudentTaskStore] = []
        study_group_tasks: list[models.StudyGroupTask] = []

        for i, teacher in enumerate(teachers_list):
            logger.info(f"TaskCreate")
            task_in = schemas.TaskCreate(
                teacher_user_id=teacher.user_id,
                teacher_role=teacher.role,
                teacher_discipline_id=teacher.discipline_id,
                title=f'Task[{i+1}]. {fake.sentence()}',
                description=fake.sentence()
            )
            task_in_obj: models.Task = await crud.task.create(db, obj_in=task_in)
            tasks.append(task_in_obj)
        try:
            for ts in tasks[:len(tasks) // 2]:
                dt_now = datetime.datetime.now()
                student_task_in = schemas.StudentTaskCreate(
                    id=ts.id,
                    student_id=random.choice(students).id,
                    grade=random.choice(classifiers.StudentTaskGrade.to_list()),
                    status=classifiers.TaskStatus.started.name,
                    priority=random.choice(classifiers.TaskPriority.to_list()),
                    deadline_date=dt_now.replace(
                        day=dt_now.day + abs(dt_now.day - random.randint(dt_now.day + 1, 30)))
                )
                student_task_in_obj: models.StudentTask = await crud.student_task.create(db, obj_in=student_task_in)
                student_tasks.append(student_task_in_obj)

                student_task_store_in = schemas.StudentTaskStoreCreate(
                    task_id=ts.id,
                    student_id=random.choice(students).id,
                    url='https://cloud.com/' + ''.join(random.choice(string.ascii_letters) for _ in range(100)),
                    size=random.randint(100000, 100000000)
                )
                student_task_store_in_obj: models.StudentTaskStore = \
                    await crud.student_task_store.create(db, obj_in=student_task_store_in)
                student_task_stores.append(student_task_store_in_obj)

            for sgt in tasks[len(tasks) // 2:]:
                for sgc in study_group_ciphers[:random.randint(1, len(study_group_ciphers) // 2)]:
                    dt_now = datetime.datetime.now()
                    study_group_task_in = schemas.StudyGroupTaskCreate(
                        id=sgt.id,
                        study_group_cipher_id=sgc.id,
                        status=classifiers.TaskStatus.pending.name,
                        deadline_date=dt_now.replace(
                            day=dt_now.day + abs(dt_now.day - random.randint(dt_now.day + 1, 30)))
                    )
                    study_group_task_in_in_obj: models.StudyGroupTask = \
                        await crud.study_group_task.create(db, obj_in=study_group_task_in)
                    study_group_tasks.append(study_group_task_in_in_obj)
        except IntegrityError as e:
            logger.error(e.args)

        end = time.perf_counter()
        logger.info(f"gen process_time: {end - start:2}")
    except Exception as e:
        logger.exception(e.args)


if __name__ == '__main__':
    asyncio.run(init_db_test())
