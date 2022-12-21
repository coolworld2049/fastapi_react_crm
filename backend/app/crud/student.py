from backend.app.crud import CRUDBase
from backend.app.db import Student
from backend.app.schemas import StudentCreate, StudentUpdate


class CRUDStudent(CRUDBase[Student, StudentCreate, StudentUpdate]):
    pass


student = CRUDStudent(Student)
