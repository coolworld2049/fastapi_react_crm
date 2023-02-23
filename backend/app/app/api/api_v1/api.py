from app.api.api_v1.endpoints import (
    login,
    signup,
    classifiers,
    campuses,
    disciplines,
    study_group_ciphers,
    study_groups,
    students,
    teachers,
    tasks,
    study_group_tasks,
    student_tasks,
    student_task_stores,
)
from app.api.api_v1.endpoints import users
from app.api.api_v1.endpoints import utils
from fastapi import APIRouter

api_router = APIRouter()

api_router.include_router(login.router, tags=["login"])
api_router.include_router(signup.router, tags=["signup"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(utils.router, prefix="/utils", tags=["utils"])

api_router.include_router(
    classifiers.router, prefix="/classifiers", tags=["classifiers"]
)
api_router.include_router(campuses.router, prefix="/campuses", tags=["campuses"])
api_router.include_router(
    disciplines.router, prefix="/disciplines", tags=["disciplines"]
)
api_router.include_router(
    study_group_ciphers.router,
    prefix="/study_group_ciphers",
    tags=["study_group_ciphers"],
)
api_router.include_router(
    study_groups.router, prefix="/study_groups", tags=["study_groups"]
)
api_router.include_router(students.router, prefix="/students", tags=["students"])
api_router.include_router(teachers.router, prefix="/teachers", tags=["teachers"])
api_router.include_router(tasks.router, prefix="/tasks", tags=["tasks"])
api_router.include_router(
    study_group_tasks.router, prefix="/study_group_tasks", tags=["study_group_tasks"]
)
api_router.include_router(
    student_tasks.router, prefix="/student_tasks", tags=["student_tasks"]
)
api_router.include_router(
    student_task_stores.router,
    prefix="/student_task_stores",
    tags=["student_task_stores"],
)
