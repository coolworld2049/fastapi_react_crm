from backend.app.crud import CRUDBase
from backend.app.db import Teacher
from backend.app.schemas import TeacherCreate, TeacherUpdate


class CRUDTeacher(CRUDBase[Teacher, TeacherCreate, TeacherUpdate]):
    pass


teacher = CRUDTeacher(Teacher)
