from sqlalchemy.ext.asyncio import AsyncSession

from backend.app.crud.base import CRUDBase
from backend.app.db.models import Task, TaskStudent, TaskStore
from backend.app.schemas import TaskCreate, TaskUpdate, TaskStudentCreate, TaskStudentUpdate, TaskStoreUpdate, \
    TaskStoreCreate


class CRUDTask(CRUDBase[Task, TaskCreate, TaskUpdate]):
    pass

task = CRUDTask(Task)

class CRUDTaskStudent(CRUDBase[TaskStudent, TaskStudentCreate, TaskStudentUpdate]):
    pass

task_student = CRUDTaskStudent(TaskStudent)


class CRUDTaskStore(CRUDBase[TaskStore, TaskStoreCreate, TaskStoreUpdate]):
    pass

task_store = CRUDTaskStore(TaskStore)
