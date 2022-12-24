# coding: utf-8
import re

from sqlalchemy import BigInteger, Boolean, CheckConstraint, Column, DateTime, Enum, ForeignKey, SmallInteger, String, \
    Text, text, Sequence, ForeignKeyConstraint, select, func
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship, validates
from sqlalchemy_mixins import AllFeaturesMixin
from sqlalchemy_utils import create_view

from backend.app.db import classifiers, user_role, type_assessment, student_role, task_status

Base = declarative_base()
metadata = Base.metadata


class BaseDbModel(Base, AllFeaturesMixin):
    __abstract__ = True
    pass


class Campus(BaseDbModel):
    __tablename__ = 'campus'

    id = Column(String(255), primary_key=True)
    address = Column(Text)


class Discipline(BaseDbModel):
    __tablename__ = 'discipline'

    id = Column(BigInteger, primary_key=True)
    title = Column(Text, nullable=False)
    assessment = Column(type_assessment)

    study_group_cipher = relationship('StudyGroupCipher', secondary='study_group')


class StudyGroupCipher(BaseDbModel):
    __tablename__ = 'study_group_cipher'

    id = Column(String(30), primary_key=True)


class User(BaseDbModel):
    __tablename__ = 'user'
    __table_args__ = (
        CheckConstraint('full_name <> (role)::text'),
        CheckConstraint('username <> (role)::text'),
        CheckConstraint('is_reserved_username(username)')
    )

    id = Column(BigInteger, primary_key=True)
    email = Column(Text, nullable=False, unique=True)
    hashed_password = Column(Text)
    role = Column(user_role, nullable=False,
                  server_default=text("'anon'::user_role"))
    full_name = Column(Text)
    username = Column(Text, nullable=False, unique=True)
    age = Column(SmallInteger)
    phone = Column(String(20))
    avatar = Column(Text)
    is_active = Column(Boolean, nullable=False, server_default=text("true"))
    is_superuser = Column(Boolean, nullable=False, server_default=text("false"))
    create_date = Column(DateTime(True), server_default=text("LOCALTIMESTAMP"))


class Student(BaseDbModel):
    __tablename__ = 'student'

    id = Column(ForeignKey('user.id'), primary_key=True)
    role = Column(student_role)
    study_group_cipher_id = Column(String(30))


class StudyGroup(BaseDbModel):
    __tablename__ = 'study_group'

    id = Column(ForeignKey('study_group_cipher.id'), primary_key=True, nullable=False)
    discipline_id = Column(ForeignKey('discipline.id'), primary_key=True, nullable=False)


class Teacher(BaseDbModel):
    __tablename__ = 'teacher'

    id = Column(BigInteger, Sequence('teacher_id_seq'), nullable=False, unique=True)
    user_id = Column(ForeignKey('user.id'), primary_key=True)
    role = Column(Enum('lecturer', 'practicioner', name='teacher_role'), primary_key=True)
    discipline_id = Column(ForeignKey('discipline.id'), primary_key=True)
    room_number = Column(String(10))
    campus_id = Column(ForeignKey('campus.id'))

    campus = relationship('Campus')
    discipline = relationship('Discipline')
    user = relationship('User')


class Task(BaseDbModel):
    __tablename__ = 'task'
    __table_args__ = (
        ForeignKeyConstraint(('teacher_user_id', 'teacher_role', 'teacher_discipline_id'),
                             ['teacher.user_id', 'teacher.role', 'teacher.discipline_id']),
    )

    id = Column(BigInteger, Sequence('task_id_seq'), nullable=False, unique=True)
    teacher_user_id = Column(BigInteger, primary_key=True, nullable=False)
    teacher_role = Column(classifiers.teacher_role, primary_key=True, nullable=False)
    teacher_discipline_id = Column(BigInteger, primary_key=True, nullable=False)
    title = Column(Text, primary_key=True, nullable=False)
    description = Column(Text)
    create_date = Column(DateTime(True), server_default=text("LOCALTIMESTAMP"))

    teacher_user = relationship('Teacher')


class StudentTask(BaseDbModel):
    __tablename__ = 'student_task'
    __table_args__ = (
        CheckConstraint('completion_date <= deadline_date'),
    )

    id = Column(ForeignKey('task.id'), primary_key=True, nullable=False)
    student_id = Column(ForeignKey('student.id'), primary_key=True, nullable=False)
    status = Column(task_status, nullable=False, server_default=text("'pending'::task_status"))
    priority = Column(Enum('high', 'medium', 'low', name='task_priority'), nullable=False)
    points = Column(SmallInteger)
    comment = Column(Text)
    feedback = Column(Text)
    grade = Column(Enum('good', 'great', 'normal', 'bad', 'passed', 'not_passed', name='task_grade_type'))
    deadline_date = Column(DateTime(True))
    completion_date = Column(DateTime(True))

    task = relationship('Task')
    student = relationship('Student')


class StudentTaskStore(BaseDbModel):
    __tablename__ = 'student_task_store'
    __table_args__ = (
        CheckConstraint('size <= 160000000'),
    )

    id = Column(BigInteger, Sequence('student_task_store_id_seq'), nullable=False, unique=True)
    task_id = Column(ForeignKey('task.id'), primary_key=True, nullable=False)
    student_id = Column(ForeignKey('student.id'), primary_key=True, nullable=False)
    url = Column(Text, primary_key=True, nullable=False)
    size = Column(BigInteger, nullable=False)
    filename = Column(Text)
    create_date = Column(DateTime(True), server_default=text("LOCALTIMESTAMP"))

    student = relationship('Student')
    task = relationship('Task')


class StudyGroupTask(BaseDbModel):
    __tablename__ = 'study_group_task'

    id = Column(ForeignKey('task.id'), primary_key=True, nullable=False)
    study_group_cipher_id = Column(ForeignKey('study_group_cipher.id'), primary_key=True, nullable=False)
    status = Column(task_status,
        nullable=False, server_default=text("'accepted'::task_status"))
    deadline_date = Column(DateTime(True))

    task = relationship('Task')
    study_group_cipher = relationship('StudyGroupCipher')


teacher_lecturer_discipline_st = select(
    Teacher.user_id,
    func.array_agg(Teacher.discipline_id).label('discipline_id')
).select_from(Teacher)\
    .where(Teacher.role == classifiers.TeacherRole.lecturer.name)\
    .group_by(Teacher.user_id)

teacher_lecturer_discipline_view = create_view(
    'teacher_lecturer_discipline_view',
    teacher_lecturer_discipline_st,
    metadata
)

class TeacherLecturerDiscipline(BaseDbModel):
    __table__ = teacher_lecturer_discipline_view



teacher_practicioner_discipline_st = select(
    Teacher.user_id,
    func.array_agg(Teacher.discipline_id).label('discipline_id')
).select_from(Teacher)\
    .where(Teacher.role == classifiers.TeacherRole.practicioner.name)\
    .group_by(Teacher.user_id)

teacher_practicioner_discipline_view = create_view(
    'teacher_practicioner_discipline_view',
    teacher_practicioner_discipline_st,
    metadata
)

class TeacherPracticionerDiscipline(BaseDbModel):
    __table__ = teacher_practicioner_discipline_view
