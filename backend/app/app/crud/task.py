from app.crud.base import CRUDBase
from app.models.domain import Task, StudentTask, StudentTaskStore
from app.schemas import (
    TaskCreate,
    TaskUpdate,
    StudentTaskCreate,
    StudentTaskUpdate,
    StudentTaskStoreCreate,
    StudentTaskStoreUpdate,
)


class CRUDTask(CRUDBase[Task, TaskCreate, TaskUpdate]):
    pass


task = CRUDTask(Task)


class CRUDStudentTask(CRUDBase[StudentTask, StudentTaskCreate, StudentTaskUpdate]):
    pass


student_task = CRUDStudentTask(StudentTask)


class CRUDStudentTaskStore(
    CRUDBase[StudentTaskStore, StudentTaskStoreCreate, StudentTaskStoreUpdate]
):
    pass


student_task_store = CRUDStudentTaskStore(StudentTaskStore)
