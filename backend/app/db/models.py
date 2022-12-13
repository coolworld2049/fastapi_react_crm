# coding: utf-8
import sqlalchemy.dialects.postgresql as ps
from sqlalchemy import BigInteger, Boolean, CheckConstraint, Column, DateTime, Enum, ForeignKey, SmallInteger, String, \
    Text, text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship

Base = declarative_base()
metadata = Base.metadata

user_role = ps.ENUM('admin', 'anon', 'student', 'student_leader', 'student_leader_assistant', 'teacher', name='user_role')
assessment_type = ps.ENUM('pass', 'pass_diff', 'coursework', 'exam', name='assessment_type')
discipline_type = ps.ENUM('lecture', 'practice', 'laboratory', 'coursework', 'pass', 'pass_diff', 'consultation', 'exam', 'project', name='discipline_type')
task_status = ps.ENUM('unassigned', 'pending', 'started', 'verifying', 'accepted', 'overdue', 'completed', name='task_status')
task_priority = ps.ENUM('high', 'medium', 'low', name='task_priority')
student_task_grade = Enum('good', 'great', 'normal', 'bad', 'passed', 'not_passed', name='student_task_grade')

class Campus(Base):
    __tablename__ = 'campus'

    id = Column(Text, primary_key=True)
    address = Column(Text)


class Discipline(Base):
    __tablename__ = 'discipline'

    id = Column(BigInteger, primary_key=True)
    title = Column(Text, nullable=False)
    assessment_type = Column(assessment_type)


class StudyGroupBase(Base):
    __tablename__ = 'study_group_base'

    id = Column(BigInteger, primary_key=True)
    cipher = Column(String(30))


class User(Base):
    __tablename__ = 'user'
    __table_args__ = (
        CheckConstraint('full_name <> (role)::text'),
        CheckConstraint('username <> (role)::text')
    )

    id = Column(BigInteger, primary_key=True)
    email = Column(Text, nullable=False, unique=True)
    hashed_password = Column(Text)
    role = Column(user_role, nullable=False, server_default=text("'anon'::user_role"))
    full_name = Column(Text)
    username = Column(Text, nullable=False, unique=True)
    age = Column(SmallInteger)
    avatar = Column(Text)
    is_active = Column(Boolean, nullable=False, server_default=text("true"))
    is_superuser = Column(Boolean, nullable=False, server_default=text("false"))
    create_date = Column(DateTime(True), server_default=text("LOCALTIMESTAMP"))

    study_group_bases = relationship('StudyGroupBase', secondary='student')


class UserContact(User):
    __tablename__ = 'user_contact'

    id = Column(ForeignKey('user.id'), primary_key=True)
    phone = Column(String(20), nullable=False)
    vk = Column(Text)
    telegram = Column(Text)
    discord = Column(Text)


class DisciplineTyped(Base):
    __tablename__ = 'discipline_typed'

    id = Column(BigInteger, primary_key=True)
    discipline_id = Column(ForeignKey('discipline.id'), nullable=False)
    type = Column(discipline_type, nullable=False)
    classroom_number = Column(Text, nullable=False)
    campus_id = Column(ForeignKey('campus.id'), nullable=False)
    create_date = Column(DateTime(True), server_default=text("LOCALTIMESTAMP"))

    campus = relationship('Campus')
    discipline = relationship('Discipline')


class Student(Base):
    __tablename__ = 'student'

    id = Column(ForeignKey('user.id'), primary_key=True)
    study_group_base_id = Column(ForeignKey('study_group_base.id'), nullable=False)


class StudyGroup(Base):
    __tablename__ = 'study_group'

    id = Column(BigInteger, primary_key=True)
    study_group_base_id = Column(ForeignKey('study_group_base.id'), nullable=False)
    discipline_id = Column(ForeignKey('discipline.id'), nullable=False)

    discipline = relationship('Discipline')
    study_group_base = relationship('StudyGroupBase')


class Teacher(Base):
    __tablename__ = 'teacher'

    id = Column(BigInteger, primary_key=True)
    discipline_id = Column(ForeignKey('discipline.id'), nullable=False)
    user_id = Column(ForeignKey('user.id'), nullable=False)

    discipline = relationship('Discipline')
    user = relationship('User')


class Task(Base):
    __tablename__ = 'task'
    __table_args__ = (
        CheckConstraint('expiration_date >= create_date'),
    )

    id = Column(BigInteger, primary_key=True)
    teacher_id = Column(ForeignKey('teacher.id'), nullable=False)
    study_group_base_id = Column(ForeignKey('study_group_base.id'))
    student_id = Column(ForeignKey('student.id'))
    title = Column(Text, nullable=False)
    description = Column(Text)
    status = Column(task_status, nullable=False, server_default=text("'pending'::task_status"))
    priority = Column(task_priority, nullable=False, server_default=text("'medium'::task_priority"))
    expiration_date = Column(DateTime(True), nullable=False)
    create_date = Column(DateTime(True), server_default=text("LOCALTIMESTAMP"))

    student = relationship('Student')
    study_group_base = relationship('StudyGroupBase')
    teacher = relationship('Teacher')


class StudentTask(Task):
    __tablename__ = 'student_task'
    __table_args__ = (
        CheckConstraint('completion_date < deadline_date'),
    )

    id = Column(ForeignKey('task.id'), primary_key=True)
    points = Column(SmallInteger)
    comment = Column(Text)
    feedback = Column(Text)
    grade = Column(student_task_grade)
    deadline_date = Column(DateTime(True))
    start_date = Column(DateTime(True))
    completion_date = Column(DateTime(True))


class TaskStore(Base):
    __tablename__ = 'task_store'
    __table_args__ = (
        CheckConstraint('size <= 838860800'),
    )

    id = Column(BigInteger, primary_key=True)
    task_id = Column(ForeignKey('task.id'), nullable=False)
    url = Column(Text, nullable=False)
    size = Column(BigInteger, nullable=False)
    filename = Column(Text)
    media_type = Column(String(150))
    create_date = Column(DateTime(True), server_default=text("LOCALTIMESTAMP"))

    task = relationship('Task')
