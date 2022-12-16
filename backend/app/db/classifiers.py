import re
from enum import Enum

from sqlalchemy.dialects import postgresql as ps

instances: dict = {}


class EnumBase(Enum):

    @classmethod
    def as_snake_case(cls):
        return re.sub(r'(?<!^)(?=[A-Z])', '_', str(cls.__name__)).lower()

    @classmethod
    def col_name(cls):
        return cls.as_snake_case().split('_')[-1]

    @classmethod
    def to_list(cls) -> list:
        return list(map(lambda c: c.value, cls))

    @classmethod
    def to_dict(cls) -> dict:
        return {cls.as_snake_case(): {c.name: c.value for c in cls}}


class UserRole(EnumBase):
    admin = 'admin'
    anon = 'anon'
    student = 'student'
    student_leader = 'student_leader'
    student_leader_assistant = 'student_leader_assistant'
    teacher = 'teacher'


class TypeAssessment(EnumBase):
    test = 'test'
    test_diff = 'test_diff'
    coursework = 'coursework'
    exam = 'exam'


class DisciplineType(EnumBase):
    lecture = 'lecture'
    practice = 'practice'
    laboratory = 'laboratory'
    project = 'project'
    consultation = 'consultation'
    test = 'test'
    test_diff = 'test_diff'
    coursewor = 'coursework'
    exam = 'exam'


class TaskStatus(EnumBase):
    unassigned = 'unassigned'
    pending = 'pending'
    started = 'started'
    verifying = 'verifying'
    accepted = 'accepted'
    overdue = 'overdue'
    completed = 'completed'


class TaskPriority(EnumBase):
    high = 'high'
    medium = 'medium'
    low = 'low'


class StudentTaskGrade(EnumBase):
    good = 'good'
    great = 'great'
    normal = 'normal'
    bad = 'bad'
    passed = 'passed'
    not_passed = 'not_passed'


user_role_student_subtypes = [
    UserRole.student.name,
    UserRole.student_leader.name,
    UserRole.student_leader_assistant.name
]

user_role_teacher_subtypes = [
    UserRole.teacher.name
]

pg_custom_type_colnames = [
    UserRole.col_name(),
    TypeAssessment.col_name(),
    DisciplineType.col_name(),
    TaskStatus.col_name(),
    TaskPriority.col_name(),
    StudentTaskGrade.col_name()
]

user_role = ps.ENUM(*UserRole.to_list(), name=UserRole.as_snake_case())
type_assessment = ps.ENUM(*TypeAssessment.to_list(), name=TypeAssessment.as_snake_case())
discipline_type = ps.ENUM(*DisciplineType.to_list(), name=DisciplineType.as_snake_case())
task_status = ps.ENUM(*TaskStatus.to_list(), name=TaskStatus.as_snake_case())
task_priority = ps.ENUM(*TaskPriority.to_list(), name=TaskPriority.as_snake_case())
student_task_grade = ps.ENUM(*StudentTaskGrade.to_list(), name=StudentTaskGrade.as_snake_case())

instances.update(UserRole.to_dict())
instances.update(TypeAssessment.to_dict())
instances.update(DisciplineType.to_dict())
instances.update(TaskStatus.to_dict())
instances.update(TaskPriority.to_dict())
instances.update(StudentTaskGrade.to_dict())
