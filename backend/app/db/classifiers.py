import re
from enum import Enum


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
        return  {c.name: c.value for c in cls}

class UserRole(EnumBase):
    admin = 'admin'
    anon = 'anon'
    student = 'student'
    student_leader = 'student_leader'
    student_leader_assistant = 'student_leader_assistant'
    teacher = 'teacher'

class AssessmentType(EnumBase):
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
    coursewor  = 'coursework'
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

pg_custom_type_colnames = [
    UserRole.col_name(),
    AssessmentType.col_name(),
    DisciplineType.col_name(),
    TaskStatus.col_name(),
    TaskPriority.col_name(),
    StudentTaskGrade.col_name()
]
